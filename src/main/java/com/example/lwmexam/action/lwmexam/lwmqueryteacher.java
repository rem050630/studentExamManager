package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmTeacherDAO;
import com.example.lwmexam.entity.lwmexam.lwmTeacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/lwmqueryteacher")
public class lwmqueryteacher extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // 统一关键字
        String keyword = request.getParameter("keyword");
        if (keyword == null) keyword = "";

        lwmTeacherDAO dao = new lwmTeacherDAO();
        List<lwmTeacher> list = dao.lwmQueryTeacherByMulti(keyword);

        request.setAttribute("someTeacher", list);
        request.getRequestDispatcher("lwmteacherlist.jsp").forward(request, response);
    }
}