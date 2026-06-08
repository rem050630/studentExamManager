package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmpaperDAO;
import com.example.lwmexam.entity.lwmexam.lwmStudent;
import com.example.lwmexam.service.lwmexam.MysqlConn;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@WebServlet("/lwmSaveExamDraft")
public class lwmSaveExamDraft extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession();
        lwmStudent student = (lwmStudent) session.getAttribute("student");

        if (student == null) { response.sendRedirect("login.jsp"); return; }

        int paperId = Integer.parseInt(request.getParameter("paperId"));
        MysqlConn db = new MysqlConn();

        int recordId = 0;
        try {
            ResultSet rs = db.doQuery(
                "SELECT lwmrecordid FROM lwmexamrecord WHERE lwmpaperid=? AND lwmstudentid=? AND lwmsubmitstatus=0",
                new Object[]{paperId, student.getLwmstudentid()});
            if (rs.next()) recordId = rs.getInt("lwmrecordid");
        } catch (Exception e) { e.printStackTrace(); }
        db.close();

        if (recordId > 0) {
            // Delete old answers
            db = new MysqlConn();
            db.doUpdate("DELETE FROM lwmstudentanswer WHERE lwmrecordid=?", new Object[]{recordId});
            db.close();
        } else {
            // Create new draft record
            db = new MysqlConn();
            String now = new Timestamp(System.currentTimeMillis()).toString();
            db.doUpdate(
                "INSERT INTO lwmexamrecord(lwmpaperid,lwmstudentid,lwmstarttime,lwmendtime,lwmsubmitstatus) VALUES(?,?,?,?,0)",
                new Object[]{paperId, student.getLwmstudentid(), now, now});
            db.close();

            db = new MysqlConn();
            try {
                ResultSet rs = db.doQuery(
                    "SELECT MAX(lwmrecordid) FROM lwmexamrecord WHERE lwmpaperid=? AND lwmstudentid=?",
                    new Object[]{paperId, student.getLwmstudentid()});
                if (rs.next()) recordId = rs.getInt(1);
            } catch (Exception e) { e.printStackTrace(); }
            db.close();
        }

        if (recordId == 0) { response.sendRedirect("lwmstudent_main.jsp"); return; }

        // Load all question IDs so we can fill in unanswered ones
        lwmpaperDAO pDao = new lwmpaperDAO();
        List<Integer> allQIdList = pDao.lwmGetPaperQuestionIds(paperId);
        Set<Integer> allQIds = new HashSet<>(allQIdList);

        db = new MysqlConn();
        Set<Integer> savedIds = new HashSet<>();
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
                    savedIds.add(questionId);
                }
            }
            // Insert empty answers for unanswered questions
            for (int qid : allQIds) {
                if (!savedIds.contains(qid)) {
                    db.doUpdate(
                        "INSERT INTO lwmstudentanswer(lwmrecordid,lwmquestionid,lwmstudentanswer,lwmquestionscore,lwmstudentid,lwmpaperid) VALUES(?,?,?,0,?,?)",
                        new Object[]{recordId, qid, "", student.getLwmstudentid(), paperId});
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        db.close();

        // Auto-record mistakes
        recordMistakes(student.getLwmstudentid(), paperId);

        response.sendRedirect("lwmstudent_main.jsp");
    }

    private void recordMistakes(int studentId, int paperId) {
        com.example.lwmexam.dao.lwmexam.lwmpaperDAO pDao = new com.example.lwmexam.dao.lwmexam.lwmpaperDAO();
        com.example.lwmexam.entity.lwmexam.lwmExamPaper paper = pDao.lwmQueryPaperById(paperId);
        if (paper == null) return;

        com.example.lwmexam.dao.lwmexam.lwmMistakeBookDAO mbDao = new com.example.lwmexam.dao.lwmexam.lwmMistakeBookDAO();
        com.example.lwmexam.service.lwmexam.MysqlConn db = new com.example.lwmexam.service.lwmexam.MysqlConn();
        try {
            java.sql.ResultSet rs = db.doQuery(
                "SELECT sa.lwmquestionid, sa.lwmquestionscore, q.lwmquestiontype " +
                "FROM lwmstudentanswer sa JOIN lwmexamquestion q ON sa.lwmquestionid = q.lwmquestionid " +
                "WHERE sa.lwmrecordid = (SELECT MAX(lwmrecordid) FROM lwmexamrecord WHERE lwmpaperid = ? AND lwmstudentid = ?)",
                new Object[]{paperId, studentId});
            while (rs.next()) {
                String type = rs.getString("lwmquestiontype");
                int score = rs.getInt("lwmquestionscore");
                int maxScore = 0;
                if ("单选题".equals(type)) maxScore = paper.getLwmdanxscore();
                else if ("多选题".equals(type)) maxScore = paper.getLwmduoxscore();
                else if ("判断题".equals(type)) maxScore = paper.getLwmpdscore();
                else if ("简答题".equals(type)) maxScore = paper.getLwmjdscore();

                boolean isWrong = score < maxScore;
                int questionId = rs.getInt("lwmquestionid");
                mbDao.upsertMistake(studentId, questionId, isWrong);
            }
        } catch (Exception e) { e.printStackTrace(); }
        db.close();
    }
}
