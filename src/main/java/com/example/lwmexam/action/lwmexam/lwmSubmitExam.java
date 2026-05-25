package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.entity.lwmexam.lwmStudent;
import com.example.lwmexam.service.lwmexam.MysqlConn;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.ResultSet;
import java.sql.Timestamp;

@WebServlet("/lwmSubmitExam")
public class lwmSubmitExam extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession();
        lwmStudent student = (lwmStudent) session.getAttribute("student");
        PrintWriter out = response.getWriter();

        if (student == null) { out.println("<script>alert('请先登录');location.href='login.jsp';</script>"); return; }

        int paperId = Integer.parseInt(request.getParameter("paperId"));

        // Load paper to get exam duration for timeout check
        com.example.lwmexam.dao.lwmexam.lwmpaperDAO pDao = new com.example.lwmexam.dao.lwmexam.lwmpaperDAO();
        com.example.lwmexam.entity.lwmexam.lwmExamPaper paper = pDao.lwmQueryPaperById(paperId);
        boolean isAutoSubmit = "true".equals(request.getParameter("autoSubmit"));

        MysqlConn db = new MysqlConn();
        int recordId = 0;
        java.sql.Timestamp recordStartTime = null;
        try {
            ResultSet rs = db.doQuery(
                "SELECT lwmrecordid, lwmstarttime FROM lwmexamrecord WHERE lwmpaperid=? AND lwmstudentid=? AND lwmsubmitstatus=0",
                new Object[]{paperId, student.getLwmstudentid()});
            if (rs.next()) {
                recordId = rs.getInt("lwmrecordid");
                recordStartTime = rs.getTimestamp("lwmstarttime");
            }
        } catch (Exception e) { e.printStackTrace(); }
        db.close();

        // Timeout check: reject manual submission if student's time has expired
        if (recordStartTime != null && paper != null && paper.getLwmexamtime() > 0) {
            long deadline = recordStartTime.getTime() + paper.getLwmexamtime() * 60 * 1000L;
            long tolerance = isAutoSubmit ? 5000 : 0;
            if (System.currentTimeMillis() > deadline + tolerance) {
                out.println("<script>alert('考试时间已到，无法提交');history.back();</script>");
                return;
            }
        }

        if (recordId > 0) {
            db = new MysqlConn();
            String now = new Timestamp(System.currentTimeMillis()).toString();
            db.doUpdate(
                "UPDATE lwmexamrecord SET lwmsubmitstatus=1, lwmendtime=? WHERE lwmrecordid=?",
                new Object[]{now, recordId});
            db.close();
            db = new MysqlConn();
            db.doUpdate("DELETE FROM lwmstudentanswer WHERE lwmrecordid=?", new Object[]{recordId});
            db.close();
        } else {
            // No draft: create new record
            db = new MysqlConn();
            String now = new Timestamp(System.currentTimeMillis()).toString();
            db.doUpdate(
                "INSERT INTO lwmexamrecord(lwmpaperid,lwmstudentid,lwmstarttime,lwmendtime,lwmsubmitstatus) VALUES(?,?,?,?,1)",
                new Object[]{paperId, student.getLwmstudentid(), now, now});
            db.close();

            // Retrieve the new record ID
            db = new MysqlConn();
            try {
                ResultSet rs = db.doQuery(
                    "SELECT MAX(lwmrecordid) FROM lwmexamrecord WHERE lwmpaperid=? AND lwmstudentid=?",
                    new Object[]{paperId, student.getLwmstudentid()});
                if (rs.next()) recordId = rs.getInt(1);
            } catch (Exception e) { e.printStackTrace(); }
            db.close();
        }

        if (recordId == 0) {
            out.println("<script>alert('提交失败');history.go(-1);</script>");
            return;
        }

        saveAnswers(request, recordId, student.getLwmstudentid(), paperId);

        if (isAutoSubmit) {
            out.println("<script>alert('考试时间到，系统已自动交卷');location.href='lwmstudent_main.jsp';</script>");
        } else {
            out.println("<script>alert('交卷成功！等待教师批阅。');location.href='lwmstudent_main.jsp';</script>");
        }
    }

    private void saveAnswers(HttpServletRequest request, int recordId, int studentId, int paperId) {
        MysqlConn db2 = new MysqlConn();
        try {
            java.util.Enumeration<String> names = request.getParameterNames();
            while (names.hasMoreElements()) {
                String name = names.nextElement();
                if (name.startsWith("q_")) {
                    int questionId = Integer.parseInt(name.substring(2));
                    String[] values = request.getParameterValues(name);
                    String answer = values != null ? String.join(",", values) : "";
                    db2.doUpdate(
                        "INSERT INTO lwmstudentanswer(lwmrecordid,lwmquestionid,lwmstudentanswer,lwmquestionscore,lwmstudentid,lwmpaperid) VALUES(?,?,?,0,?,?)",
                        new Object[]{recordId, questionId, answer, studentId, paperId});
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        db2.close();
    }
}
