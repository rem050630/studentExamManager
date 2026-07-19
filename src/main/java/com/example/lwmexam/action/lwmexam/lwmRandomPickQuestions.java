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
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@WebServlet("/lwmRandomPickQuestions")
public class lwmRandomPickQuestions extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        PrintWriter out = response.getWriter();

        if (teacher == null) { out.print(""); return; }

        int subjectId;
        try { subjectId = Integer.parseInt(request.getParameter("subject")); }
        catch (NumberFormatException e) { out.print(""); return; }

        Set<Integer> excludeSet = new HashSet<>();
        String exclude = request.getParameter("exclude");
        if (exclude != null && !exclude.isEmpty()) {
            for (String eid : exclude.split(",")) {
                try { excludeSet.add(Integer.parseInt(eid.trim())); } catch (NumberFormatException ignored) {}
            }
        }

        lwmquestionDAO dao = new lwmquestionDAO();
        StringBuilder html = new StringBuilder();

        int danxNum = parseInt(request.getParameter("danxnum"), 0);
        int duoxNum = parseInt(request.getParameter("duoxnum"), 0);
        int pdNum = parseInt(request.getParameter("pdnum"), 0);
        int jdNum = parseInt(request.getParameter("jdnum"), 0);

        String[][] typeDefs = {{"单选题"}, {"多选题"}, {"判断题"}, {"简答题"}};
        int[] counts = {danxNum, duoxNum, pdNum, jdNum};

        for (int i = 0; i < typeDefs.length; i++) {
            int count = counts[i];
            String typeName = typeDefs[i][0];
            if (count <= 0) continue;

            List<lwmExamQuestion> picked = dao.lwmRandomPick(subjectId, typeName, count + excludeSet.size());
            int added = 0;
            for (lwmExamQuestion q : picked) {
                if (added >= count) break;
                if (!excludeSet.contains(q.getLwmquestionid())) {
                    excludeSet.add(q.getLwmquestionid());
                    html.append("<div class=\"q-item\">");
                    html.append("<input type=\"checkbox\" name=\"questionIds\" value=\"").append(q.getLwmquestionid()).append("\" checked>");
                    html.append("<span class=\"badge\">").append(escapeHtml(typeName)).append("</span>");
                    html.append("<span>").append(escapeHtml(q.getLwmquestioncontent())).append("</span>");
                    html.append("<button type=\"button\" class=\"btn-remove\" onclick=\"this.parentElement.remove();existingIds.delete(").append(q.getLwmquestionid()).append(");updateTotal();editLoadQuestions()\">移除</button>");
                    html.append("</div>");
                    added++;
                }
            }
            if (added < count) {
                out.print("<p style='color:#ef4444;'>" + typeName + "数量不足：需要" + count + "道，题库可用不足</p>");
                return;
            }
        }

        out.print(html.toString());
    }

    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }

    private String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
}
