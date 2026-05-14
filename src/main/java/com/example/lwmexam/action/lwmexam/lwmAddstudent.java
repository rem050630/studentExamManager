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

@WebServlet("/lwmAddstudent")
public class lwmAddstudent extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");
        String studentno = request.getParameter("lwmstudentno");
        String studentname = request.getParameter("lwmstudentname");
        String studentpassword = request.getParameter("lwmstudentpassword");
        String gender = request.getParameter("lwmgender");
        String grade = request.getParameter("lwmgrade");
        String major = request.getParameter("lwmmajor");
        String classname = request.getParameter("lwmclassname");

        lwmstudentDAO studentDao = new lwmstudentDAO();
        lwmStudent student = new lwmStudent();
        student.setLwmstudentno(studentno);
        student.setLwmstudentname(studentname);
        student.setLwmstudentpassword(studentpassword);
        student.setLwmgender(gender);
        student.setLwmgrade(grade);
        student.setLwmmajor(major);
        student.setLwmclassname(classname);
        int res = studentDao.lwmAddStudent(student);
        if (res > 0) {
            response.setContentType("text/html;charset=utf-8");
            PrintWriter out = response.getWriter();
            out.println("<script>alert('添加成功');location.href='lwmstudent_xx';</script>");
        } else {
            response.setContentType("text/html;charset=utf-8");
            PrintWriter out = response.getWriter();
            out.println("<script>alert('添加失败，请检查学号是否已存在');history.go(-1);</script>");
        }
    }
}