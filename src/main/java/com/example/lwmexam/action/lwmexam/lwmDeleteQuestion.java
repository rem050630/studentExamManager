package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmquestionDAO;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/lwmDeleteQuestion")
public class lwmDeleteQuestion extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        lwmquestionDAO dao = new lwmquestionDAO();
        int res = dao.lwmDeleteQuestion(id);
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        if (res > 0) {
            out.println("<script>alert('删除成功');location.href='lwmQueryQuestion';</script>");
        } else {
            out.println("<script>alert('删除失败');history.go(-1);</script>");
        }
    }
}
