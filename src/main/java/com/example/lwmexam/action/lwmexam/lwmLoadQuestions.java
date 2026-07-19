package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmquestionDAO;
import com.example.lwmexam.entity.lwmexam.lwmExamQuestion;
import com.example.lwmexam.entity.lwmexam.lwmTeacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@WebServlet("/lwmLoadQuestions")
public class lwmLoadQuestions extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        PrintWriter out = response.getWriter();

        if (teacher == null) { out.print("<p style='color:#94a3b8;'>请先登录</p>"); return; }

        String subjectId = request.getParameter("subject");
        String questionType = request.getParameter("type");
        String exclude = request.getParameter("exclude");
        if (questionType == null || questionType.isEmpty()) questionType = null;

        if (subjectId == null || subjectId.isEmpty()) {
            out.print("<p style='color:#94a3b8;'>请先选择科目</p>"); return;
        }

        lwmquestionDAO dao = new lwmquestionDAO();
        List<lwmExamQuestion> allQuestions = dao.lwmQueryBySubjectType(subjectId, questionType, null);
        List<lwmExamQuestion> filtered = new ArrayList<>();

        if (exclude != null && !exclude.isEmpty()) {
            Set<Integer> excludeSet = new HashSet<>();
            for (String eid : exclude.split(",")) {
                try { excludeSet.add(Integer.parseInt(eid.trim())); } catch (NumberFormatException ignored) {}
            }
            for (lwmExamQuestion q : allQuestions) {
                if (!excludeSet.contains(q.getLwmquestionid())) {
                    filtered.add(q);
                }
            }
        } else {
            filtered = allQuestions;
        }

        if (filtered.isEmpty()) {
            out.print("<p style='color:#94a3b8;'>该科目暂无更多试题</p>"); return;
        }

        for (lwmExamQuestion q : filtered) {
            out.print("<div class=\"q-item\">");
            out.print("<input type=\"checkbox\" name=\"addQuestionIds\" value=\"" + q.getLwmquestionid() + "\">");
            out.print("<span>[" + escapeHtml(q.getLwmquestiontype()) + "] " + escapeHtml(q.getLwmquestioncontent()) + "</span>");
            out.print("</div>");
        }
    }

    private String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
}
