package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmpaperDAO;
import com.example.lwmexam.dao.lwmexam.lwmquestionDAO;
import com.example.lwmexam.entity.lwmexam.lwmExamPaper;
import com.example.lwmexam.entity.lwmexam.lwmExamQuestion;
import com.example.lwmexam.entity.lwmexam.lwmStudent;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Statement;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/lwmTakeExam")
public class lwmTakeExam extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        lwmStudent student = (lwmStudent) session.getAttribute("student");
        if (student == null) { response.sendRedirect("login.jsp"); return; }

        int paperId = Integer.parseInt(request.getParameter("paperId"));
        lwmpaperDAO pDao = new lwmpaperDAO();
        lwmExamPaper paper = pDao.lwmQueryPaperById(paperId);

        // Check if student's class is among the published classes (comma-separated)
        boolean classMatch = false;
        if (paper != null && paper.getLwmclassname() != null) {
            for (String cls : paper.getLwmclassname().split(",")) {
                if (cls.trim().equals(student.getLwmclassname())) { classMatch = true; break; }
            }
        }
        if (paper == null || !classMatch) {
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<script>alert('试卷不存在或不可访问');history.go(-1);</script>");
            return;
        }

        // Time-based access control
        String startTimeStr = paper.getLwmstarttime();
        String endTimeStr = paper.getLwmendtime();
        if (startTimeStr != null && !startTimeStr.isEmpty() && endTimeStr != null && !endTimeStr.isEmpty()) {
            LocalDateTime now = LocalDateTime.now();
            LocalDateTime startTime = parseTime(startTimeStr);
            LocalDateTime endTime = parseTime(endTimeStr);
            if (startTime != null && endTime != null) {
                if (now.isBefore(startTime)) {
                    response.setContentType("text/html;charset=UTF-8");
                    response.getWriter().println("<script>alert('考试还未开始，开始时间：" + startTimeStr + "');history.go(-1);</script>");
                    return;
                }
                if (now.isAfter(endTime)) {
                    response.setContentType("text/html;charset=UTF-8");
                    response.getWriter().println("<script>alert('考试已结束，结束时间：" + endTimeStr + "');history.go(-1);</script>");
                    return;
                }
            }
        }

        lwmquestionDAO qDao = new lwmquestionDAO();
        List<Integer> qIds = pDao.lwmGetPaperQuestionIds(paperId);
        List<lwmExamQuestion> questions = new ArrayList<>();
        for (int qId : qIds) {
            lwmExamQuestion q = qDao.lwmQueryById(qId);
            if (q != null) questions.add(q);
        }

        // Load existing draft record (status=0) for this student+paper, or create one
        java.util.Map<Integer, String> draftAnswers = new java.util.HashMap<>();
        int draftRecordId = 0;
        java.sql.Timestamp recordStartTime = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            java.sql.Connection conn = java.sql.DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8",
                "root", "123456");

            java.sql.PreparedStatement ps = conn.prepareStatement(
                "SELECT lwmrecordid, lwmstarttime FROM lwmexamrecord WHERE lwmpaperid=? AND lwmstudentid=? AND lwmsubmitstatus=0");
            ps.setInt(1, paperId);
            ps.setInt(2, student.getLwmstudentid());
            java.sql.ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                draftRecordId = rs.getInt("lwmrecordid");
                recordStartTime = rs.getTimestamp("lwmstarttime");
                rs.close(); ps.close();
                java.sql.PreparedStatement aps = conn.prepareStatement(
                    "SELECT lwmquestionid, lwmstudentanswer FROM lwmstudentanswer WHERE lwmrecordid=?");
                aps.setInt(1, draftRecordId);
                java.sql.ResultSet ars = aps.executeQuery();
                while (ars.next()) {
                    draftAnswers.put(ars.getInt("lwmquestionid"), ars.getString("lwmstudentanswer"));
                }
                ars.close(); aps.close();
            } else {
                rs.close(); ps.close();
                // No draft — create exam record with current time as start time
                recordStartTime = new java.sql.Timestamp(System.currentTimeMillis());
                java.sql.PreparedStatement ips = conn.prepareStatement(
                    "INSERT INTO lwmexamrecord(lwmpaperid,lwmstudentid,lwmstarttime,lwmendtime,lwmsubmitstatus) VALUES(?,?,?,?,0)",
                    Statement.RETURN_GENERATED_KEYS);
                ips.setInt(1, paperId);
                ips.setInt(2, student.getLwmstudentid());
                ips.setTimestamp(3, recordStartTime);
                ips.setTimestamp(4, recordStartTime);
                ips.executeUpdate();
                java.sql.ResultSet keys = ips.getGeneratedKeys();
                if (keys.next()) {
                    draftRecordId = keys.getInt(1);
                }
                keys.close(); ips.close();
            }
            conn.close();
        } catch (Exception e) { e.printStackTrace(); }

        request.setAttribute("paper", paper);
        request.setAttribute("questions", questions);
        request.setAttribute("draftAnswers", draftAnswers);
        request.setAttribute("draftRecordId", draftRecordId);
        request.setAttribute("recordStartTime", recordStartTime);
        request.getRequestDispatcher("lwmstudent_take_exam.jsp").forward(request, response);
    }

    private LocalDateTime parseTime(String timeStr) {
        if (timeStr == null || timeStr.isEmpty()) return null;
        // Handle both "yyyy-MM-dd HH:mm:ss" (DB) and "yyyy-MM-ddTHH:mm" (form) formats
        String[] patterns = {
            "yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd HH:mm:ss.S", "yyyy-MM-dd'T'HH:mm", "yyyy-MM-dd HH:mm"
        };
        for (String pattern : patterns) {
            try {
                return LocalDateTime.parse(timeStr, DateTimeFormatter.ofPattern(pattern));
            } catch (DateTimeParseException ignored) {}
        }
        // Try default ISO parsing
        try {
            return LocalDateTime.parse(timeStr.replace(" ", "T"));
        } catch (DateTimeParseException e) {
            return null;
        }
    }
}
