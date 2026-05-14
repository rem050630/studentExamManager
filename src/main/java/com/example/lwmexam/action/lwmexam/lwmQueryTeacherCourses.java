package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmCourseArrangeDAO;
import com.example.lwmexam.entity.lwmexam.lwmTeacher;
import com.example.lwmexam.entity.lwmexam.lwmstudentcourseteacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/lwmQueryTeacherCourses")
public class lwmQueryTeacherCourses extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");

        if (teacher == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        lwmCourseArrangeDAO dao = new lwmCourseArrangeDAO();
        String keyword = request.getParameter("keyword");
        String sql;
        Object[] params;

        if (keyword != null && !keyword.trim().isEmpty()) {
            String likeKey = "%" + keyword.trim() + "%";
            sql = "SELECT sct.*, sub.lwmsubjectname, tea.lwmteachername " +
                  "FROM lwmstudentcourseteacher sct " +
                  "LEFT JOIN lwmexamsubject sub ON sct.lwmsubjectid = sub.lwmsubjectid " +
                  "LEFT JOIN lwmteacher tea ON sct.lwmteacherid = tea.lwmteacherid " +
                  "WHERE sct.lwmteacherid = ? AND (sct.lwmclassname LIKE ? OR sub.lwmsubjectname LIKE ?)";
            params = new Object[]{teacher.getLwmteacherid(), likeKey, likeKey};
        } else {
            sql = "SELECT sct.*, sub.lwmsubjectname, tea.lwmteachername " +
                  "FROM lwmstudentcourseteacher sct " +
                  "LEFT JOIN lwmexamsubject sub ON sct.lwmsubjectid = sub.lwmsubjectid " +
                  "LEFT JOIN lwmteacher tea ON sct.lwmteacherid = tea.lwmteacherid " +
                  "WHERE sct.lwmteacherid = ?";
            params = new Object[]{teacher.getLwmteacherid()};
        }

        List<lwmstudentcourseteacher> courses = dao.lwmQuerySomeSct(sql, params);
        request.setAttribute("courses", courses);
        request.getRequestDispatcher("lwmteacher_courses.jsp").forward(request, response);
    }
}
