package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmpaperDAO;
import com.example.lwmexam.dao.lwmexam.lwmscoreDAO;
import com.example.lwmexam.entity.lwmexam.lwmExamPaper;
import com.example.lwmexam.entity.lwmexam.lwmExamScore;
import com.example.lwmexam.entity.lwmexam.lwmTeacher;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/lwmSubmitScore")
public class lwmSubmitScore extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        PrintWriter out = response.getWriter();

        if (teacher == null) { out.println("<script>alert('请先登录');location.href='login.jsp';</script>"); return; }

        int recordId = Integer.parseInt(request.getParameter("recordId"));
        int studentId = Integer.parseInt(request.getParameter("studentId"));
        int paperId = Integer.parseInt(request.getParameter("paperId"));
        boolean finalize = "true".equals(request.getParameter("finalize"));

        // Load paper config for per-type max scores
        lwmpaperDAO pDao = new lwmpaperDAO();
        lwmExamPaper paper = pDao.lwmQueryPaperById(paperId);

        // Load answer -> question type mapping for validation
        Map<Integer, String> answerTypes = new HashMap<>();
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8",
                "root", "123456");
            PreparedStatement ps = conn.prepareStatement(
                "SELECT sa.lwmanswerid, q.lwmquestiontype FROM lwmstudentanswer sa " +
                "JOIN lwmexamquestion q ON sa.lwmquestionid = q.lwmquestionid " +
                "WHERE sa.lwmrecordid = ?");
            ps.setInt(1, recordId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                answerTypes.put(rs.getInt("lwmanswerid"), rs.getString("lwmquestiontype"));
            }
            rs.close(); ps.close(); conn.close();
        } catch (Exception e) { e.printStackTrace(); }

        lwmscoreDAO dao = new lwmscoreDAO();
        int totalScore = 0;

        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String name = paramNames.nextElement();
            if (name.startsWith("score_")) {
                int answerId = Integer.parseInt(name.substring(6));
                int score = Integer.parseInt(request.getParameter(name));
                // Clamp score to question type max
                String type = answerTypes.get(answerId);
                int maxScore = 0;
                if ("单选题".equals(type)) maxScore = paper.getLwmdanxscore();
                else if ("多选题".equals(type)) maxScore = paper.getLwmduoxscore();
                else if ("判断题".equals(type)) maxScore = paper.getLwmpdscore();
                else if ("简答题".equals(type)) maxScore = paper.getLwmjdscore();
                if (maxScore > 0 && score > maxScore) score = maxScore;
                dao.lwmSaveQuestionScore(answerId, score);
                totalScore += score;
            }
        }

        lwmExamScore examScore = new lwmExamScore();
        examScore.setLwmrecordid(recordId);
        examScore.setLwmtotalscore(totalScore);
        examScore.setLwmteacherid(teacher.getLwmteacherid());
        examScore.setLwmstudentid(studentId);
        examScore.setLwmpaperid(paperId);
        dao.lwmSaveScore(examScore);

        // Only set status to 2 when teacher explicitly clicks "提交成绩"
        if (finalize) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8",
                    "root", "123456");
                PreparedStatement pstmt = conn.prepareStatement(
                    "UPDATE lwmexamrecord SET lwmsubmitstatus = 2 WHERE lwmrecordid = ?");
                pstmt.setInt(1, recordId);
                pstmt.executeUpdate();
                pstmt.close(); conn.close();
            } catch (Exception e) { e.printStackTrace(); }
            out.println("<script>alert('成绩提交成功，总分：" + totalScore + "');location.href='lwmQueryExamRecords';</script>");
        } else {
            out.println("<script>alert('评分已保存，总分：" + totalScore + "（尚未提交成绩）');location.href='lwmQueryExamRecords';</script>");
        }
    }
}
