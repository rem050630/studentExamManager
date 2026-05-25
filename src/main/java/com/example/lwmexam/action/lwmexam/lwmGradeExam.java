package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmpaperDAO;
import com.example.lwmexam.dao.lwmexam.lwmscoreDAO;
import com.example.lwmexam.entity.lwmexam.lwmExamPaper;
import com.example.lwmexam.entity.lwmexam.lwmStudentAnswer;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

@WebServlet("/lwmGradeExam")
public class lwmGradeExam extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("teacher") == null) {
            response.sendRedirect("login.jsp"); return;
        }

        int recordId = Integer.parseInt(request.getParameter("recordId"));

        // Check submit status — reject if already finalized
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            java.sql.Connection conn = java.sql.DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8",
                "root", "123456");
            java.sql.PreparedStatement ps = conn.prepareStatement(
                "SELECT lwmsubmitstatus FROM lwmexamrecord WHERE lwmrecordid = ?");
            ps.setInt(1, recordId);
            java.sql.ResultSet rs = ps.executeQuery();
            if (rs.next() && rs.getInt("lwmsubmitstatus") == 2) {
                rs.close(); ps.close(); conn.close();
                response.setContentType("text/html;charset=UTF-8");
                response.getWriter().println("<script>alert('成绩已提交，无法修改');location.href='lwmQueryExamRecords';</script>");
                return;
            }
            rs.close(); ps.close(); conn.close();
        } catch (Exception e) { e.printStackTrace(); }

        lwmscoreDAO dao = new lwmscoreDAO();
        List<lwmStudentAnswer> answers = dao.lwmQueryAnswersByRecord(recordId);
        answers.sort(Comparator.comparingInt(a -> {
            String t = a.getLwmquestiontype();
            if ("单选题".equals(t)) return 1;
            if ("多选题".equals(t)) return 2;
            if ("判断题".equals(t)) return 3;
            if ("简答题".equals(t)) return 4;
            return 5;
        }));

        // Auto-grade objective questions on first load (scores are 0)
        boolean needAutoScore = true;
        for (lwmStudentAnswer a : answers) {
            if (a.getLwmquestionscore() > 0) { needAutoScore = false; break; }
        }

        // Get paper info for per-question max scores
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

        if (needAutoScore) {
            for (lwmStudentAnswer a : answers) {
                int autoScore = autoGrade(a);
                a.setLwmquestionscore(autoScore);
            }
        }

        request.setAttribute("answers", answers);
        request.setAttribute("recordId", recordId);
        request.getRequestDispatcher("lwmteacher_grading.jsp").forward(request, response);
    }

    private int autoGrade(lwmStudentAnswer a) {
        String type = a.getLwmquestiontype();
        String studentAns = a.getLwmstudentanswer();
        String correctAns = a.getLwmcorrectanswer();
        if (studentAns == null || correctAns == null) return 0;

        if ("单选题".equals(type) || "判断题".equals(type)) {
            return studentAns.trim().equals(correctAns.trim()) ? a.getLwmpaperscore() : 0;
        } else if ("多选题".equals(type)) {
            // Normalize answers: split by comma, or treat each char as option if no comma
            String[] stuArr = splitAnswer(studentAns.trim());
            String[] corArr = splitAnswer(correctAns.trim());
            Arrays.sort(stuArr);
            Arrays.sort(corArr);
            return Arrays.equals(stuArr, corArr) ? a.getLwmpaperscore() : 0;
        }
        return 0; // 简答题不自动评分
    }

    // Normalize multi-select answer: "A,C,D" → ["A","C","D"]; "ACD" → ["A","C","D"]
    private String[] splitAnswer(String ans) {
        if (ans.contains(",") || ans.contains("，")) {
            return ans.replace("，", ",").split(",");
        }
        return ans.split("");
    }
}
