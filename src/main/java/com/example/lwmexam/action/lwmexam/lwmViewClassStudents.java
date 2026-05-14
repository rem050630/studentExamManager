package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmstudentDAO;
import com.example.lwmexam.entity.lwmexam.lwmStudent;
import com.example.lwmexam.entity.lwmexam.lwmTeacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
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
        List<lwmStudent> students;
        if (keyword != null && !keyword.trim().isEmpty()) {
            students = dao.lwmQuerySomeStudent(
                "SELECT * FROM lwmstudent WHERE lwmclassname = ? AND (lwmstudentno LIKE ? OR lwmstudentname LIKE ?)",
                new Object[]{classname, "%" + keyword.trim() + "%", "%" + keyword.trim() + "%"});
        } else {
            students = dao.lwmQuerySomeStudent(
                "SELECT * FROM lwmstudent WHERE lwmclassname = ?",
                new Object[]{classname});
        }

        request.setAttribute("students", students);
        request.setAttribute("classname", classname);
        request.getRequestDispatcher("lwmteacher_class_students.jsp").forward(request, response);
    }
}
