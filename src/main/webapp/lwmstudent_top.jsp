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
    <title>学生学习中心</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family: 'Inter',sans-serif; }
        .top-bar {
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 50%, #f39c12 100%);
            background-size: 200% 200%;
            animation: gradientShift 10s ease infinite;
            color:white; height:70px; padding:0 32px;
            display:flex; align-items:center; justify-content:space-between;
            box-shadow:0 2px 10px rgba(0,0,0,0.1);
        }
        @keyframes gradientShift {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }
        .logo-area { display:flex; align-items:center; gap:16px; }
        .logo-icon {
            width:48px; height:48px; background:rgba(255,255,255,0.25);
            border-radius:16px; display:flex; align-items:center; justify-content:center;
            backdrop-filter:blur(10px);
        }
        .logo-icon i { font-size:24px; }
        .logo-text h1 { font-size:1.5rem; font-weight:700; letter-spacing:-0.5px; margin-bottom:4px; }
        .logo-text p { font-size:0.75rem; opacity:0.9; }
        .user-info { display:flex; align-items:center; gap:24px; }
        .user-name {
            display:flex; align-items:center; gap:12px;
            background:rgba(255,255,255,0.2); padding:8px 24px;
            border-radius:50px; backdrop-filter:blur(10px);
        }
        .logout-area { color:white; font-size:16px; }
        .logout-area a { color:white; text-decoration:none; padding:8px 20px; background:rgba(255,255,255,0.2); border-radius:50px; }
    </style>
</head>
<body>
<div class="top-bar">
    <div class="logo-area">
        <div class="logo-icon"><i class="fas fa-user-graduate"></i></div>
        <div class="logo-text">
            <h1>高校在线考试系统</h1>
            <p>学生学习中心</p>
        </div>
    </div>
    <div class="user-info">
        <div class="user-name">
            <i class="fas fa-user"></i>
            <span><%= student.getLwmstudentname() %></span>
            <span style="font-size:12px;">(<%= student.getLwmstudentno() %>)</span>
        </div>
        <div class="logout-area">
            <a href="SystemExit" target="_parent" onclick="return confirm('确定退出？')"><i class="fas fa-sign-out-alt"></i> 退出</a>
        </div>
    </div>
</div>
</body>
</html>
