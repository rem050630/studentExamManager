package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmsubjectDAO;
import com.example.lwmexam.entity.lwmexam.lwmSubject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/lwmquerysubject")
public class lwmquerysubject extends HttpServlet {
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

        lwmsubjectDAO dao = new lwmsubjectDAO();
        List<lwmSubject> list = dao.lwmQuerySubjectByMulti(keyword);

        request.setAttribute("someSubject", list);
        request.getRequestDispatcher("lwmsubjectlist.jsp").forward(request, response);
    }
}