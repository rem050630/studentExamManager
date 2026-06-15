<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmStudent" %>
<%@ page import="com.example.lwmexam.service.lwmexam.MysqlConn" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.format.DateTimeParseException" %>
<%
    lwmStudent student = (lwmStudent) session.getAttribute("student");
    String role = (String) session.getAttribute("role");
    if (student == null || !"student".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Map<String,Object>> availExams = new ArrayList<>();
    List<Map<String,Object>> myRecords = new ArrayList<>();

    MysqlConn db = new MysqlConn();
    try {
        ResultSet rs = db.doQuery(
            "SELECT p.* FROM lwmexampaper p " +
            "WHERE FIND_IN_SET(?, p.lwmclassname) " +
            "AND NOT EXISTS (SELECT 1 FROM lwmexamrecord r WHERE r.lwmpaperid = p.lwmpaperid AND r.lwmstudentid = ? AND r.lwmsubmitstatus IN (1, 2)) " +
            "ORDER BY p.lwmstarttime DESC",
            new Object[]{student.getLwmclassname(), student.getLwmstudentid()});
        while (rs.next()) {
            Map<String,Object> m = new HashMap<>();
            m.put("id", rs.getInt("lwmpaperid"));
            m.put("name", rs.getString("lwmpapername"));
            String start = rs.getString("lwmstarttime");
            String end = rs.getString("lwmendtime");
            m.put("start", start);
            m.put("end", end);
            m.put("time", rs.getInt("lwmexamtime"));
            m.put("score", rs.getInt("lwmexamsore"));

            String timeStatus = "during";
            if (start != null && !start.isEmpty() && end != null && !end.isEmpty()) {
                try {
                    String[] patterns = {"yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd HH:mm:ss.S", "yyyy-MM-dd'T'HH:mm", "yyyy-MM-dd HH:mm"};
                    LocalDateTime startTime = parseTimeStr(start, patterns);
                    LocalDateTime endTime = parseTimeStr(end, patterns);
                    LocalDateTime now = LocalDateTime.now();
                    if (startTime != null && endTime != null) {
                        if (now.isBefore(startTime)) timeStatus = "before";
                        else if (now.isAfter(endTime)) timeStatus = "after";
                    }
                } catch (Exception ignored) {}
            }
            m.put("timeStatus", timeStatus);
            availExams.add(m);
        }
    } catch (Exception e) { e.printStackTrace(); }
    db.close();

    db = new MysqlConn();
    try {
        ResultSet rs = db.doQuery(
            "SELECT r.*, p.lwmpapername, sc.lwmtotalscore " +
            "FROM lwmexamrecord r " +
            "JOIN lwmexampaper p ON r.lwmpaperid = p.lwmpaperid " +
            "LEFT JOIN lwmexamscore sc ON r.lwmrecordid = sc.lwmrecordid " +
            "WHERE r.lwmstudentid = ? ORDER BY r.lwmstarttime DESC",
            new Object[]{student.getLwmstudentid()});
        while (rs.next()) {
            Map<String,Object> m = new HashMap<>();
            m.put("recordId", rs.getInt("lwmrecordid"));
            m.put("paperName", rs.getString("lwmpapername"));
            m.put("startTime", rs.getString("lwmstarttime"));
            m.put("status", rs.getInt("lwmsubmitstatus"));
            m.put("score", rs.getObject("lwmtotalscore"));
            myRecords.add(m);
        }
    } catch (Exception e) { e.printStackTrace(); }
    db.close();
%>
<%!
    private LocalDateTime parseTimeStr(String str, String[] patterns) {
        if (str == null || str.isEmpty()) return null;
        for (String p : patterns) {
            try { return LocalDateTime.parse(str, DateTimeFormatter.ofPattern(p)); } catch (DateTimeParseException ignored) {}
        }
        try { return LocalDateTime.parse(str.replace(" ", "T")); } catch (DateTimeParseException e) { return null; }
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>考试中心</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; color:#1e293b; }
        .content-area { padding:28px 32px; overflow-y:auto; }
        .welcome-card {
            background:linear-gradient(135deg,#667eea 0%,#764ba2 50%,#f093fb 100%);
            color:white; padding:32px 40px; border-radius:28px;
            margin-bottom:32px; position:relative; overflow:hidden;
            box-shadow:0 20px 40px rgba(0,0,0,0.15);
        }
        .welcome-card h2 { font-size:1.8rem; margin-bottom:12px; font-weight:700; position:relative; z-index:1; }
        .welcome-card p { font-size:1rem; opacity:0.95; position:relative; z-index:1; }
        .stats-grid {
            display:grid; grid-template-columns:repeat(auto-fit,minmax(240px,1fr));
            gap:24px; margin-bottom:32px;
        }
        .stat-card {
            background:white; padding:28px 24px; border-radius:24px;
            box-shadow:0 4px 12px rgba(0,0,0,0.08); transition:all 0.3s;
            border:1px solid rgba(0,0,0,0.05);
        }
        .stat-card:hover { transform:translateY(-5px); box-shadow:0 12px 28px rgba(0,0,0,0.12); }
        .stat-num {
            font-size:2.5rem; font-weight:800;
            background:linear-gradient(135deg,#f39c12,#e67e22);
            -webkit-background-clip:text; background-clip:text;
            color:transparent; margin-bottom:8px;
        }
        .stat-label {
            color:#64748b; font-size:0.9rem; font-weight:500;
            text-transform:uppercase; letter-spacing:0.5px;
        }
        .exam-card {
            background:white; border-radius:20px; padding:24px 28px;
            margin-bottom:16px; display:flex; justify-content:space-between;
            align-items:center; box-shadow:0 2px 8px rgba(0,0,0,0.06);
            transition:all 0.3s; border:1px solid #f0f0f0;
        }
        .exam-card:hover {
            transform:translateX(8px); box-shadow:0 8px 24px rgba(0,0,0,0.12);
            border-color:#f39c12;
        }
        .exam-card h4 { font-size:1.1rem; margin-bottom:8px; font-weight:600; color:#1e293b; }
        .exam-card p { color:#64748b; font-size:0.85rem; margin-top:4px; }
        .btn-exam {
            background:linear-gradient(135deg,#f39c12,#e67e22); color:white;
            border:none; padding:12px 32px; border-radius:40px; cursor:pointer;
            font-weight:600; text-decoration:none; display:inline-block;
            transition:all 0.3s; box-shadow:0 4px 12px rgba(243,156,18,0.3);
        }
        .btn-exam:hover { transform:translateY(-2px); box-shadow:0 6px 20px rgba(243,156,18,0.4); }
        h3 { font-size:1.5rem; font-weight:700; color:#1e293b; margin-bottom:20px; }
    </style>
</head>
<body>
<div class="content-area">
    <div class="welcome-card">
        <h2>加油，<%= student.getLwmstudentname() %> 同学！</h2>
        <p><%= student.getLwmmajor() %>专业 · <%= student.getLwmclassname() %></p>
    </div>
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-num"><%= availExams.size() %></div>
            <div class="stat-label">待参加考试</div>
        </div>
        <div class="stat-card">
            <div class="stat-num"><%= myRecords.size() %></div>
            <div class="stat-label">考试记录</div>
        </div>
    </div>
    <h3>可参加的考试</h3>
    <% if (availExams.isEmpty()) { %>
        <p style="text-align:center;color:#94a3b8;padding:48px;background:white;border-radius:20px;">暂无安排给你的考试</p>
    <% } else {
        for (Map<String,Object> e : availExams) {
            String ts = (String) e.get("timeStatus");
            boolean canEnter = "during".equals(ts);
            String badgeText = "before".equals(ts) ? "未开始" : ("after".equals(ts) ? "已结束" : "进行中");
            String badgeColor = "before".equals(ts) ? "#64748b" : ("after".equals(ts) ? "#ef4444" : "#16a34a");
    %>
            <div class="exam-card">
                <div>
                    <h4><%= e.get("name") %> <span style="font-size:0.75rem;display:inline-block;padding:2px 10px;border-radius:10px;color:white;background:<%= badgeColor %>;"><%= badgeText %></span></h4>
                    <p><%= e.get("start") %> ~ <%= e.get("end") %> | <%= e.get("time") %>分钟 | <%= e.get("score") %>分</p>
                </div>
                <% if (canEnter) { %>
                    <a href="lwmTakeExam?paperId=<%= e.get("id") %>" class="btn-exam" target="rightFrame">开始考试</a>
                <% } else { %>
                    <span style="padding:10px 24px;border-radius:12px;font-weight:600;font-size:0.85rem;background:#e2e8f0;color:#94a3b8;"><%= "before".equals(ts) ? "等待开始" : "已结束" %></span>
                <% } %>
            </div>
    <% } } %>
</div>
</body>
</html>
