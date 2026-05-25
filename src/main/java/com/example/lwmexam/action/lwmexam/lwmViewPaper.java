package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmquestionDAO;
import com.example.lwmexam.dao.lwmexam.lwmpaperDAO;
import com.example.lwmexam.entity.lwmexam.lwmExamPaper;
import com.example.lwmexam.entity.lwmexam.lwmExamQuestion;
import com.example.lwmexam.entity.lwmexam.lwmTeacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

@WebServlet("/lwmViewPaper")
public class lwmViewPaper extends HttpServlet {
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
            response.getWriter().println("<script>alert('试卷不存在');history.go(-1);</script>");
            return;
        }

        lwmquestionDAO qDao = new lwmquestionDAO();
        List<Integer> questionIds = dao.lwmGetPaperQuestionIds(paperId);
        List<lwmExamQuestion> questions = new ArrayList<>();
        for (int id : questionIds) {
            lwmExamQuestion q = qDao.lwmQueryById(id);
            if (q != null) questions.add(q);
        }
        questions.sort(Comparator.comparingInt(q -> {
            switch (q.getLwmquestiontype()) {
                case "单选题": return 1;
                case "多选题": return 2;
                case "判断题": return 3;
                case "简答题": return 4;
                default: return 5;
            }
        }));

        request.setAttribute("paper", paper);
        request.setAttribute("questions", questions);
        request.getRequestDispatcher("lwmteacher_paper_view.jsp").forward(request, response);
    }
}
