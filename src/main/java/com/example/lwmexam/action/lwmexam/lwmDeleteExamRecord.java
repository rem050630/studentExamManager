package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.entity.lwmexam.lwmStudent;
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
        lwmStudent student = (lwmStudent) session.getAttribute("student");
        PrintWriter out = response.getWriter();

        if (teacher == null && student == null) {
            out.println("<script>alert('请先登录');location.href='login.jsp';</script>"); return;
        }

        int recordId = Integer.parseInt(request.getParameter("recordId"));

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8",
                "root", "123456");

            // Verify ownership
            if (teacher != null) {
                // Teacher: verify record belongs to one of their papers
                PreparedStatement checkStmt = conn.prepareStatement(
                    "SELECT r.lwmrecordid FROM lwmexamrecord r " +
                    "JOIN lwmexampaper p ON r.lwmpaperid = p.lwmpaperid " +
                    "WHERE r.lwmrecordid = ? AND p.lwmteacherid = ?");
                checkStmt.setInt(1, recordId);
                checkStmt.setInt(2, teacher.getLwmteacherid());
                ResultSet rs = checkStmt.executeQuery();
                if (!rs.next()) {
                    rs.close(); checkStmt.close(); conn.close();
                    out.println("<script>alert('无权删除该记录');history.go(-1);</script>"); return;
                }
                rs.close(); checkStmt.close();
            } else {
                // Student: can only delete own ungraded records
                PreparedStatement checkStmt = conn.prepareStatement(
                    "SELECT lwmsubmitstatus FROM lwmexamrecord WHERE lwmrecordid = ? AND lwmstudentid = ?");
                checkStmt.setInt(1, recordId);
                checkStmt.setInt(2, student.getLwmstudentid());
                ResultSet rs = checkStmt.executeQuery();
                if (!rs.next()) {
                    rs.close(); checkStmt.close(); conn.close();
                    out.println("<script>alert('无权删除该记录');history.go(-1);</script>"); return;
                }
                int status = rs.getInt("lwmsubmitstatus");
                rs.close(); checkStmt.close();
                if (status == 2) {
                    conn.close();
                    out.println("<script>alert('该试卷已批阅，无法删除');history.go(-1);</script>"); return;
                }
            }

            // Delete in order: scores → answers → record
            conn.createStatement().executeUpdate("DELETE FROM lwmexamscore WHERE lwmrecordid = " + recordId);
            conn.createStatement().executeUpdate("DELETE FROM lwmstudentanswer WHERE lwmrecordid = " + recordId);
            conn.createStatement().executeUpdate("DELETE FROM lwmexamrecord WHERE lwmrecordid = " + recordId);
            conn.close();

            String redirect = teacher != null ? "lwmQueryExamRecords" : "lwmstudent_main.jsp";
            out.println("<script>alert('删除成功');location.href='" + redirect + "';</script>");
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('删除失败');history.go(-1);</script>");
        }
    }
}
