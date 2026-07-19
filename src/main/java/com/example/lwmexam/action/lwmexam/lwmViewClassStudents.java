package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmstudentDAO;
import com.example.lwmexam.entity.lwmexam.lwmStudent;
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
import java.util.List;

@WebServlet("/lwmViewClassStudents")
public class lwmViewClassStudents extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        if (teacher == null) { response.sendRedirect("login.jsp"); return; }

        String classname = request.getParameter("classname");
        String keyword = request.getParameter("keyword");

        lwmstudentDAO dao = new lwmstudentDAO();

        // Pagination
        Fpage fp = new Fpage();
        fp.setPageSize(6);
        if (request.getParameter("page") != null) {
            fp.setPageNow(Integer.parseInt(request.getParameter("page")));
        }

        String where;
        Object[] countParams;
        Object[] queryParams;
        if (keyword != null && !keyword.trim().isEmpty()) {
            String likeKey = "%" + keyword.trim() + "%";
            where = " WHERE lwmclassname = ? AND (lwmstudentno LIKE ? OR lwmstudentname LIKE ?)";
            countParams = new Object[]{classname, likeKey, likeKey};
            queryParams = new Object[]{classname, likeKey, likeKey};
        } else {
            where = " WHERE lwmclassname = ?";
            countParams = new Object[]{classname};
            queryParams = new Object[]{classname};
        }

        fp.setFpage("SELECT COUNT(*) FROM lwmstudent" + where, countParams);

        Object[] pagedParams = new Object[queryParams.length + 2];
        System.arraycopy(queryParams, 0, pagedParams, 0, queryParams.length);
        pagedParams[queryParams.length] = fp.getStart();
        pagedParams[queryParams.length + 1] = fp.getPageSize();

        List<lwmStudent> students = dao.lwmQuerySomeStudent(
            "SELECT * FROM lwmstudent" + where + " LIMIT ?,?", pagedParams);

        // Build tj for pagination links
        StringBuilder tj = new StringBuilder();
        tj.append("classname=").append(URLEncoder.encode(classname, "UTF-8"));
        if (keyword != null && !keyword.trim().isEmpty()) {
            tj.append("&keyword=").append(URLEncoder.encode(keyword.trim(), "UTF-8"));
        }

        request.setAttribute("students", students);
        request.setAttribute("classname", classname);
        request.setAttribute("fp", fp);
        request.setAttribute("pageUrl", "lwmViewClassStudents");
        request.setAttribute("tj", tj.toString());
        request.getRequestDispatcher("lwmteacher_class_students.jsp").forward(request, response);
    }
}
