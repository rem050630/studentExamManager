package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.entity.lwmexam.lwmAdmin;
import com.example.lwmexam.entity.lwmexam.lwmStudent;
import com.example.lwmexam.entity.lwmexam.lwmTeacher;
import com.example.lwmexam.service.lwmexam.MysqlConn;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.ResultSet;

@WebServlet("/lwmLogin")
public class lwmLogin extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String account = request.getParameter("account");
        String password = request.getParameter("password");
        String role = request.getParameter("role"); // 获取登录角色：admin, student, teacher

        MysqlConn db = new MysqlConn();
        PrintWriter out = response.getWriter();

        try {
            if ("admin".equals(role)) {
                // 管理员登录验证
                ResultSet rs = db.doQuery("SELECT * FROM lwmadmin WHERE lwmadminaccount=? AND lwmadminpassword=?",
                        new Object[]{account, password});

                if (rs.next()) {
                    lwmAdmin admin = new lwmAdmin();
                    admin.setLwmadminid(rs.getInt("lwmadminid"));
                    admin.setLwmadminaccount(rs.getString("lwmadminaccount"));
                    admin.setLwmadminpassword(rs.getString("lwmadminpassword"));
                    admin.setLwmadminname(rs.getString("lwmadminname"));

                    HttpSession session = request.getSession();
                    session.setAttribute("admin", admin);
                    session.setAttribute("role", "admin");
                    response.sendRedirect("lwmadmin_main.jsp");
                } else {
                    out.println("<script>alert('管理员账号或密码错误！');history.go(-1);</script>");
                }

            } else if ("student".equals(role)) {
                // 学生登录验证
                ResultSet rs = db.doQuery("SELECT * FROM lwmstudent WHERE lwmstudentno=? AND lwmstudentpassword=?",
                        new Object[]{account, password});

                if (rs.next()) {
                    lwmStudent student = new lwmStudent();
                    student.setLwmstudentid(rs.getInt("lwmstudentid"));
                    student.setLwmstudentno(rs.getString("lwmstudentno"));
                    student.setLwmstudentname(rs.getString("lwmstudentname"));
                    student.setLwmstudentpassword(rs.getString("lwmstudentpassword"));
                    student.setLwmgender(rs.getString("lwmgender"));
                    student.setLwmgrade(rs.getString("lwmgrade"));
                    student.setLwmmajor(rs.getString("lwmmajor"));
                    student.setLwmclassname(rs.getString("lwmclassname"));

                    HttpSession session = request.getSession();
                    session.setAttribute("student", student);
                    session.setAttribute("role", "student");
                    response.sendRedirect("lwmstudent_main.jsp");
                } else {
                    out.println("<script>alert('学生学号或密码错误！');history.go(-1);</script>");
                }

            } else if ("teacher".equals(role)) {
                // 教师登录验证
                ResultSet rs = db.doQuery("SELECT * FROM lwmteacher WHERE lwmteacherno=? AND lwmteacherpassword=?",
                        new Object[]{account, password});

                if (rs.next()) {
                    lwmTeacher teacher = new lwmTeacher();
                    teacher.setLwmteacherid(rs.getInt("lwmteacherid"));
                    teacher.setLwmteacherno(rs.getString("lwmteacherno"));
                    teacher.setLwmteachername(rs.getString("lwmteachername"));
                    teacher.setLwmteacherpassword(rs.getString("lwmteacherpassword"));


                    HttpSession session = request.getSession();
                    session.setAttribute("teacher", teacher);
                    session.setAttribute("role", "teacher");
                    response.sendRedirect("lwmteacher_main.jsp");
                } else {
                    out.println("<script>alert('教师工号或密码错误！');history.go(-1);</script>");
                }
            } else {
                out.println("<script>alert('请选择登录角色！');history.go(-1);</script>");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('系统错误，请稍后重试！');history.go(-1);</script>");
        } finally {
            db.close();
        }
    }
}