package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmCourseArrangeDAO;
import com.example.lwmexam.dao.lwmexam.lwmquestionDAO;
import com.example.lwmexam.entity.lwmexam.lwmExamQuestion;
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
import java.util.stream.Collectors;

@WebServlet("/lwmQueryQuestion")
public class lwmQueryQuestion extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");

        if (teacher == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        lwmCourseArrangeDAO arrangeDao = new lwmCourseArrangeDAO();
        List<lwmstudentcourseteacher> courses = arrangeDao.lwmQuerySomeSct(
            "SELECT sct.*, sub.lwmsubjectname, tea.lwmteachername FROM lwmstudentcourseteacher sct LEFT JOIN lwmexamsubject sub ON sct.lwmsubjectid = sub.lwmsubjectid LEFT JOIN lwmteacher tea ON sct.lwmteacherid = tea.lwmteacherid WHERE sct.lwmteacherid = ?",
            new Object[]{teacher.getLwmteacherid()});

        String subjectIds = courses.stream()
            .map(c -> String.valueOf(c.getLwmsubjectid()))
            .distinct()
            .collect(Collectors.joining(","));

        String questiontype = request.getParameter("questiontype");
        String keyword = request.getParameter("keyword");

        lwmquestionDAO dao = new lwmquestionDAO();
        List<lwmExamQuestion> questions = dao.lwmQueryBySubjectType(
            subjectIds.isEmpty() ? null : subjectIds, questiontype, keyword);

        request.setAttribute("questions", questions);
        request.setAttribute("courses", courses);
        request.setAttribute("questiontype", questiontype);
        request.setAttribute("keyword", keyword);
        request.getRequestDispatcher("lwmteacher_question_list.jsp").forward(request, response);
    }
}
