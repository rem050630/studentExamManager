package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmTeacherDAO;
import com.example.lwmexam.entity.lwmexam.lwmTeacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/lwmUpdateteacher")
public class lwmUpdateteacher extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 这里必须和页面传参一致：lwmteacherid
        int id = Integer.parseInt(request.getParameter("id"));

        lwmTeacherDAO hdao = new lwmTeacherDAO();
        lwmTeacher teacher = hdao.lwmQueryTeacherById(id);

        request.setAttribute("teacher", teacher);
        request.getRequestDispatcher("lwmupdateteacher.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");

        int lwmteacherid = Integer.parseInt(request.getParameter("lwmteacherid"));

        String lwmteacherno = request.getParameter("lwmteacherno");
        String lwmteachername = request.getParameter("lwmteachername");
        String lwmteacherpassword = request.getParameter("lwmteacherpassword");
        String lwmteachergender = request.getParameter("lwmteachergender");
        String lwmteacherphone = request.getParameter("lwmteacherphone");

        // 封装教师对象
        lwmTeacher teacher = new lwmTeacher();
        // 必须设置ID！！！
        teacher.setLwmteacherid(lwmteacherid);

        teacher.setLwmteacherno(lwmteacherno);
        teacher.setLwmteachername(lwmteachername);
        teacher.setLwmteacherpassword(lwmteacherpassword);
        teacher.setLwmteachergender(lwmteachergender);
        teacher.setLwmteacherphone(lwmteacherphone);

        // 调用DAO更新
        lwmTeacherDAO hdao = new lwmTeacherDAO();
        int res = hdao.lwmUpdateTeacher(teacher);

        if (res > 0) {
            response.setContentType("text/html;charset=utf-8");
            PrintWriter out = response.getWriter();
            out.println("<script>alert('修改成功');location.href='lwmUpdateteacher?id="+teacher.getLwmteacherid()+"';</script>");

        } else {
            response.setContentType("text/html;charset=utf-8");
            PrintWriter out = response.getWriter();
            out.println("<script>alert('教师信息修改失败！');history.go(-1);</script>");
        }
    }
}