package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmsubjectDAO;
import com.example.lwmexam.entity.lwmexam.lwmSubject;
import com.example.lwmexam.service.lwmexam.Fpage;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/lwmsubject_xx")
public class lwmsubject_xx extends HttpServlet {
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

        // 创建课程DAO对象
        lwmsubjectDAO subjectDao = new lwmsubjectDAO();

        // 分页处理
        Fpage fp = new Fpage();
        if (request.getParameter("page") != null) {
            fp.setPageNow(Integer.parseInt(request.getParameter("page")));
        }

        // 设置分页查询的总记录数（按课程名称、学期搜索）
        fp.setFpage("select count(*) from lwmexamsubject where lwmsubjectname like '%" + tj + "%' " +
                "or lwmterm like '%" + tj + "%'", new Object[]{});

        // 查询课程列表（支持搜索，最新添加的排在前面）
        List<lwmSubject> someSubject = subjectDao.lwmQuerySomeSubject(
                "select * from lwmexamsubject where lwmsubjectname like '%" + tj + "%' " +
                        "or lwmterm like '%" + tj + "%' ORDER BY lwmsubjectid DESC limit ?,?",
                new Object[]{fp.getStart(), fp.getPageSize()});

        // 将数据存入session
        request.getSession().setAttribute("someSubject", someSubject);
        request.getSession().setAttribute("fp", fp);
        request.getSession().setAttribute("tj", tj);
        request.getSession().setAttribute("pageUrl", "lwmsubject_xx");

        // 跳转到课程列表页面
        response.sendRedirect("lwmsubjectlist.jsp");
    }
}