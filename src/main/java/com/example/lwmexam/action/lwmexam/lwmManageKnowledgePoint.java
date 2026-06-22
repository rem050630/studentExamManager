package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmKnowledgePointDAO;
import com.example.lwmexam.entity.lwmexam.lwmKnowledgePoint;
import com.example.lwmexam.entity.lwmexam.lwmTeacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/lwmManageKnowledgePoint")
public class lwmManageKnowledgePoint extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        if (teacher == null) {
            response.getWriter().print("{\"error\":\"not_logged_in\"}");
            return;
        }

        String subjectIdStr = request.getParameter("subjectid");
        if (subjectIdStr == null || subjectIdStr.isEmpty()) {
            response.getWriter().print("[]");
            return;
        }
        int subjectId = Integer.parseInt(subjectIdStr);

        lwmKnowledgePointDAO kpDao = new lwmKnowledgePointDAO();
        List<lwmKnowledgePoint> kpList = kpDao.queryBySubject(subjectId);

        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < kpList.size(); i++) {
            lwmKnowledgePoint kp = kpList.get(i);
            json.append("{");
            json.append("\"kpid\":").append(kp.getLwmkpid()).append(",");
            json.append("\"kpname\":\"").append(escapeJson(kp.getLwmkpname())).append("\",");
            json.append("\"kpdesc\":\"").append(escapeJson(kp.getLwmkpdesc() != null ? kp.getLwmkpdesc() : "")).append("\"");
            json.append("}");
            if (i < kpList.size() - 1) json.append(",");
        }
        json.append("]");
        response.getWriter().print(json.toString());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        if (teacher == null) {
            response.getWriter().print("{\"error\":\"not_logged_in\"}");
            return;
        }

        String action = request.getParameter("action");
        lwmKnowledgePointDAO kpDao = new lwmKnowledgePointDAO();

        if ("add".equals(action)) {
            // Insert new KP
            String subjectIdStr = request.getParameter("subjectid");
            String kpname = request.getParameter("kpname");
            String kpdesc = request.getParameter("kpdesc");

            if (subjectIdStr == null || subjectIdStr.isEmpty() || kpname == null || kpname.trim().isEmpty()) {
                response.getWriter().print("{\"success\":false,\"message\":\"缺少必填参数\"}");
                return;
            }
            int subjectId = Integer.parseInt(subjectIdStr);

            lwmKnowledgePoint kp = new lwmKnowledgePoint();
            kp.setLwmsubjectid(subjectId);
            kp.setLwmkpname(kpname.trim());
            kp.setLwmkpdesc(kpdesc != null ? kpdesc.trim() : "");

            int result = kpDao.insert(kp);
            if (result > 0) {
                // Get the inserted ID
                List<lwmKnowledgePoint> list = kpDao.queryBySubject(subjectId);
                int insertedId = 0;
                for (lwmKnowledgePoint item : list) {
                    if (item.getLwmkpid() > insertedId) insertedId = item.getLwmkpid();
                }
                response.getWriter().print("{\"success\":true,\"kpid\":" + insertedId + ",\"kpname\":\"" + escapeJson(kpname.trim()) + "\"}");
            } else {
                response.getWriter().print("{\"success\":false,\"message\":\"添加失败\"}");
            }
        } else if ("saveQuestionKPs".equals(action)) {
            // Save question-KP links
            String questionIdStr = request.getParameter("questionid");
            String[] kpIdsParam = request.getParameterValues("kpids[]");

            if (questionIdStr == null || questionIdStr.isEmpty()) {
                response.getWriter().print("{\"success\":false,\"message\":\"缺少questionid参数\"}");
                return;
            }
            int questionId = Integer.parseInt(questionIdStr);

            int[] kpIds = null;
            if (kpIdsParam != null && kpIdsParam.length > 0) {
                kpIds = new int[kpIdsParam.length];
                for (int i = 0; i < kpIdsParam.length; i++) {
                    kpIds[i] = Integer.parseInt(kpIdsParam[i]);
                }
            }
            kpDao.saveQuestionKPs(questionId, kpIds);
            response.getWriter().print("{\"success\":true}");
        } else if ("delete".equals(action)) {
            String kpIdStr = request.getParameter("kpid");
            if (kpIdStr == null || kpIdStr.isEmpty()) {
                response.getWriter().print("{\"success\":false,\"message\":\"缺少kpid参数\"}");
                return;
            }
            int kpId = Integer.parseInt(kpIdStr);

            int refCount = kpDao.countQuestionsByKP(kpId);
            if (refCount > 0) {
                response.getWriter().print("{\"success\":false,\"message\":\"该知识点已被试题使用，无法删除\"}");
                return;
            }

            int result = kpDao.delete(kpId);
            if (result > 0) {
                response.getWriter().print("{\"success\":true}");
            } else {
                response.getWriter().print("{\"success\":false,\"message\":\"删除失败\"}");
            }
        } else {
            response.getWriter().print("{\"success\":false,\"message\":\"未知action: " + (action != null ? action : "null") + "\"}");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default: sb.append(c);
            }
        }
        return sb.toString();
    }
}
