package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.service.lwmexam.MysqlConn;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/lwmKnowledgeAnalysis")
public class lwmKnowledgeAnalysisAction extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        String paperIdStr = request.getParameter("paperid");
        if (paperIdStr == null || paperIdStr.isEmpty()) {
            response.getWriter().print("[]");
            return;
        }
        int paperId = Integer.parseInt(paperIdStr);

        String classnames = request.getParameter("classnames");
        MysqlConn db = new MysqlConn();
        ResultSet rs = null;

        if (classnames != null && !classnames.trim().isEmpty()) {
            // Mode 2: Per-class KP comparison
            String[] classes = classnames.split(",");
            if (classes.length == 0) {
                response.getWriter().print("{}");
                return;
            }

            // Build class filter placeholders
            StringBuilder placeholders = new StringBuilder();
            List<Object> params = new ArrayList<>();
            params.add(paperId);
            for (int i = 0; i < classes.length; i++) {
                if (i > 0) placeholders.append(",");
                placeholders.append("?");
                params.add(classes[i].trim());
            }

            Map<String, List<Map<String, Object>>> result = new LinkedHashMap<>();
            // Initialize empty arrays for each class
            for (String cls : classes) {
                result.put(cls.trim(), new ArrayList<Map<String, Object>>());
            }

            // First, get all KPs with their names for this paper (to ensure consistent KP list across classes)
            List<Map<String, Object>> allKPs = new ArrayList<>();
            try {
                rs = db.doQuery(
                    "SELECT DISTINCT kp.lwmkpid, kp.lwmkpname " +
                    "FROM lwmknowledgepoint kp " +
                    "JOIN lwmquestionknowledge qk ON kp.lwmkpid = qk.lwmkpid " +
                    "JOIN lwmpaperquestion pq ON qk.lwmquestionid = pq.lwmquestionid " +
                    "WHERE pq.lwmpaperid = ? ORDER BY kp.lwmkpid",
                    new Object[]{paperId});
                while (rs.next()) {
                    Map<String, Object> kp = new LinkedHashMap<>();
                    kp.put("kpid", rs.getInt("lwmkpid"));
                    kp.put("kpname", rs.getString("lwmkpname"));
                    allKPs.add(kp);
                }
                rs.close();
            } catch (Exception e) { e.printStackTrace(); }
            db.close();

            if (allKPs.isEmpty()) {
                StringBuilder json = new StringBuilder("{");
                for (int i = 0; i < classes.length; i++) {
                    json.append("\"").append(escapeJson(classes[i].trim())).append("\":[]");
                    if (i < classes.length - 1) json.append(",");
                }
                json.append("}");
                response.getWriter().print(json.toString());
                return;
            }

            // Initialize rate maps: kpid -> {classname -> {correct, total}}
            Map<Integer, Map<String, int[]>> kpClassStats = new LinkedHashMap<>();
            for (Map<String, Object> kp : allKPs) {
                int kpid = (Integer) kp.get("kpid");
                Map<String, int[]> classStats = new LinkedHashMap<>();
                for (String cls : classes) {
                    classStats.put(cls.trim(), new int[]{0, 0}); // [correct_count, total_count]
                }
                kpClassStats.put(kpid, classStats);
            }

            // Query per-class KP stats
            db = new MysqlConn();
            try {
                String sql = "SELECT kp.lwmkpid, s.lwmclassname, " +
                    "SUM(CASE WHEN sa.lwmquestionscore > 0 THEN 1 ELSE 0 END) AS correct_cnt, " +
                    "COUNT(*) AS total_cnt " +
                    "FROM lwmknowledgepoint kp " +
                    "JOIN lwmquestionknowledge qk ON kp.lwmkpid = qk.lwmkpid " +
                    "JOIN lwmpaperquestion pq ON qk.lwmquestionid = pq.lwmquestionid " +
                    "JOIN lwmstudentanswer sa ON sa.lwmquestionid = qk.lwmquestionid AND sa.lwmpaperid = pq.lwmpaperid " +
                    "JOIN lwmstudent s ON sa.lwmstudentid = s.lwmstudentid " +
                    "WHERE pq.lwmpaperid = ? AND s.lwmclassname IN (" + placeholders.toString() + ") " +
                    "GROUP BY kp.lwmkpid, s.lwmclassname";
                rs = db.doQuery(sql, params.toArray());
                while (rs.next()) {
                    int kpid = rs.getInt("lwmkpid");
                    String cls = rs.getString("lwmclassname");
                    int correctCnt = rs.getInt("correct_cnt");
                    int totalCnt = rs.getInt("total_cnt");
                    Map<String, int[]> cs = kpClassStats.get(kpid);
                    if (cs != null && cs.containsKey(cls)) {
                        cs.get(cls)[0] = correctCnt;
                        cs.get(cls)[1] = totalCnt;
                    }
                }
                rs.close();
            } catch (Exception e) { e.printStackTrace(); }
            db.close();

            // Build per-class result arrays
            for (Map<String, Object> kp : allKPs) {
                int kpid = (Integer) kp.get("kpid");
                String kpname = (String) kp.get("kpname");
                Map<String, int[]> classStats = kpClassStats.get(kpid);
                if (classStats != null) {
                    for (String cls : classes) {
                        String c = cls.trim();
                        int[] stats = classStats.get(c);
                        double rate = 0;
                        if (stats != null && stats[1] > 0) {
                            rate = (double) stats[0] / stats[1];
                        }
                        Map<String, Object> entry = new LinkedHashMap<>();
                        entry.put("kpid", kpid);
                        entry.put("kpname", kpname);
                        entry.put("rate", Double.parseDouble(String.format("%.2f", rate)));
                        result.get(c).add(entry);
                    }
                }
            }

            // Build JSON
            StringBuilder json = new StringBuilder("{");
            boolean firstClass = true;
            for (String cls : classes) {
                if (!firstClass) json.append(",");
                firstClass = false;
                String c = cls.trim();
                json.append("\"").append(escapeJson(c)).append("\":[");
                List<Map<String, Object>> entries = result.get(c);
                for (int i = 0; i < entries.size(); i++) {
                    Map<String, Object> e = entries.get(i);
                    json.append("{");
                    json.append("\"kpid\":").append(e.get("kpid")).append(",");
                    json.append("\"kpname\":\"").append(escapeJson((String) e.get("kpname"))).append("\",");
                    json.append("\"rate\":").append(e.get("rate"));
                    json.append("}");
                    if (i < entries.size() - 1) json.append(",");
                }
                json.append("]");
            }
            json.append("}");
            response.getWriter().print(json.toString());

        } else {
            // Mode 1: Overall KP analysis
            List<Map<String, Object>> result = new ArrayList<>();
            try {
                rs = db.doQuery(
                    "SELECT kp.lwmkpid, kp.lwmkpname, " +
                    "COUNT(DISTINCT sa.lwmquestionid) AS qcnt, " +
                    "AVG(CASE WHEN sa.lwmquestionscore > 0 THEN 1 ELSE 0 END) AS score_rate, " +
                    "COUNT(*) AS total_answers " +
                    "FROM lwmknowledgepoint kp " +
                    "JOIN lwmquestionknowledge qk ON kp.lwmkpid = qk.lwmkpid " +
                    "JOIN lwmpaperquestion pq ON qk.lwmquestionid = pq.lwmquestionid " +
                    "JOIN lwmstudentanswer sa ON sa.lwmquestionid = qk.lwmquestionid AND sa.lwmpaperid = pq.lwmpaperid " +
                    "WHERE pq.lwmpaperid = ? " +
                    "GROUP BY kp.lwmkpid, kp.lwmkpname " +
                    "ORDER BY score_rate ASC",
                    new Object[]{paperId});
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("kpid", rs.getInt("lwmkpid"));
                    row.put("kpname", rs.getString("lwmkpname"));
                    row.put("qcnt", rs.getInt("qcnt"));
                    double rate = rs.getDouble("score_rate");
                    row.put("rate", Double.parseDouble(String.format("%.2f", rate)));
                    row.put("weak", rate < 0.6);
                    result.add(row);
                }
                rs.close();
            } catch (Exception e) { e.printStackTrace(); }
            db.close();

            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < result.size(); i++) {
                Map<String, Object> row = result.get(i);
                json.append("{");
                json.append("\"kpid\":").append(row.get("kpid")).append(",");
                json.append("\"kpname\":\"").append(escapeJson((String) row.get("kpname"))).append("\",");
                json.append("\"qcnt\":").append(row.get("qcnt")).append(",");
                json.append("\"rate\":").append(row.get("rate")).append(",");
                json.append("\"weak\":").append(row.get("weak"));
                json.append("}");
                if (i < result.size() - 1) json.append(",");
            }
            json.append("]");
            response.getWriter().print(json.toString());
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
