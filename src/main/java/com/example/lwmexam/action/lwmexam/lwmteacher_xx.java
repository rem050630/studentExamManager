package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmTeacherDAO;
import com.example.lwmexam.entity.lwmexam.lwmTeacher;
import com.example.lwmexam.service.lwmexam.Fpage;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/lwmteacher_xx")
public class lwmteacher_xx extends HttpServlet {
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

        // 创建教师DAO对象
        lwmTeacherDAO teacherDao = new lwmTeacherDAO();

        // 分页处理
        Fpage fp = new Fpage();
        if (request.getParameter("page") != null) {
            fp.setPageNow(Integer.parseInt(request.getParameter("page")));
        }

        // 设置分页查询的总记录数（按工号、姓名搜索）
        fp.setFpage("select count(*) from lwmteacher where lwmteacherno like '%" + tj + "%' " +
                "or lwmteachername like '%" + tj + "%' ", new Object[]{});

        // 查询教师列表（最新添加的排在前面）
        List<lwmTeacher> someTeacher = teacherDao.lwmQuerySomeTeacher(
                "select * from lwmteacher where lwmteacherno like '%" + tj + "%' " +
                        "or lwmteachername like '%" + tj + "%' ORDER BY lwmteacherid DESC limit ?,?",
                new Object[]{fp.getStart(), fp.getPageSize()});

        // 将数据存入session
        request.getSession().setAttribute("someTeacher", someTeacher);
        request.getSession().setAttribute("fp", fp);
        request.getSession().setAttribute("tj", tj);
        request.getSession().setAttribute("pageUrl", "lwmteacher_xx");

        // 跳转到教师列表页面
        response.sendRedirect("lwmteacherlist.jsp");

    }
}