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
        MysqlConn db = new MysqlConn();

        try {
            // Create exam record
            String now = new Timestamp(System.currentTimeMillis()).toString();
            db.doUpdate(
                "INSERT INTO lwmexamrecord(lwmpaperid,lwmstudentid,lwmstarttime,lwmendtime,lwmsubmitstatus) VALUES(?,?,?,?,1)",
                new Object[]{paperId, student.getLwmstudentid(), now, now});
        } catch (Exception e) { e.printStackTrace(); }
        db.close();

        // Retrieve the record ID
        int recordId = 0;
        db = new MysqlConn();
        try {
            ResultSet rs = db.doQuery(
                "SELECT MAX(lwmrecordid) FROM lwmexamrecord WHERE lwmpaperid=? AND lwmstudentid=?",
                new Object[]{paperId, student.getLwmstudentid()});
            if (rs.next()) recordId = rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        db.close();

        if (recordId == 0) {
            out.println("<script>alert('提交失败');history.go(-1);</script>");
            return;
        }

        // Save each answer
        db = new MysqlConn();
        try {
            java.util.Enumeration<String> names = request.getParameterNames();
            while (names.hasMoreElements()) {
                String name = names.nextElement();
                if (name.startsWith("q_")) {
                    int questionId = Integer.parseInt(name.substring(2));
                    String[] values = request.getParameterValues(name);
                    String answer = values != null ? String.join(",", values) : "";
                    db.doUpdate(
                        "INSERT INTO lwmstudentanswer(lwmrecordid,lwmquestionid,lwmstudentanswer,lwmquestionscore,lwmstudentid,lwmpaperid) VALUES(?,?,?,0,?,?)",
                        new Object[]{recordId, questionId, answer, student.getLwmstudentid(), paperId});
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        db.close();

        out.println("<script>alert('交卷成功！等待教师批阅。');location.href='lwmstudent_main.jsp';</script>");
    }
}
