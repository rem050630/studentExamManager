package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmsubjectDAO;
import com.example.lwmexam.entity.lwmexam.lwmSubject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/lwmUpdatesubject")
public class lwmUpdatesubject extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 获取课程ID
        int id = Integer.parseInt(request.getParameter("id"));

        lwmsubjectDAO sdao = new lwmsubjectDAO();
        lwmSubject subject = sdao.lwmQuerySubjectById(id);

        request.setAttribute("subject", subject);
        request.getRequestDispatcher("lwmupdatesubject.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");

        int lwmsubjectid = Integer.parseInt(request.getParameter("lwmsubjectid"));
        String lwmsubjectname = request.getParameter("lwmsubjectname");
        String lwmsubjectdesc = request.getParameter("lwmsubjectdesc");
        int lwmsubjectscore = Integer.parseInt(request.getParameter("lwmsubjectscore"));
        String lwmterm = request.getParameter("lwmterm");

        // 封装课程对象
        lwmSubject subject = new lwmSubject();
        subject.setLwmsubjectid(lwmsubjectid);
        subject.setLwmsubjectname(lwmsubjectname);
        subject.setLwmsubjectdesc(lwmsubjectdesc);
        subject.setLwmsubjectscore(lwmsubjectscore);
        subject.setLwmterm(lwmterm);

        // 调用DAO更新
        lwmsubjectDAO sdao = new lwmsubjectDAO();
        int res = sdao.lwmUpdateSubject(subject);

        if (res > 0) {
            response.setContentType("text/html;charset=utf-8");
            PrintWriter out = response.getWriter();
            out.println("<script>alert('修改成功');location.href='lwmUpdatesubject?id="+subject.getLwmsubjectid()+"';</script>");
        } else {
            response.setContentType("text/html;charset=utf-8");
            PrintWriter out = response.getWriter();
            out.println("<script>alert('课程信息修改失败！');history.go(-1);</script>");
        }
    }
}