package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmCourseArrangeDAO;
import com.example.lwmexam.entity.lwmexam.lwmstudentcourseteacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/lwmAddsourse")
public class lwmAddsourse extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");
        response.setContentType("text/html;charset=utf-8");

        // 接收表单参数
        String lwmclassname = request.getParameter("lwmclassname");
        int lwmsubjectid = Integer.parseInt(request.getParameter("lwmsubjectid"));
        int lwmteacherid = Integer.parseInt(request.getParameter("lwmteacherid"));
        String lwmsemester = request.getParameter("lwmsemester");

        // 封装实体类
        lwmstudentcourseteacher sct = new lwmstudentcourseteacher();
        sct.setLwmclassname(lwmclassname);
        sct.setLwmsubjectid(lwmsubjectid);
        sct.setLwmteacherid(lwmteacherid);
        sct.setLwmsemester(lwmsemester);

        // 调用DAO添加
        lwmCourseArrangeDAO sctDao = new lwmCourseArrangeDAO();
        PrintWriter out = response.getWriter();

        // 检查同一班级同一课程同一学期是否已排课
        if (sctDao.lwmExistArrange(lwmclassname, lwmsubjectid, lwmsemester)) {
            out.println("<script>alert('该班级本课程在当前学期已安排教师，请重新选择');history.back();</script>");
            return;
        }

        int res = sctDao.lwmAddSct(sct);

        if(res > 0){
            out.println("<script>alert('排课添加成功');location.href='lwmcourse_xx';</script>");
        }else{
            out.println("<script>alert('添加重复课程，请重新选择');history.back();</script>");
        }
    }
}