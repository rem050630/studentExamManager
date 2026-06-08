package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmKnowledgePointDAO;
import com.example.lwmexam.dao.lwmexam.lwmMistakeBookDAO;
import com.example.lwmexam.entity.lwmexam.lwmKnowledgePoint;
import com.example.lwmexam.entity.lwmexam.lwmMistakeBook;
import com.example.lwmexam.entity.lwmexam.lwmStudent;
import com.example.lwmexam.service.lwmexam.Fpage;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/lwmMistakeBook")
public class lwmMistakeBookAction extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        lwmStudent student = (lwmStudent) session.getAttribute("student");
        if (student == null) { response.sendRedirect("login.jsp"); return; }

        lwmKnowledgePointDAO kpDao = new lwmKnowledgePointDAO();
        lwmMistakeBookDAO mbDao = new lwmMistakeBookDAO();

        String subjectIdStr = request.getParameter("subjectid");
        String kpIdStr = request.getParameter("kpid");
        String reviewStr = request.getParameter("reviewstatus");

        Integer subjectId = (subjectIdStr != null && !subjectIdStr.isEmpty()) ? Integer.parseInt(subjectIdStr) : null;
        Integer kpId = (kpIdStr != null && !kpIdStr.isEmpty()) ? Integer.parseInt(kpIdStr) : null;
        Integer reviewStatus = (reviewStr != null && !reviewStr.isEmpty()) ? Integer.parseInt(reviewStr) : null;

        // Load KPs for dropdown
        List<lwmKnowledgePoint> allKPs = kpDao.queryAll();
        List<lwmKnowledgePoint> filteredKPs = new java.util.ArrayList<>();
        if (subjectId != null) {
            for (lwmKnowledgePoint kp : allKPs) {
                if (kp.getLwmsubjectid() == subjectId) filteredKPs.add(kp);
            }
        }

        // Pagination
        Fpage fp = new Fpage();
        fp.setPageSize(10);
        if (request.getParameter("page") != null) {
            fp.setPageNow(Integer.parseInt(request.getParameter("page")));
        }
        int total = mbDao.countMistakes(student.getLwmstudentid(), subjectId, kpId, reviewStatus);
        fp.setRowCount(total);

        List<lwmMistakeBook> mistakes = mbDao.queryMistakes(
            student.getLwmstudentid(), subjectId, kpId, reviewStatus, fp.getStart(), fp.getPageSize());

        request.setAttribute("mistakes", mistakes);
        request.setAttribute("allKPs", allKPs);
        request.setAttribute("filteredKPs", filteredKPs);
        request.setAttribute("subjectId", subjectIdStr != null ? subjectIdStr : "");
        request.setAttribute("kpId", kpIdStr != null ? kpIdStr : "");
        request.setAttribute("reviewStatus", reviewStr != null ? reviewStr : "");
        request.setAttribute("fp", fp);
        StringBuilder tj = new StringBuilder();
        if (subjectIdStr != null && !subjectIdStr.isEmpty()) tj.append("subjectid=").append(subjectIdStr);
        if (kpIdStr != null && !kpIdStr.isEmpty()) {
            if (tj.length() > 0) tj.append("&");
            tj.append("kpid=").append(kpIdStr);
        }
        if (reviewStr != null && !reviewStr.isEmpty()) {
            if (tj.length() > 0) tj.append("&");
            tj.append("reviewstatus=").append(reviewStr);
        }
        request.setAttribute("tj", tj.toString());
        request.getRequestDispatcher("lwmstudent_mistakebook.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        lwmStudent student = (lwmStudent) session.getAttribute("student");
        if (student == null) { response.sendRedirect("login.jsp"); return; }

        String action = request.getParameter("action");
        int questionId = Integer.parseInt(request.getParameter("questionId"));

        if ("updateStatus".equals(action)) {
            int status = Integer.parseInt(request.getParameter("status"));
            lwmMistakeBookDAO dao = new lwmMistakeBookDAO();
            dao.updateReviewStatus(student.getLwmstudentid(), questionId, status);
            response.sendRedirect("lwmMistakeBook");
        }
    }
}
