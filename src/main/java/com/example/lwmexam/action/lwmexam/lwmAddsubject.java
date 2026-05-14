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

@WebServlet("/lwmAddsubject")
public class lwmAddsubject extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");

        // 获取课程表单参数（和你的实体类一一对应）
        String subjectname = request.getParameter("lwmsubjectname");
        String subjectdesc = request.getParameter("lwmsubjectdesc");
        String subjectscore = request.getParameter("lwmsubjectscore");
        String term = request.getParameter("lwmterm");

        // 封装课程对象
        lwmsubjectDAO subjectDao = new lwmsubjectDAO();
        lwmSubject subject = new lwmSubject();
        subject.setLwmsubjectname(subjectname);
        subject.setLwmsubjectdesc(subjectdesc);
        subject.setLwmsubjectscore(Integer.valueOf(subjectscore));
        subject.setLwmterm(term);

        // 调用DAO添加
        int res = subjectDao.lwmAddSubject(subject);
        if (res > 0) {
            response.setContentType("text/html;charset=utf-8");
            PrintWriter out = response.getWriter();
            out.println("<script>alert('添加成功');location.href='lwmaddsubject.jsp';</script>");
        } else {
            response.setContentType("text/html;charset=utf-8");
            PrintWriter out = response.getWriter();
            out.println("<script>alert('添加失败，请检查数据');history.go(-1);</script>");
        }
    }
}