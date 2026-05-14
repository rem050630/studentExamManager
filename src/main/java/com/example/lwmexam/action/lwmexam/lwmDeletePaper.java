package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmpaperDAO;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/lwmDeletePaper")
public class lwmDeletePaper extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        int paperId = Integer.parseInt(request.getParameter("id"));
        lwmpaperDAO dao = new lwmpaperDAO();

        if (dao.hasSubmitRecord(paperId)) {
            out.println("<script>alert('该试卷已有学生提交，不可删除');history.go(-1);</script>");
            return;
        }
        int res = dao.lwmDeletePaper(paperId);
        if (res > 0) {
            out.println("<script>alert('删除成功');location.href='lwmQueryPaper';</script>");
        } else {
            out.println("<script>alert('删除失败');history.go(-1);</script>");
        }
    }
}
