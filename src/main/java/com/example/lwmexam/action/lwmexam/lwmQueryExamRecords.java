package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.entity.lwmexam.lwmTeacher;
import com.example.lwmexam.service.lwmexam.Fpage;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
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
        Fpage fp = new Fpage();
        fp.setPageSize(6);
        if (request.getParameter("page") != null) {
            fp.setPageNow(Integer.parseInt(request.getParameter("page")));
        }
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

            // Build WHERE clause and params for filter
            StringBuilder whereSql = new StringBuilder(" WHERE p.lwmteacherid = ?");
            List<Object> params = new ArrayList<>();
            params.add(teacher.getLwmteacherid());
            if (selectedClass != null && !selectedClass.isEmpty()) {
                whereSql.append(" AND s.lwmclassname = ?");
                params.add(selectedClass);
            }
            if (selectedPaper != null && !selectedPaper.isEmpty()) {
                whereSql.append(" AND p.lwmpapername LIKE ?");
                params.add("%" + selectedPaper + "%");
            }

            // Pagination: count total
            PreparedStatement countStmt = conn.prepareStatement(
                "SELECT COUNT(*) FROM lwmexamrecord r " +
                "JOIN lwmstudent s ON r.lwmstudentid = s.lwmstudentid " +
                "JOIN lwmexampaper p ON r.lwmpaperid = p.lwmpaperid" + whereSql);
            for (int idx = 0; idx < params.size(); idx++) {
                countStmt.setObject(idx + 1, params.get(idx));
            }
            ResultSet countRs = countStmt.executeQuery();
            if (countRs.next()) fp.setRowCount(countRs.getInt(1));
            countRs.close(); countStmt.close();

            // Paged query
            String sql = "SELECT r.*, s.lwmstudentno, s.lwmstudentname, s.lwmclassname, p.lwmpapername, " +
                        "COALESCE(sc.lwmtotalscore, -1) AS lwmtotalscore " +
                        "FROM lwmexamrecord r " +
                        "JOIN lwmstudent s ON r.lwmstudentid = s.lwmstudentid " +
                        "JOIN lwmexampaper p ON r.lwmpaperid = p.lwmpaperid " +
                        "LEFT JOIN lwmexamscore sc ON r.lwmrecordid = sc.lwmrecordid" + whereSql +
                        " ORDER BY r.lwmstarttime DESC LIMIT ?,?";
            params.add(fp.getStart());
            params.add(fp.getPageSize());
            PreparedStatement pstmt = conn.prepareStatement(sql);
            for (int idx = 0; idx < params.size(); idx++) {
                pstmt.setObject(idx + 1, params.get(idx));
            }
            ResultSet rs = pstmt.executeQuery();
            int i = fp.getStart() + 1;
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
                record.put("lwmtotalscore", rs.getInt("lwmtotalscore"));
                records.add(record);
            }
            rs.close(); pstmt.close(); conn.close();
        } catch (Exception e) { e.printStackTrace(); }

        // Build tj string for pagination links
        StringBuilder tj = new StringBuilder();
        if (selectedClass != null && !selectedClass.isEmpty()) {
            tj.append("classname=").append(URLEncoder.encode(selectedClass, "UTF-8"));
        }
        if (selectedPaper != null && !selectedPaper.isEmpty()) {
            if (tj.length() > 0) tj.append("&");
            tj.append("papername=").append(URLEncoder.encode(selectedPaper, "UTF-8"));
        }

        request.setAttribute("classList", classList);
        request.setAttribute("paperList", paperList);
        request.setAttribute("selectedClass", selectedClass != null ? selectedClass : "");
        request.setAttribute("selectedPaper", selectedPaper != null ? selectedPaper : "");
        request.setAttribute("records", records);
        request.setAttribute("fp", fp);
        request.setAttribute("pageUrl", "lwmQueryExamRecords");
        request.setAttribute("tj", tj.toString());
        request.getRequestDispatcher("lwmteacher_exam_records.jsp").forward(request, response);
    }
}
