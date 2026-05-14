package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmscoreDAO;
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
import java.util.Enumeration;

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

        lwmscoreDAO dao = new lwmscoreDAO();
        int totalScore = 0;

        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String name = paramNames.nextElement();
            if (name.startsWith("score_")) {
                int answerId = Integer.parseInt(name.substring(6));
                int score = Integer.parseInt(request.getParameter(name));
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

        // Update submit status to 2 (已批阅)
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

        out.println("<script>alert('评分提交成功，总分：" + totalScore + "');location.href='lwmQueryExamRecords';</script>");
    }
}
