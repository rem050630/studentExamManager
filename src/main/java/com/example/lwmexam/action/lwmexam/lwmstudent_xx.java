package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmstudentDAO;
import com.example.lwmexam.entity.lwmexam.lwmStudent;
import com.example.lwmexam.service.lwmexam.Fpage;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/lwmstudent_xx")
public class lwmstudent_xx extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");

        // 获取搜索条件
        String tj = "";
        if (request.getParameter("tj") != null) {
            tj = request.getParameter("tj");
        }

        // 创建学生DAO对象
        lwmstudentDAO studentDao = new lwmstudentDAO();

        // 分页处理
        Fpage fp = new Fpage();
        if (request.getParameter("page") != null) {
            fp.setPageNow(Integer.parseInt(request.getParameter("page")));
        }

        // 设置分页查询的总记录数（支持按学号、姓名、班级、专业等多条件搜索）
        fp.setFpage("select count(*) from lwmstudent where lwmstudentno like '%" + tj + "%' " +
                "or lwmstudentname like '%" + tj + "%' " +
                "or lwmclassname like '%" + tj + "%' " +
                "or lwmmajor like '%" + tj + "%'", new Object[]{});

        // 查询学生列表（支持多条件搜索，最新添加的排在前面）
        List<lwmStudent> someStudent = studentDao.lwmQuerySomeStudent(
                "select * from lwmstudent where lwmstudentno like '%" + tj + "%' " +
                        "or lwmstudentname like '%" + tj + "%' " +
                        "or lwmclassname like '%" + tj + "%' " +
                        "or lwmmajor like '%" + tj + "%' ORDER BY lwmstudentid DESC limit ?,?",
                new Object[]{fp.getStart(), fp.getPageSize()});

        // 将数据存入session
        request.getSession().setAttribute("someStudent", someStudent);
        request.getSession().setAttribute("fp", fp);
        request.getSession().setAttribute("tj", tj);
        request.getSession().setAttribute("pageUrl", "lwmstudent_xx");

        // 跳转到学生列表页面
        response.sendRedirect("lwmstudentlist.jsp");

    }
}