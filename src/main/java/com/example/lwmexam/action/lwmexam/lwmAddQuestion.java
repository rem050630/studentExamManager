package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmquestionDAO;
import com.example.lwmexam.entity.lwmexam.lwmExamQuestion;
import com.example.lwmexam.entity.lwmexam.lwmTeacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/lwmAddQuestion")
public class lwmAddQuestion extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        PrintWriter out = response.getWriter();

        if (teacher == null) {
            out.println("<script>alert('请先登录');location.href='login.jsp';</script>");
            return;
        }

        lwmExamQuestion q = new lwmExamQuestion();
        q.setLwmsubjectid(Integer.parseInt(request.getParameter("lwmsubjectid")));
        q.setLwmquestiontype(request.getParameter("lwmquestiontype"));
        q.setLwmquestioncontent(request.getParameter("lwmquestioncontent"));
        q.setLwmoptiona(request.getParameter("lwmoptiona") != null ? request.getParameter("lwmoptiona") : "");
        q.setLwmoptionb(request.getParameter("lwmoptionb") != null ? request.getParameter("lwmoptionb") : "");
        q.setLwmoptionc(request.getParameter("lwmoptionc") != null ? request.getParameter("lwmoptionc") : "");
        q.setLwmoptiond(request.getParameter("lwmoptiond") != null ? request.getParameter("lwmoptiond") : "");
        q.setLwmcorrectanswer(request.getParameter("lwmcorrectanswer"));

        lwmquestionDAO dao = new lwmquestionDAO();
        int res = dao.lwmAddQuestion(q);
        if (res > 0) {
            out.println("<script>alert('添加成功');location.href='lwmQueryQuestion';</script>");
        } else {
            out.println("<script>alert('添加失败');history.go(-1);</script>");
        }
    }
}
