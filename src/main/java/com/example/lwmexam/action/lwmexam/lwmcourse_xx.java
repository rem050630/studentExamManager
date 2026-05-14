package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmCourseArrangeDAO;
import com.example.lwmexam.entity.lwmexam.lwmstudentcourseteacher;
import com.example.lwmexam.service.lwmexam.Fpage;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/lwmcourse_xx")
public class lwmcourse_xx extends HttpServlet {
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

        // 创建排课DAO对象
        lwmCourseArrangeDAO sctDao = new lwmCourseArrangeDAO();

        // 分页处理
        Fpage fp = new Fpage();
        if (request.getParameter("page") != null) {
            fp.setPageNow(Integer.parseInt(request.getParameter("page")));
        }

        // 设置分页查询的总记录数（支持按班级、学期搜索）
        fp.setFpage("select count(*) from lwmstudentcourseteacher where lwmclassname like '%" + tj + "%' " +
                "or lwmsemester like '%" + tj + "%' ", new Object[]{});

        // 查询排课列表（支持搜索）
        // 查询排课列表（支持搜索 + 三表联查）
        List<lwmstudentcourseteacher> someCourse = sctDao.lwmQuerySomeSct(
                "SELECT sct.*, sub.lwmsubjectname, tea.lwmteachername " +
                        "FROM lwmstudentcourseteacher sct " +
                        "LEFT JOIN lwmexamsubject sub ON sct.lwmsubjectid = sub.lwmsubjectid " +
                        "LEFT JOIN lwmteacher tea ON sct.lwmteacherid = tea.lwmteacherid " +
                        "WHERE lwmclassname LIKE ? OR lwmsemester LIKE ? " +
                        "LIMIT ?,?",
                new Object[]{
                        "%" + tj + "%",
                        "%" + tj + "%",
                        fp.getStart(),
                        fp.getPageSize()
                }
        );

        // 将数据存入session
        request.getSession().setAttribute("someCourse", someCourse);
        request.getSession().setAttribute("fp", fp);
        request.getSession().setAttribute("tj", tj);
        request.getSession().setAttribute("pageUrl", "lwmcourse_xx");

        // 跳转到排课列表页面
        response.sendRedirect("lwmcourselist.jsp");
    }
}