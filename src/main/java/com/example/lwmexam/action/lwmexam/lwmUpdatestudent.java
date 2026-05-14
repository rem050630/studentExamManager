package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmstudentDAO;
import com.example.lwmexam.entity.lwmexam.lwmStudent;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/lwmUpdatestudent")
public class lwmUpdatestudent extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 这里必须和页面传参一致：lwmstudentid
        int id = Integer.parseInt(request.getParameter("id"));

        lwmstudentDAO hdao = new lwmstudentDAO();
        lwmStudent student = hdao.lwmQueryStudentById(id);

        request.setAttribute("student", student);
        request.getRequestDispatcher("lwmupdatestudent.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");

        int lwmstudentid = Integer.parseInt(request.getParameter("lwmstudentid"));

        String lwmstudentno = request.getParameter("lwmstudentno");
        String lwmstudentname = request.getParameter("lwmstudentname");
        String lwmstudentpassword = request.getParameter("lwmstudentpassword");
        String lwmgender = request.getParameter("lwmgender");
        String lwmgrade = request.getParameter("lwmgrade");
        String lwmmajor = request.getParameter("lwmmajor");
        String lwmclassname = request.getParameter("lwmclassname");

        // 封装学生对象
        lwmStudent student = new lwmStudent();
        student.setLwmstudentid(lwmstudentid);

        student.setLwmstudentno(lwmstudentno);
        student.setLwmstudentname(lwmstudentname);
        student.setLwmstudentpassword(lwmstudentpassword);
        student.setLwmgender(lwmgender);
        student.setLwmgrade(lwmgrade);
        student.setLwmmajor(lwmmajor);
        student.setLwmclassname(lwmclassname);

        // 调用DAO更新
        lwmstudentDAO hdao = new lwmstudentDAO();
        int res = hdao.lwmUpdateStudent(student);

        if (res > 0) {
            response.setContentType("text/html;charset=utf-8");
            PrintWriter out = response.getWriter();
            out.println("<script>alert('修改成功');location.href='lwmUpdatestudent?id="+student.getLwmstudentid()+"';</script>");

        } else {
            response.setContentType("text/html;charset=utf-8");
            PrintWriter out = response.getWriter();
            out.println("<script>alert('学生信息修改失败！');history.go(-1);</script>");
        }
    }
}