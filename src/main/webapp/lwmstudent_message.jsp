<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmStudent" %>
<%
    lwmStudent student = (lwmStudent) session.getAttribute("student");
    String role = (String) session.getAttribute("role");
    if (student == null || !"student".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>个人信息</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; color:#1e293b; }
        .content-area { padding:28px 32px; overflow-y:auto; }
        .info-card {
            background:white; border-radius:24px; padding:32px;
            box-shadow:0 4px 12px rgba(0,0,0,0.08); border:1px solid rgba(0,0,0,0.05);
        }
        .info-row {
            display:flex; padding:16px 0; border-bottom:1px solid #f1f5f9;
            transition:all 0.2s;
        }
        .info-row:hover { background:#fef9f0; padding-left:12px; }
        .info-row .label { width:100px; color:#64748b; font-weight:600; font-size:0.9rem; }
        .info-row div:last-child { color:#1e293b; font-weight:500; }
        h3 { font-size:1.5rem; font-weight:700; color:#1e293b; margin-bottom:20px; }
    </style>
</head>
<body>
<div class="content-area">
    <h3>个人信息</h3>
    <div class="info-card">
        <div class="info-row"><div class="label">学号</div><div><%= student.getLwmstudentno() %></div></div>
        <div class="info-row"><div class="label">姓名</div><div><%= student.getLwmstudentname() %></div></div>
        <div class="info-row"><div class="label">性别</div><div><%= student.getLwmgender() %></div></div>
        <div class="info-row"><div class="label">年级</div><div><%= student.getLwmgrade() %></div></div>
        <div class="info-row"><div class="label">专业</div><div><%= student.getLwmmajor() %></div></div>
        <div class="info-row"><div class="label">班级</div><div><%= student.getLwmclassname() %></div></div>
    </div>
</div>
</body>
</html>
