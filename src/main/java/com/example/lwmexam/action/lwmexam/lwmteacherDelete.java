package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmTeacherDAO;
import com.example.lwmexam.dao.lwmexam.lwmstudentDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/lwmteacherDelete")
public class lwmteacherDelete extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        lwmTeacherDAO hdao = new lwmTeacherDAO();
        int res = hdao.lwmDeleteTeacherById(id);
        if(res>0){
            response.setContentType("text/html;charset=utf-8");
            PrintWriter out = response.getWriter();
            out.println("<script>alert('删除成功');location.href='lwmteacher_xx';</script>");
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