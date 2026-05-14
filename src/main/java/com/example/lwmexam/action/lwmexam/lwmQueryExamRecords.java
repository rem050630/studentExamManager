package com.example.lwmexam.action.lwmexam;

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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/lwmQueryExamRecords")
public class lwmQueryExamRecords extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        if (teacher == null) { response.sendRedirect("login.jsp"); return; }

        String selectedClass = request.getParameter("classname");
        String selectedPaper = request.getParameter("papername");
        List<Map<String, Object>> records = new ArrayList<>();
        List<String> classList = new ArrayList<>();
        List<String> paperList = new ArrayList<>();
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8",
                "root", "123456");

            // Load distinct class names for this teacher's papers
            PreparedStatement csPstmt = conn.prepareStatement(
                "SELECT DISTINCT s.lwmclassname FROM lwmexamrecord r " +
                "JOIN lwmstudent s ON r.lwmstudentid = s.lwmstudentid " +
                "JOIN lwmexampaper p ON r.lwmpaperid = p.lwmpaperid " +
                "WHERE p.lwmteacherid = ? ORDER BY s.lwmclassname");
            csPstmt.setInt(1, teacher.getLwmteacherid());
            ResultSet csRs = csPstmt.executeQuery();
            while (csRs.next()) classList.add(csRs.getString("lwmclassname"));
            csRs.close(); csPstmt.close();

            // Load distinct paper names for this teacher
            PreparedStatement pnPstmt = conn.prepareStatement(
                "SELECT DISTINCT p.lwmpapername FROM lwmexamrecord r " +
                "JOIN lwmexampaper p ON r.lwmpaperid = p.lwmpaperid " +
                "WHERE p.lwmteacherid = ? ORDER BY p.lwmpapername");
            pnPstmt.setInt(1, teacher.getLwmteacherid());
            ResultSet pnRs = pnPstmt.executeQuery();
            while (pnRs.next()) paperList.add(pnRs.getString("lwmpapername"));
            pnRs.close(); pnPstmt.close();

            // Build query with optional filters
            String sql = "SELECT r.*, s.lwmstudentno, s.lwmstudentname, s.lwmclassname, p.lwmpapername " +
                        "FROM lwmexamrecord r " +
                        "JOIN lwmstudent s ON r.lwmstudentid = s.lwmstudentid " +
                        "JOIN lwmexampaper p ON r.lwmpaperid = p.lwmpaperid " +
                        "WHERE p.lwmteacherid = ?";
            List<Object> params = new ArrayList<>();
            params.add(teacher.getLwmteacherid());
            if (selectedClass != null && !selectedClass.isEmpty()) {
                sql += " AND s.lwmclassname = ?";
                params.add(selectedClass);
            }
            if (selectedPaper != null && !selectedPaper.isEmpty()) {
                sql += " AND p.lwmpapername = ?";
                params.add(selectedPaper);
            }
            sql += " ORDER BY r.lwmstarttime DESC";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            for (int idx = 0; idx < params.size(); idx++) {
                pstmt.setObject(idx + 1, params.get(idx));
            }
            ResultSet rs = pstmt.executeQuery();
            int i = 1;
            while (rs.next()) {
                Map<String, Object> record = new HashMap<>();
                record.put("index", i++);
                record.put("lwmrecordid", rs.getInt("lwmrecordid"));
                record.put("lwmpaperid", rs.getInt("lwmpaperid"));
                record.put("lwmpapername", rs.getString("lwmpapername"));
                record.put("lwmstudentno", rs.getString("lwmstudentno"));
                record.put("lwmstudentname", rs.getString("lwmstudentname"));
                record.put("lwmclassname", rs.getString("lwmclassname"));
                record.put("lwmstarttime", rs.getString("lwmstarttime"));
                record.put("lwmendtime", rs.getString("lwmendtime"));
                record.put("lwmsubmitstatus", rs.getInt("lwmsubmitstatus"));
                records.add(record);
            }
            rs.close(); pstmt.close(); conn.close();
        } catch (Exception e) { e.printStackTrace(); }

        request.setAttribute("classList", classList);
        request.setAttribute("paperList", paperList);
        request.setAttribute("selectedClass", selectedClass != null ? selectedClass : "");
        request.setAttribute("selectedPaper", selectedPaper != null ? selectedPaper : "");
        request.setAttribute("records", records);
        request.getRequestDispatcher("lwmteacher_exam_records.jsp").forward(request, response);
    }
}
