package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.service.lwmexam.MysqlConn;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.sql.ResultSet;
import java.util.Properties;

@WebServlet("/lwmAIAnalysis")
public class lwmAIAnalysisAction extends HttpServlet {

    private String apiKey;
    private String apiUrl;

    @Override
    public void init() throws ServletException {
        try {
            Properties props = new Properties();
            props.load(getServletContext().getResourceAsStream("/WEB-INF/config.properties"));
            apiKey = props.getProperty("deepseek.api.key", "");
            apiUrl = props.getProperty("deepseek.api.url", "https://api.deepseek.com/v1/chat/completions");
        } catch (Exception e) {
            throw new ServletException("Failed to load config.properties", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        String paperIdStr = request.getParameter("paperid");
        if (paperIdStr == null || paperIdStr.isEmpty()) {
            response.getWriter().print("{\"error\":\"请选择试卷\"}");
            return;
        }
        int paperId = Integer.parseInt(paperIdStr);
        String classname = request.getParameter("classname");
        boolean filterByClass = classname != null && !classname.trim().isEmpty();

        // Collect data
        StringBuilder data = new StringBuilder();

        // 1. Score overview
        data.append("【成绩概览】\n");
        MysqlConn db = new MysqlConn();
        ResultSet rs;
        int totalScore = 100;
        try {
            // Get paper total score
            rs = db.doQuery("SELECT lwmexamsore FROM lwmexampaper WHERE lwmpaperid = ?", new Object[]{paperId});
            if (rs.next()) totalScore = rs.getInt("lwmexamsore");
            rs.close();
        } catch (Exception e) { e.printStackTrace(); }
        db.close();
        int passLine = (int)(totalScore * 0.6);
        int excelLine = (int)(totalScore * 0.9);

        db = new MysqlConn();
        try {
            String sql = "SELECT COUNT(*) AS cnt, AVG(sc.lwmtotalscore) AS avg, MAX(sc.lwmtotalscore) AS max, " +
                "MIN(sc.lwmtotalscore) AS min " +
                "FROM lwmexamscore sc " +
                "JOIN lwmexamrecord r ON sc.lwmrecordid = r.lwmrecordid " +
                "JOIN lwmstudent s ON sc.lwmstudentid = s.lwmstudentid " +
                "WHERE sc.lwmpaperid = ?";
            Object[] params = filterByClass
                ? new Object[]{paperId}
                : new Object[]{paperId};
            String classFilter = filterByClass ? " AND s.lwmclassname = ?" : "";

            rs = db.doQuery(sql + classFilter,
                filterByClass ? new Object[]{paperId, classname.trim()} : new Object[]{paperId});
            int cnt = 0;
            double avg = 0;
            int max = 0, min = 0;
            if (rs.next()) {
                cnt = rs.getInt("cnt");
                avg = rs.getDouble("avg");
                max = rs.getInt("max");
                min = rs.getInt("min");
            }
            rs.close();

            // Pass rate
            rs = db.doQuery(
                "SELECT COUNT(*) AS total, SUM(CASE WHEN sc.lwmtotalscore >= ? THEN 1 ELSE 0 END) AS pass_count " +
                "FROM lwmexamscore sc " +
                "JOIN lwmexamrecord r ON sc.lwmrecordid = r.lwmrecordid " +
                "JOIN lwmstudent s ON sc.lwmstudentid = s.lwmstudentid " +
                "WHERE sc.lwmpaperid = ?" + classFilter,
                filterByClass
                    ? new Object[]{passLine, paperId, classname.trim()}
                    : new Object[]{passLine, paperId});
            double passRate = 0;
            if (rs.next()) {
                int total = rs.getInt("total");
                int passCount = rs.getInt("pass_count");
                passRate = total > 0 ? (double) passCount / total * 100.0 : 0;
            }
            rs.close();

            // Distribution
            int b2End = (int)(totalScore * 0.7), b3End = (int)(totalScore * 0.8);
            rs = db.doQuery(
                "SELECT " +
                "SUM(CASE WHEN sc.lwmtotalscore < ? THEN 1 ELSE 0 END) AS b0, " +
                "SUM(CASE WHEN sc.lwmtotalscore >= ? AND sc.lwmtotalscore < ? THEN 1 ELSE 0 END) AS b1, " +
                "SUM(CASE WHEN sc.lwmtotalscore >= ? AND sc.lwmtotalscore < ? THEN 1 ELSE 0 END) AS b2, " +
                "SUM(CASE WHEN sc.lwmtotalscore >= ? AND sc.lwmtotalscore < ? THEN 1 ELSE 0 END) AS b3, " +
                "SUM(CASE WHEN sc.lwmtotalscore >= ? THEN 1 ELSE 0 END) AS b4 " +
                "FROM lwmexamscore sc " +
                "JOIN lwmexamrecord r ON sc.lwmrecordid = r.lwmrecordid " +
                "JOIN lwmstudent s ON sc.lwmstudentid = s.lwmstudentid " +
                "WHERE sc.lwmpaperid = ?" + classFilter,
                filterByClass
                    ? new Object[]{passLine, passLine, b2End, b2End, b3End, b3End, excelLine, excelLine, paperId, classname.trim()}
                    : new Object[]{passLine, passLine, b2End, b2End, b3End, b3End, excelLine, excelLine, paperId});
            int[] dist = new int[5];
            if (rs.next()) {
                for (int i = 0; i < 5; i++) dist[i] = rs.getInt("b" + i);
            }
            rs.close();

            data.append("参考人数:").append(cnt).append(", 平均分:").append(String.format("%.1f", avg))
                .append(", 最高分:").append(max).append(", 最低分:").append(min)
                .append(", 及格率:").append(String.format("%.1f", passRate)).append("%")
                .append(", 总分:").append(totalScore).append("\n");
            data.append("分数分布: 不及格(").append(dist[0]).append("), 及格(").append(dist[1])
                .append("), 中等(").append(dist[2]).append("), 良好(").append(dist[3])
                .append("), 优秀(").append(dist[4]).append(")\n");
        } catch (Exception e) { e.printStackTrace(); }
        db.close();

        // 2. Question quality (top 10 most difficult)
        data.append("\n【试题质量】\n");
        db = new MysqlConn();
        try {
            rs = db.doQuery(
                "SELECT q.lwmquestionid, q.lwmquestiontype, q.lwmquestioncontent, " +
                "GROUP_CONCAT(DISTINCT kp.lwmkpname SEPARATOR ', ') AS kpnames " +
                "FROM lwmexamquestion q " +
                "JOIN lwmpaperquestion pq ON q.lwmquestionid = pq.lwmquestionid " +
                "LEFT JOIN lwmquestionknowledge qk ON q.lwmquestionid = qk.lwmquestionid " +
                "LEFT JOIN lwmknowledgepoint kp ON qk.lwmkpid = kp.lwmkpid " +
                "WHERE pq.lwmpaperid = ? " +
                "GROUP BY q.lwmquestionid ORDER BY pq.lwmid",
                new Object[]{paperId});
            java.util.List<String[]> qList = new java.util.ArrayList<>();
            while (rs.next()) {
                String content = rs.getString("lwmquestioncontent");
                if (content != null && content.length() > 30) content = content.substring(0, 30) + "...";
                qList.add(new String[]{
                    String.valueOf(rs.getInt("lwmquestionid")),
                    rs.getString("lwmquestiontype"),
                    content,
                    rs.getString("kpnames") != null ? rs.getString("kpnames") : ""
                });
            }
            rs.close();

            // Calculate difficulty for each question
            for (String[] q : qList) {
                int qid = Integer.parseInt(q[0]);
                rs = db.doQuery(
                    "SELECT COUNT(*) AS total, SUM(CASE WHEN sa.lwmquestionscore > 0 THEN 1 ELSE 0 END) AS correct " +
                    "FROM lwmstudentanswer sa " +
                    (filterByClass ? "JOIN lwmstudent s ON sa.lwmstudentid = s.lwmstudentid AND s.lwmclassname = ? " : "") +
                    "WHERE sa.lwmquestionid = ? AND sa.lwmpaperid = ?",
                    filterByClass ? new Object[]{classname.trim(), qid, paperId} : new Object[]{qid, paperId});
                if (rs.next()) {
                    int total = rs.getInt("total");
                    int correct = rs.getInt("correct");
                    double difficulty = total > 0 ? (double) correct / total : 0;
                    String level = difficulty >= 0.75 ? "容易" : (difficulty >= 0.5 ? "中等" : (difficulty >= 0.25 ? "较难" : "困难"));
                    data.append("[").append(q[1]).append("] ").append(q[2])
                        .append(" | 难度:").append(level).append("(").append(String.format("%.0f", difficulty * 100)).append("%)");
                    if (!q[3].isEmpty()) data.append(" | 知识点:").append(q[3]);
                    data.append("\n");
                }
                rs.close();
            }
        } catch (Exception e) { e.printStackTrace(); }
        db.close();

        // 3. Knowledge point analysis
        data.append("\n【知识点分析】\n");
        db = new MysqlConn();
        try {
            rs = db.doQuery(
                "SELECT kp.lwmkpid, kp.lwmkpname, " +
                "COUNT(DISTINCT sa.lwmquestionid) AS qcnt, " +
                "AVG(CASE WHEN sa.lwmquestionscore > 0 THEN 1 ELSE 0 END) AS score_rate " +
                "FROM lwmknowledgepoint kp " +
                "JOIN lwmquestionknowledge qk ON kp.lwmkpid = qk.lwmkpid " +
                "JOIN lwmpaperquestion pq ON qk.lwmquestionid = pq.lwmquestionid " +
                "JOIN lwmstudentanswer sa ON sa.lwmquestionid = qk.lwmquestionid AND sa.lwmpaperid = pq.lwmpaperid " +
                (filterByClass ? "JOIN lwmstudent s ON sa.lwmstudentid = s.lwmstudentid AND s.lwmclassname = ? " : "") +
                "WHERE pq.lwmpaperid = ? " +
                "GROUP BY kp.lwmkpid, kp.lwmkpname ORDER BY score_rate ASC",
                filterByClass ? new Object[]{classname.trim(), paperId} : new Object[]{paperId});
            while (rs.next()) {
                double rate = rs.getDouble("score_rate");
                String status = rate < 0.6 ? "薄弱" : (rate < 0.8 ? "一般" : "良好");
                data.append(rs.getString("lwmkpname")).append(": 得分率").append(String.format("%.0f", rate * 100))
                    .append("% (").append(status).append("), 关联").append(rs.getInt("qcnt")).append("题\n");
            }
            rs.close();
        } catch (Exception e) { e.printStackTrace(); }
        db.close();

        // Build prompt and call DeepSeek
        String analysis = callDeepSeek(data.toString(),
            filterByClass ? "（班级筛选: " + classname.trim() + "）" : "");

        response.getWriter().print("{\"analysis\":\"" + escapeJson(analysis) + "\"}");
    }

    private String callDeepSeek(String data, String classNote) {
        String systemPrompt = "";

        String userContent = data + "\n" + classNote;

        try {
            URL url = new URL(apiUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("Authorization", "Bearer " + apiKey);
            conn.setDoOutput(true);
            conn.setConnectTimeout(30000);
            conn.setReadTimeout(60000);

            String body = "{\"model\":\"deepseek-chat\"," +
                "\"system\":\"" + escapeJson(systemPrompt) + "\"," +
                "\"messages\":[" +
                "{\"role\":\"user\",\"content\":\"" + escapeJson(userContent) + "\"}" +
                "],\"max_tokens\":1200,\"temperature\":0.7}";

            OutputStream os = conn.getOutputStream();
            os.write(body.getBytes("UTF-8"));
            os.flush();
            os.close();

            int code = conn.getResponseCode();
            java.io.InputStream is = code >= 200 && code < 300 ? conn.getInputStream() : conn.getErrorStream();
            StringBuilder resp = new StringBuilder();
            if (is != null) {
                BufferedReader br = new BufferedReader(new InputStreamReader(is, "UTF-8"));
                String line;
                while ((line = br.readLine()) != null) resp.append(line);
                br.close();
            }
            conn.disconnect();

            if (code >= 200 && code < 300) {
                return extractContent(resp.toString());
            } else {
                return "AI分析请求失败(HTTP " + code + "): " + resp.toString();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "AI分析服务暂时不可用: " + e.getMessage();
        }
    }

    private String extractContent(String json) {
        // Anthropic format: content[0].text
        // OpenAI format: choices[0].message.content
        // Try Anthropic format first
        int textIdx = json.indexOf("\"text\"");
        if (textIdx >= 0) {
            int colonIdx = json.indexOf(":", textIdx);
            if (colonIdx >= 0) {
                int start = json.indexOf("\"", colonIdx + 1);
                if (start >= 0) {
                    start++;
                    int end = start - 1;
                    boolean escaped = false;
                    for (int i = start; i < json.length(); i++) {
                        char c = json.charAt(i);
                        if (escaped) { escaped = false; continue; }
                        if (c == '\\') { escaped = true; continue; }
                        if (c == '"') { end = i; break; }
                    }
                    if (end > start) {
                        return json.substring(start, end)
                            .replace("\\n", "\n").replace("\\\"", "\"").replace("\\\\", "\\");
                    }
                }
            }
        }
        // Fallback: OpenAI format
        try {
            int msgIdx = json.indexOf("\"message\"");
            if (msgIdx < 0) return json;
            int contentIdx = json.indexOf("\"content\"", msgIdx);
            if (contentIdx < 0) return json;
            int start = json.indexOf("\"", contentIdx + 10) + 1;
            int end = start - 1;
            boolean escaped = false;
            for (int i = start; i < json.length(); i++) {
                char c = json.charAt(i);
                if (escaped) { escaped = false; continue; }
                if (c == '\\') { escaped = true; continue; }
                if (c == '"') { end = i; break; }
            }
            if (end > start) {
                return json.substring(start, end)
                    .replace("\\n", "\n").replace("\\\"", "\"").replace("\\\\", "\\");
            }
        } catch (Exception ignored) {}
        return json;
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
