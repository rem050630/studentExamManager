<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmTeacher" %>
<%
    lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
    String role = (String) session.getAttribute("role");
    if (teacher == null || !"teacher".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>教师工作台</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family: 'Inter',sans-serif; }
        .top-bar {
            background: linear-gradient(135deg, #059669, #10b981);
            color:white; height:70px; padding:0 32px;
            display:flex; align-items:center; justify-content:space-between;
            box-shadow:0 2px 10px rgba(0,0,0,0.1);
        }
        .logo-area { display:flex; align-items:center; gap:12px; }
        .logo-icon { width:40px; height:40px; background:rgba(255,255,255,0.2); border-radius:12px; display:flex; align-items:center; justify-content:center; }
        .logo-icon i { font-size:24px; }
        .logo-text h1 { font-size:1.3rem; font-weight:600; }
        .logo-text p { font-size:0.7rem; opacity:0.8; }
        .user-info { display:flex; align-items:center; gap:20px; }
        .user-name { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.15); padding:8px 20px; border-radius:40px; }
        .logout-area { color:white; font-size:16px; cursor:pointer; }
        .logout-area a { color:white; text-decoration:none; }
    </style>
</head>
<body>
<div class="top-bar">
    <div class="logo-area">
        <div class="logo-icon"><i class="fas fa-chalkboard-user"></i></div>
        <div class="logo-text">
            <h1>高校在线考试系统</h1>
            <p>教师工作台</p>
        </div>
    </div>
    <div class="user-info">
        <div class="user-name">
            <i class="fas fa-user"></i>
            <span><%= teacher.getLwmteachername() %> 老师</span>
        </div>
        <div class="logout-area">
            <i class="fas fa-sign-out-alt"></i>
            <a href="SystemExit" target="_parent" onclick="return confirm('确定退出？')">退出</a>
        </div>
    </div>
</div>
</body>
</html>