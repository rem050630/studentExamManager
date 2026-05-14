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

@WebServlet("/lwmUpdatePaper")
public class lwmUpdatePaper extends HttpServlet {
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
            response.getWriter().println("<script>alert('试卷不存在或无权修改');history.go(-1);</script>");
            return;
        }
        request.setAttribute("paper", paper);
        request.setAttribute("hasSubmit", dao.hasSubmitRecord(paperId));
        request.getRequestDispatcher("lwmteacher_paper_edit.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        int paperId = Integer.parseInt(request.getParameter("lwmpaperid"));
        lwmpaperDAO dao = new lwmpaperDAO();

        lwmExamPaper paper = new lwmExamPaper();
        paper.setLwmpaperid(paperId);
        paper.setLwmpapername(request.getParameter("lwmpapername"));
        paper.setLwmsubjectid(Integer.parseInt(request.getParameter("lwmsubjectid")));
        paper.setLwmclassname(request.getParameter("lwmclassname"));
        paper.setLwmstarttime(request.getParameter("lwmstarttime"));
        paper.setLwmendtime(request.getParameter("lwmendtime"));
        paper.setLwmexamtime(Integer.parseInt(request.getParameter("lwmexamtime")));
        paper.setLwmexamsore(Integer.parseInt(request.getParameter("lwmexamsore")));

        int res = dao.lwmUpdatePaper(paper);
        if (res > 0) {
            out.println("<script>alert('修改成功');location.href='lwmQueryPaper';</script>");
        } else {
            out.println("<script>alert('修改失败');history.go(-1);</script>");
        }
    }
}
