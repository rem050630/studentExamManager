package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmCourseArrangeDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/lwmcourseDelete")
public class lwmcourseDelete extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");
        int id = Integer.parseInt(request.getParameter("id"));
        lwmCourseArrangeDAO sctDao = new lwmCourseArrangeDAO();
        int res = sctDao.lwmDeleteSctById(id);

        if(res>0){
            response.setContentType("text/html;charset=utf-8");
            PrintWriter out = response.getWriter();
            out.println("<script>alert('删除成功');location.href='lwmcourse_xx';</script>");
        }else {
            response.setContentType("text/html;charset=utf-8");
            PrintWriter out = response.getWriter();
            out.println("<script>alert('删除失败');history.go(-1);</script>");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }
}