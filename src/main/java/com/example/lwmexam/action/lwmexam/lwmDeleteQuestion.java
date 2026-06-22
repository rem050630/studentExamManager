package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmpaperDAO;
import com.example.lwmexam.dao.lwmexam.lwmquestionDAO;
import com.example.lwmexam.entity.lwmexam.lwmExamPaper;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/lwmDeleteQuestion")
public class lwmDeleteQuestion extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        int id = Integer.parseInt(request.getParameter("id"));

        lwmpaperDAO paperDAO = new lwmpaperDAO();
        List<lwmExamPaper> papers = paperDAO.getPapersByQuestionId(id);
        if (papers != null && !papers.isEmpty()) {
            StringBuilder sb = new StringBuilder("该试题已被以下试卷引用，无法删除：");
            for (lwmExamPaper p : papers) {
                sb.append("\\n- ").append(p.getLwmpapername());
            }
            sb.append("\\n\\n请先从对应试卷中移除该试题后再删除。");
            out.println("<script>alert('" + sb.toString() + "');history.go(-1);</script>");
            return;
        }

        lwmquestionDAO dao = new lwmquestionDAO();
        int res = dao.lwmDeleteQuestion(id);
        if (res > 0) {
            out.println("<script>alert('删除成功');location.href='lwmQueryQuestion';</script>");
        } else {
            out.println("<script>alert('删除失败');history.go(-1);</script>");
        }
    }
}
