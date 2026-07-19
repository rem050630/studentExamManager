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
import com.example.lwmexam.service.lwmexam.Fpage;
import java.net.URLEncoder;
import java.util.ArrayList;
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

        // Build unique subject list for dropdown (id and name)
        java.util.LinkedHashMap<String, String> subjectMap = new java.util.LinkedHashMap<>();
        for (lwmstudentcourseteacher c : courses) {
            subjectMap.putIfAbsent(String.valueOf(c.getLwmsubjectid()), c.getLwmsubjectname());
        }
        List<String[]> subjectList = new ArrayList<>();
        for (java.util.Map.Entry<String, String> e : subjectMap.entrySet()) {
            subjectList.add(new String[]{e.getKey(), e.getValue()});
        }

        String questiontype = request.getParameter("questiontype");
        String keyword = request.getParameter("keyword");
        String selectedSubjectId = request.getParameter("subjectid");

        // If a specific subject is selected, use it; otherwise use all teacher's subjects
        String filterSubjectIds = (selectedSubjectId != null && !selectedSubjectId.isEmpty())
            ? selectedSubjectId : subjectIds;

        lwmquestionDAO dao = new lwmquestionDAO();

        // Pagination
        Fpage fp = new Fpage();
        fp.setPageSize(6);
        if (request.getParameter("page") != null) {
            fp.setPageNow(Integer.parseInt(request.getParameter("page")));
        }
        String filterSubj = (filterSubjectIds != null && !filterSubjectIds.isEmpty()) ? filterSubjectIds : null;
        int total = dao.lwmCountByFilters(filterSubj, questiontype, keyword);
        fp.setRowCount(total);

        List<lwmExamQuestion> questions = dao.lwmQueryBySubjectTypePaged(
            filterSubj, questiontype, keyword, fp.getStart(), fp.getPageSize());

        // Build tj string for pagination links
        StringBuilder tj = new StringBuilder();
        if (selectedSubjectId != null && !selectedSubjectId.isEmpty())
            tj.append("subjectid=").append(selectedSubjectId);
        if (questiontype != null && !questiontype.isEmpty()) {
            if (tj.length() > 0) tj.append("&");
            tj.append("questiontype=").append(questiontype);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            if (tj.length() > 0) tj.append("&");
            tj.append("keyword=").append(URLEncoder.encode(keyword, "UTF-8"));
        }

        request.setAttribute("questions", questions);
        request.setAttribute("courses", courses);
        request.setAttribute("subjectList", subjectList);
        request.setAttribute("questiontype", questiontype);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedSubjectId", selectedSubjectId != null ? selectedSubjectId : "");
        request.setAttribute("fp", fp);
        request.setAttribute("pageUrl", "lwmQueryQuestion");
        request.setAttribute("tj", tj.toString());
        request.getRequestDispatcher("lwmteacher_question_list.jsp").forward(request, response);
    }
}
