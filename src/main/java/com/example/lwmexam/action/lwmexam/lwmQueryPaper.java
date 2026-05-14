package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmpaperDAO;
import com.example.lwmexam.entity.lwmexam.lwmExamPaper;
import com.example.lwmexam.entity.lwmexam.lwmTeacher;

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
import java.util.ArrayList;
import java.util.List;

@WebServlet("/lwmQueryPaper")
public class lwmQueryPaper extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        if (teacher == null) { response.sendRedirect("login.jsp"); return; }

        String selectedClass = request.getParameter("classname");
        String selectedPaper = request.getParameter("papername");
        String subjectIdStr = request.getParameter("subjectid");
        Integer selectedSubjectId = (subjectIdStr != null && !subjectIdStr.isEmpty()) ? Integer.parseInt(subjectIdStr) : null;

        List<String> classList = new ArrayList<>();
        List<String> paperList = new ArrayList<>();
        List<String[]> subjectList = new ArrayList<>(); // [id, name] pairs

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8",
                "root", "123456");

            // Load distinct class names for this teacher's papers
            PreparedStatement csPstmt = conn.prepareStatement(
                "SELECT DISTINCT lwmclassname FROM lwmexampaper WHERE lwmteacherid = ? ORDER BY lwmclassname");
            csPstmt.setInt(1, teacher.getLwmteacherid());
            ResultSet csRs = csPstmt.executeQuery();
            while (csRs.next()) classList.add(csRs.getString("lwmclassname"));
            csRs.close(); csPstmt.close();

            // Load distinct paper names for this teacher
            PreparedStatement pnPstmt = conn.prepareStatement(
                "SELECT DISTINCT lwmpapername FROM lwmexampaper WHERE lwmteacherid = ? ORDER BY lwmpapername");
            pnPstmt.setInt(1, teacher.getLwmteacherid());
            ResultSet pnRs = pnPstmt.executeQuery();
            while (pnRs.next()) paperList.add(pnRs.getString("lwmpapername"));
            pnRs.close(); pnPstmt.close();

            // Load distinct subjects for this teacher's papers
            PreparedStatement subPstmt = conn.prepareStatement(
                "SELECT DISTINCT p.lwmsubjectid, s.lwmsubjectname FROM lwmexampaper p " +
                "LEFT JOIN lwmexamsubject s ON p.lwmsubjectid = s.lwmsubjectid " +
                "WHERE p.lwmteacherid = ? ORDER BY s.lwmsubjectname");
            subPstmt.setInt(1, teacher.getLwmteacherid());
            ResultSet subRs = subPstmt.executeQuery();
            while (subRs.next()) {
                subjectList.add(new String[]{String.valueOf(subRs.getInt("lwmsubjectid")), subRs.getString("lwmsubjectname")});
            }
            subRs.close(); subPstmt.close();

            conn.close();
        } catch (Exception e) { e.printStackTrace(); }

        lwmpaperDAO dao = new lwmpaperDAO();
        List<lwmExamPaper> papers = dao.lwmQueryByTeacherWithFilters(
            teacher.getLwmteacherid(), selectedClass, selectedPaper, selectedSubjectId);

        request.setAttribute("papers", papers);
        request.setAttribute("classList", classList);
        request.setAttribute("paperList", paperList);
        request.setAttribute("subjectList", subjectList);
        request.setAttribute("selectedClass", selectedClass != null ? selectedClass : "");
        request.setAttribute("selectedPaper", selectedPaper != null ? selectedPaper : "");
        request.setAttribute("selectedSubjectId", selectedSubjectId != null ? String.valueOf(selectedSubjectId) : "");
        request.getRequestDispatcher("lwmteacher_paper_list.jsp").forward(request, response);
    }
}
