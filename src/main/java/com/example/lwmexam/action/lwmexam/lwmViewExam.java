package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmpaperDAO;
import com.example.lwmexam.dao.lwmexam.lwmscoreDAO;
import com.example.lwmexam.entity.lwmexam.lwmExamPaper;
import com.example.lwmexam.entity.lwmexam.lwmStudent;
import com.example.lwmexam.entity.lwmexam.lwmStudentAnswer;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Comparator;
import java.util.List;

@WebServlet("/lwmViewExam")
public class lwmViewExam extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        lwmStudent student = (lwmStudent) session.getAttribute("student");
        if (student == null) { response.sendRedirect("login.jsp"); return; }

        int recordId = Integer.parseInt(request.getParameter("recordId"));

        String paperName = "";
        int status = 0;
        Integer totalScore = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8",
                "root", "123456");
            PreparedStatement pstmt = conn.prepareStatement(
                "SELECT r.lwmsubmitstatus, p.lwmpapername, sc.lwmtotalscore FROM lwmexamrecord r " +
                "JOIN lwmexampaper p ON r.lwmpaperid = p.lwmpaperid " +
                "LEFT JOIN lwmexamscore sc ON r.lwmrecordid = sc.lwmrecordid " +
                "WHERE r.lwmrecordid = ? AND r.lwmstudentid = ?");
            pstmt.setInt(1, recordId);
            pstmt.setInt(2, student.getLwmstudentid());
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                status = rs.getInt("lwmsubmitstatus");
                paperName = rs.getString("lwmpapername");
                totalScore = (Integer) rs.getObject("lwmtotalscore");
            } else {
                rs.close(); pstmt.close(); conn.close();
                response.getWriter().println("<script>alert('记录不存在或无权查看');location.href='lwmstudent_main.jsp';</script>");
                return;
            }
            rs.close(); pstmt.close(); conn.close();
        } catch (Exception e) { e.printStackTrace(); }

        // Only allow viewing submitted/graded exams
        if (status == 0) {
            response.getWriter().println("<script>alert('该试卷尚未提交，无法查看');location.href='lwmstudent_main.jsp';</script>");
            return;
        }

        lwmscoreDAO dao = new lwmscoreDAO();
        List<lwmStudentAnswer> answers = dao.lwmQueryAnswersByRecord(recordId);

        // Set per-question max scores from paper config
        answers.sort(Comparator.comparingInt(a -> {
            switch (a.getLwmquestiontype() != null ? a.getLwmquestiontype() : "") {
                case "单选题": return 1;
                case "多选题": return 2;
                case "判断题": return 3;
                case "简答题": return 4;
                default: return 5;
            }
        }));

        if (!answers.isEmpty()) {
            lwmpaperDAO pDao = new lwmpaperDAO();
            lwmExamPaper paper = pDao.lwmQueryPaperById(answers.get(0).getLwmpaperid());
            if (paper != null) {
                for (lwmStudentAnswer a : answers) {
                    String type = a.getLwmquestiontype();
                    if ("单选题".equals(type)) a.setLwmpaperscore(paper.getLwmdanxscore());
                    else if ("多选题".equals(type)) a.setLwmpaperscore(paper.getLwmduoxscore());
                    else if ("判断题".equals(type)) a.setLwmpaperscore(paper.getLwmpdscore());
                    else if ("简答题".equals(type)) a.setLwmpaperscore(paper.getLwmjdscore());
                }
            }
        }

        request.setAttribute("answers", answers);
        request.setAttribute("recordId", recordId);
        request.setAttribute("paperName", paperName);
        request.setAttribute("status", status);
        request.setAttribute("totalScore", totalScore);
        request.getRequestDispatcher("lwmstudent_view_exam.jsp").forward(request, response);
    }
}
