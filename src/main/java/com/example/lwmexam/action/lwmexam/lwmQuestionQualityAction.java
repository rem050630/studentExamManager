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
import java.util.Set;
import java.util.HashSet;

@WebServlet("/lwmQuestionQuality")
public class lwmQuestionQualityAction extends HttpServlet {
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

        // 新增：读取可选的 classname 参数
        String classname = request.getParameter("classname");
        boolean filterByClass = classname != null && !classname.trim().isEmpty();

        MysqlConn db = new MysqlConn();
        ResultSet rs = null;

        // 1. Get all questions for this paper
        List<Map<String, Object>> questions = new ArrayList<>();
        try {
            rs = db.doQuery(
                "SELECT q.lwmquestionid, q.lwmquestiontype, q.lwmquestioncontent, q.lwmcorrectanswer, " +
                "GROUP_CONCAT(DISTINCT kp.lwmkpname SEPARATOR ', ') AS kpnames " +
                "FROM lwmexamquestion q " +
                "JOIN lwmpaperquestion pq ON q.lwmquestionid = pq.lwmquestionid " +
                "LEFT JOIN lwmquestionknowledge qk ON q.lwmquestionid = qk.lwmquestionid " +
                "LEFT JOIN lwmknowledgepoint kp ON qk.lwmkpid = kp.lwmkpid " +
                "WHERE pq.lwmpaperid = ? " +
                "GROUP BY q.lwmquestionid, q.lwmquestiontype, q.lwmquestioncontent, q.lwmcorrectanswer " +
                "ORDER BY pq.lwmid",
                new Object[]{paperId});
            while (rs.next()) {
                Map<String, Object> q = new LinkedHashMap<>();
                q.put("qid", rs.getInt("lwmquestionid"));
                q.put("type", rs.getString("lwmquestiontype"));
                String content = rs.getString("lwmquestioncontent");
                if (content != null && content.length() > 40) {
                    content = content.substring(0, 40) + "...";
                }
                q.put("content", content);
                q.put("answer", rs.getString("lwmcorrectanswer"));
                String kps = rs.getString("kpnames");
                q.put("kps", kps != null ? kps : "");
                questions.add(q);
            }
            rs.close();
        } catch (Exception e) { e.printStackTrace(); }
        db.close();

        if (questions.isEmpty()) {
            response.getWriter().print("[]");
            return;
        }

        // 2. Get all student answers for this paper
        db = new MysqlConn();
        List<Map<String, Object>> answers = new ArrayList<>();
        try {
            rs = db.doQuery(
                "SELECT sa.lwmquestionid, sa.lwmstudentid, sa.lwmstudentanswer, sa.lwmquestionscore, " +
                "q.lwmquestiontype, q.lwmcorrectanswer " +
                "FROM lwmstudentanswer sa " +
                "JOIN lwmexamquestion q ON sa.lwmquestionid = q.lwmquestionid " +
                (filterByClass ? "JOIN lwmstudent s ON sa.lwmstudentid = s.lwmstudentid AND s.lwmclassname = ? " : "") +
                "WHERE sa.lwmpaperid = ?",
                filterByClass ? new Object[]{classname.trim(), paperId} : new Object[]{paperId});
            while (rs.next()) {
                Map<String, Object> a = new LinkedHashMap<>();
                a.put("qid", rs.getInt("lwmquestionid"));
                a.put("sid", rs.getInt("lwmstudentid"));
                a.put("sanswer", rs.getString("lwmstudentanswer"));
                a.put("score", rs.getInt("lwmquestionscore"));
                a.put("type", rs.getString("lwmquestiontype"));
                a.put("correct", rs.getString("lwmcorrectanswer"));
                answers.add(a);
            }
            rs.close();
        } catch (Exception e) { e.printStackTrace(); }
        db.close();

        // Get unique student count
        Set<Integer> allStudents = new HashSet<>();
        for (Map<String, Object> a : answers) {
            allStudents.add((Integer) a.get("sid"));
        }
        int totalStudents = allStudents.size();

        if (totalStudents == 0) {
            response.getWriter().print("[]");
            return;
        }

        // 3. Get student total scores for discrimination calculation
        db = new MysqlConn();
        Map<Integer, Integer> studentScores = new LinkedHashMap<>();
        List<Integer> sortedByScore = new ArrayList<>();
        try {
            rs = db.doQuery(
                "SELECT sc.lwmstudentid, sc.lwmtotalscore " +
                "FROM lwmexamscore sc " +
                (filterByClass ? "JOIN lwmstudent s ON sc.lwmstudentid = s.lwmstudentid AND s.lwmclassname = ? " : "") +
                "WHERE sc.lwmpaperid = ? " +
                "ORDER BY sc.lwmtotalscore DESC",
                filterByClass ? new Object[]{classname.trim(), paperId} : new Object[]{paperId});
            while (rs.next()) {
                int sid = rs.getInt("lwmstudentid");
                int score = rs.getInt("lwmtotalscore");
                studentScores.put(sid, score);
                sortedByScore.add(sid);
            }
            rs.close();
        } catch (Exception e) { e.printStackTrace(); }
        db.close();

        // Determine top 27% and bottom 27% groups
        int groupSize = (int) Math.max(1, Math.round(totalStudents * 0.27));
        Set<Integer> topGroup = new HashSet<>();
        Set<Integer> bottomGroup = new HashSet<>();
        for (int i = 0; i < groupSize && i < sortedByScore.size(); i++) {
            topGroup.add(sortedByScore.get(i));
        }
        for (int i = sortedByScore.size() - 1; i >= Math.max(0, sortedByScore.size() - groupSize); i--) {
            bottomGroup.add(sortedByScore.get(i));
        }

        // 4. Build JSON result
        StringBuilder json = new StringBuilder("[");
        for (int qi = 0; qi < questions.size(); qi++) {
            Map<String, Object> q = questions.get(qi);
            int qid = (Integer) q.get("qid");
            String type = (String) q.get("type");

            int correctCount = 0;
            int qStudentCount = 0;
            int topCorrect = 0;
            int bottomCorrect = 0;

            for (Map<String, Object> a : answers) {
                if ((Integer) a.get("qid") == qid) {
                    qStudentCount++;
                    int sid = (Integer) a.get("sid");
                    boolean isCorrect;
                    if ("简答题".equals(type)) {
                        isCorrect = (Integer) a.get("score") > 0;
                    } else {
                        String sAns = (String) a.get("sanswer");
                        String cAns = (String) a.get("correct");
                        isCorrect = sAns != null && sAns.equalsIgnoreCase(cAns);
                    }
                    if (isCorrect) {
                        correctCount++;
                        if (topGroup.contains(sid)) topCorrect++;
                        if (bottomGroup.contains(sid)) bottomCorrect++;
                    }
                }
            }

            double difficulty = qStudentCount > 0 ? (double) correctCount / qStudentCount : 0;
            int stars = difficulty >= 0.75 ? 1 : (difficulty >= 0.5 ? 2 : (difficulty >= 0.25 ? 3 : 4));

            double topRate = groupSize > 0 ? (double) topCorrect / groupSize : 0;
            double bottomRate = groupSize > 0 ? (double) bottomCorrect / groupSize : 0;
            double discrimination = Math.max(-1.0, Math.min(1.0, topRate - bottomRate));

            json.append("{");
            json.append("\"qid\":").append(qid).append(",");
            json.append("\"type\":\"").append(escapeJson(type)).append("\",");
            json.append("\"content\":\"").append(escapeJson((String) q.get("content"))).append("\",");
            json.append("\"kps\":\"").append(escapeJson((String) q.get("kps"))).append("\",");
            json.append("\"total\":").append(qStudentCount).append(",");
            json.append("\"correct\":").append(correctCount).append(",");
            json.append("\"difficulty\":").append(String.format("%.2f", difficulty)).append(",");
            json.append("\"stars\":").append(stars).append(",");
            json.append("\"discrimination\":").append(String.format("%.3f", discrimination));
            json.append("}");
            if (qi < questions.size() - 1) json.append(",");
        }
        json.append("]");
        response.getWriter().print(json.toString());
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
