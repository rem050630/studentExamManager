package com.example.lwmexam.action.lwmexam;

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

@WebServlet("/lwmDeleteExamRecord")
public class lwmDeleteExamRecord extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        PrintWriter out = response.getWriter();

        if (teacher == null) { out.println("<script>alert('请先登录');location.href='login.jsp';</script>"); return; }

        int recordId = Integer.parseInt(request.getParameter("recordId"));

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8",
                "root", "123456");

            // Verify the record belongs to a paper created by this teacher
            PreparedStatement check = conn.prepareStatement(
                "SELECT r.lwmrecordid FROM lwmexamrecord r " +
                "JOIN lwmexampaper p ON r.lwmpaperid = p.lwmpaperid " +
                "WHERE r.lwmrecordid = ? AND p.lwmteacherid = ?");
            check.setInt(1, recordId);
            check.setInt(2, teacher.getLwmteacherid());
            ResultSet rs = check.executeQuery();
            if (!rs.next()) {
                rs.close(); check.close(); conn.close();
                out.println("<script>alert('无权删除该记录');history.go(-1);</script>");
                return;
            }
            rs.close(); check.close();

            // Delete related data in order (child tables first)
            conn.createStatement().executeUpdate(
                "DELETE FROM lwmexamscore WHERE lwmrecordid = " + recordId);
            conn.createStatement().executeUpdate(
                "DELETE FROM lwmstudentanswer WHERE lwmrecordid = " + recordId);
            conn.createStatement().executeUpdate(
                "DELETE FROM lwmexamrecord WHERE lwmrecordid = " + recordId);

            conn.close();
            out.println("<script>alert('删除成功');location.href='lwmQueryExamRecords';</script>");
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('删除失败');history.go(-1);</script>");
        }
    }
}
