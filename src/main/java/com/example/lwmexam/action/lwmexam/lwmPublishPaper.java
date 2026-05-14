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
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@WebServlet("/lwmPublishPaper")
public class lwmPublishPaper extends HttpServlet {

    // GET: Load the publish page with paper info and class checkboxes
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        if (teacher == null) { response.sendRedirect("login.jsp"); return; }

        int paperId = Integer.parseInt(request.getParameter("id"));
        lwmpaperDAO dao = new lwmpaperDAO();
        lwmExamPaper paper = dao.lwmQueryPaperById(paperId);
        if (paper == null || paper.getLwmteacherid() != teacher.getLwmteacherid()) {
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<script>alert('试卷不存在或无权操作');history.go(-1);</script>");
            return;
        }

        // Load teacher's assigned classes from lwmstudentcourseteacher
        List<String> teacherClasses = new ArrayList<>();
        // Parse already-published classes
        Set<String> publishedClasses = new HashSet<>();
        String currentClasses = paper.getLwmclassname();
        if (currentClasses != null && !currentClasses.isEmpty()) {
            publishedClasses.addAll(Arrays.asList(currentClasses.split(",")));
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8",
                "root", "123456");
            PreparedStatement pstmt = conn.prepareStatement(
                "SELECT DISTINCT lwmclassname FROM lwmstudentcourseteacher WHERE lwmteacherid = ? ORDER BY lwmclassname");
            pstmt.setInt(1, teacher.getLwmteacherid());
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) teacherClasses.add(rs.getString("lwmclassname"));
            rs.close(); pstmt.close(); conn.close();
        } catch (Exception e) { e.printStackTrace(); }

        request.setAttribute("paper", paper);
        request.setAttribute("teacherClasses", teacherClasses);
        request.setAttribute("publishedClasses", publishedClasses);
        request.getRequestDispatcher("lwmteacher_paper_publish.jsp").forward(request, response);
    }

    // POST: Save published classes
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        PrintWriter out = response.getWriter();
        if (teacher == null) { out.println("<script>alert('请先登录');location.href='login.jsp';</script>"); return; }

        int paperId = Integer.parseInt(request.getParameter("paperId"));
        String[] selectedClasses = request.getParameterValues("classes");
        String classname = "";
        if (selectedClasses != null && selectedClasses.length > 0) {
            classname = String.join(",", selectedClasses);
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8",
                "root", "123456");
            PreparedStatement pstmt = conn.prepareStatement(
                "UPDATE lwmexampaper SET lwmclassname = ? WHERE lwmpaperid = ? AND lwmteacherid = ?");
            pstmt.setString(1, classname);
            pstmt.setInt(2, paperId);
            pstmt.setInt(3, teacher.getLwmteacherid());
            int res = pstmt.executeUpdate();
            pstmt.close(); conn.close();
            if (res > 0) {
                out.println("<script>alert('发布成功');location.href='lwmQueryPaper';</script>");
            } else {
                out.println("<script>alert('发布失败');history.go(-1);</script>");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('发布失败');history.go(-1);</script>");
        }
    }
}
