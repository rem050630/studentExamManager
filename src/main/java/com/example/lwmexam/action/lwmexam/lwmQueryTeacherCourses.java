package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmCourseArrangeDAO;
import com.example.lwmexam.entity.lwmexam.lwmTeacher;
import com.example.lwmexam.entity.lwmexam.lwmstudentcourseteacher;
import com.example.lwmexam.service.lwmexam.Fpage;

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
        String where;
        Object[] countParams;
        Object[] queryParams;

        if (keyword != null && !keyword.trim().isEmpty()) {
            String likeKey = "%" + keyword.trim() + "%";
            where = " WHERE sct.lwmteacherid = ? AND (sct.lwmclassname LIKE ? OR sub.lwmsubjectname LIKE ?)";
            countParams = new Object[]{teacher.getLwmteacherid(), likeKey, likeKey};
            queryParams = new Object[]{teacher.getLwmteacherid(), likeKey, likeKey};
        } else {
            where = " WHERE sct.lwmteacherid = ?";
            countParams = new Object[]{teacher.getLwmteacherid()};
            queryParams = new Object[]{teacher.getLwmteacherid()};
        }

        // Pagination
        Fpage fp = new Fpage();
        fp.setPageSize(6);
        if (request.getParameter("page") != null) {
            fp.setPageNow(Integer.parseInt(request.getParameter("page")));
        }
        fp.setFpage("SELECT COUNT(*) FROM lwmstudentcourseteacher sct " +
                     "LEFT JOIN lwmexamsubject sub ON sct.lwmsubjectid = sub.lwmsubjectid" + where, countParams);

        String sql = "SELECT sct.*, sub.lwmsubjectname, tea.lwmteachername " +
                     "FROM lwmstudentcourseteacher sct " +
                     "LEFT JOIN lwmexamsubject sub ON sct.lwmsubjectid = sub.lwmsubjectid " +
                     "LEFT JOIN lwmteacher tea ON sct.lwmteacherid = tea.lwmteacherid" + where +
                     " LIMIT ?,?";
        Object[] pagedParams = new Object[queryParams.length + 2];
        System.arraycopy(queryParams, 0, pagedParams, 0, queryParams.length);
        pagedParams[queryParams.length] = fp.getStart();
        pagedParams[queryParams.length + 1] = fp.getPageSize();

        List<lwmstudentcourseteacher> courses = dao.lwmQuerySomeSct(sql, pagedParams);
        request.setAttribute("courses", courses);
        request.setAttribute("fp", fp);
        request.setAttribute("pageUrl", "lwmQueryTeacherCourses");
        request.setAttribute("tj", keyword != null && !keyword.trim().isEmpty() ? "keyword=" + java.net.URLEncoder.encode(keyword.trim(), "UTF-8") : "");
        request.getRequestDispatcher("lwmteacher_courses.jsp").forward(request, response);
    }
}
