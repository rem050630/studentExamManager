package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmpaperDAO;
import com.example.lwmexam.dao.lwmexam.lwmquestionDAO;
import com.example.lwmexam.entity.lwmexam.lwmExamPaper;
import com.example.lwmexam.entity.lwmexam.lwmExamQuestion;
import com.example.lwmexam.entity.lwmexam.lwmStudent;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/lwmTakeExam")
public class lwmTakeExam extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        lwmStudent student = (lwmStudent) session.getAttribute("student");
        if (student == null) { response.sendRedirect("login.jsp"); return; }

        int paperId = Integer.parseInt(request.getParameter("paperId"));
        lwmpaperDAO pDao = new lwmpaperDAO();
        lwmExamPaper paper = pDao.lwmQueryPaperById(paperId);

        // Check if student's class is among the published classes (comma-separated)
        boolean classMatch = false;
        if (paper != null && paper.getLwmclassname() != null) {
            for (String cls : paper.getLwmclassname().split(",")) {
                if (cls.trim().equals(student.getLwmclassname())) { classMatch = true; break; }
            }
        }
        if (paper == null || !classMatch) {
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<script>alert('试卷不存在或不可访问');history.go(-1);</script>");
            return;
        }

        lwmquestionDAO qDao = new lwmquestionDAO();
        List<Integer> qIds = pDao.lwmGetPaperQuestionIds(paperId);
        List<lwmExamQuestion> questions = new ArrayList<>();
        for (int qId : qIds) {
            lwmExamQuestion q = qDao.lwmQueryById(qId);
            if (q != null) questions.add(q);
        }

        request.setAttribute("paper", paper);
        request.setAttribute("questions", questions);
        request.getRequestDispatcher("lwmstudent_take_exam.jsp").forward(request, response);
    }
}
