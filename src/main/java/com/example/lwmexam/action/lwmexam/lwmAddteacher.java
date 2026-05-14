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

@WebServlet("/lwmAddteacher")
public class lwmAddteacher extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");

        // 获取教师表单字段
        String teacherno = request.getParameter("lwmteacherno");
        String teachername = request.getParameter("lwmteachername");
        String teacherpassword = request.getParameter("lwmteacherpassword");
        String teachergender = request.getParameter("lwmteachergender");
        String teacherphone = request.getParameter("lwmteacherphone");

        // 创建DAO与实体对象
        lwmTeacherDAO teacherDao = new lwmTeacherDAO();
        lwmTeacher teacher = new lwmTeacher();

        // 设置属性
        teacher.setLwmteacherno(teacherno);
        teacher.setLwmteachername(teachername);
        teacher.setLwmteacherpassword(teacherpassword);
        teacher.setLwmteachergender(teachergender);
        teacher.setLwmteacherphone(teacherphone);

        // 执行添加
        int res = teacherDao.lwmAddTeacher(teacher);

        // 返回结果
        if (res > 0) {
            response.setContentType("text/html;charset=utf-8");
            PrintWriter out = response.getWriter();
            out.println("<script>alert('添加成功');location.href='lwmaddteacher.jsp';</script>");
        } else {
            response.setContentType("text/html;charset=utf-8");
            PrintWriter out = response.getWriter();
            out.println("<script>alert('添加失败，请检查工号是否已存在');history.go(-1);</script>");
        }
    }
}