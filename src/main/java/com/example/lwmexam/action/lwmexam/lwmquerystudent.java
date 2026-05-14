package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmstudentDAO;
import com.example.lwmexam.entity.lwmexam.lwmStudent;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/lwmquerystudent")
public class lwmquerystudent extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // 接收统一关键字
        String keyword = request.getParameter("keyword");
        if (keyword == null) keyword = "";

        lwmstudentDAO dao = new lwmstudentDAO();
        List<lwmStudent> list = dao.lwmSearchStudent(keyword);

        request.setAttribute("someStudent", list);
        request.getRequestDispatcher("lwmstudentlist.jsp").forward(request, response);
    }
}