<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmStudent" %>
<%@ page import="com.example.lwmexam.service.lwmexam.MysqlConn" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.*" %>
<%
    lwmStudent student = (lwmStudent) session.getAttribute("student");
    String role = (String) session.getAttribute("role");
    if (student == null || !"student".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Map<String,Object>> myRecords = new ArrayList<>();
    MysqlConn db = new MysqlConn();
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
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的试卷</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; color:#1e293b; }
        .content-area { padding:28px 32px; overflow-y:auto; }
        table { width:100%; border-collapse:separate; border-spacing:0; background:white; border-radius:20px; overflow:hidden; box-shadow:0 4px 12px rgba(0,0,0,0.08); }
        th { background:linear-gradient(135deg,#f8fafc,#f1f5f9); padding:16px 20px; text-align:left; font-weight:600; color:#475569; font-size:0.85rem; text-transform:uppercase; letter-spacing:0.5px; border-bottom:2px solid #e2e8f0; }
        td { padding:14px 20px; border-bottom:1px solid #f1f5f9; font-size:0.9rem; }
        tr:hover td { background:#fef9f0; }
        .badge { padding:6px 14px; border-radius:20px; font-size:0.75rem; font-weight:600; display:inline-block; }
        .badge-blue { background:linear-gradient(135deg,#3b82f6,#2563eb); color:white; }
        .badge-green { background:linear-gradient(135deg,#10b981,#059669); color:white; }
        .badge-yellow { background:linear-gradient(135deg,#f59e0b,#d97706); color:white; }
        h3 { font-size:1.5rem; font-weight:700; color:#1e293b; margin-bottom:20px; }
        a { text-decoration:none; transition:all 0.2s; }
        a[href*="lwmViewExam"] { color:#3b82f6; font-weight:500; }
        a[href*="lwmViewExam"]:hover { color:#2563eb; text-decoration:underline; }
    </style>
</head>
<body>
<div class="content-area">
    <h3>我的考试记录</h3>
    <table>
        <thead><tr><th>试卷名称</th><th>考试时间</th><th>状态</th><th>成绩</th><th>操作</th></tr></thead>
        <tbody>
        <% if (myRecords.isEmpty()) { %>
            <tr><td colspan="5" style="text-align:center;color:#94a3b8;padding:24px;">暂无考试记录</td></tr>
        <% } else {
            for (Map<String,Object> r : myRecords) {
                int status = (int) r.get("status");
                Object scoreObj = r.get("score"); %>
                <tr>
                    <td><%= r.get("paperName") %></td>
                    <td><%= r.get("startTime") %></td>
                    <td>
                        <% if (status == 2) { %>
                            <span class="badge badge-blue">已批阅</span>
                        <% } else if (status == 1) { %>
                            <span class="badge badge-green">已提交</span>
                        <% } else { %>
                            <span class="badge badge-yellow">未提交</span>
                        <% } %>
                    </td>
                    <td><strong><%= status == 2 ? (scoreObj != null ? scoreObj + "分" : "--") : (status == 1 ? "待批阅" : "--") %></strong></td>
                    <td>
                        <% if (status >= 1) { %>
                            <a href="lwmViewExam?recordId=<%= r.get("recordId") %>">查看</a>
                        <% } else { %>
                            <span style="color:#94a3b8;">--</span>
                        <% } %>
                    </td>
                </tr>
        <% } } %>
        </tbody>
    </table>
</div>
</body>
</html>
