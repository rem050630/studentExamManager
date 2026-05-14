package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmCourseArrangeDAO;
import com.example.lwmexam.entity.lwmexam.lwmstudentcourseteacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/lwmquerystuentcourseteacher")
public class lwmquerystuentcourseteacher extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // 获取关键字
        String keyword = request.getParameter("keyword");

        // 空值安全处理
        if (keyword == null) keyword = "";

        lwmCourseArrangeDAO dao = new lwmCourseArrangeDAO();
        List<lwmstudentcourseteacher> list;

        // 关键字为空 → 查询全部
        if (keyword.trim().isEmpty()) {
            list = dao.lwmQueryAllSct();
        } else {
            list = dao.lwmSearchArrange(keyword);
        }

        // 放入数据
        request.setAttribute("someCourse", list);

        // 跳转到你的排课列表页面（确认这里是你的真实JSP文件名）
        request.getRequestDispatcher("lwmcourselist.jsp").forward(request, response);
    }
}