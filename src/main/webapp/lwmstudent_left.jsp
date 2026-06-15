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
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; }
        .sidebar { width:200px; background:white; box-shadow:2px 0 8px rgba(0,0,0,0.05); padding:24px 0; min-height:100vh; }
        .menu-item {
            display:flex; align-items:center; gap:12px; padding:12px 24px; margin:4px 16px;
            border-radius:12px; cursor:pointer; transition:all 0.3s; color:#475569;
        }
        .menu-item i { width:24px; font-size:1.2rem; }
        .menu-item:hover { background:#fff5e6; color:#f39c12; }
        .menu-item.active { background:linear-gradient(135deg,#f39c12,#e67e22); color:white; font-weight:600; box-shadow:0 4px 12px rgba(243,156,18,0.3); }
        .menu-item a { text-decoration:none; color:inherit; }
    </style>
</head>
<body>
<div class="sidebar">
    <div class="menu-item active">
        <i class="fas fa-pen"></i>
        <a href="lwmstudent_index.jsp" target="rightFrame">考试中心</a>
    </div>
    <div class="menu-item">
        <i class="fas fa-file-alt"></i>
        <a href="lwmstudent_paper.jsp" target="rightFrame">我的试卷</a>
    </div>
    <div class="menu-item">
        <i class="fas fa-book"></i>
        <a href="lwmMistakeBook" target="rightFrame">我的错题本</a>
    </div>
    <div class="menu-item">
        <i class="fas fa-user"></i>
        <a href="lwmstudent_message.jsp" target="rightFrame">个人信息</a>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const menuItems = document.querySelectorAll('.menu-item');
        menuItems.forEach(item => {
            item.addEventListener('click', function(e) {
                menuItems.forEach(menu => menu.classList.remove('active'));
                this.classList.add('active');
                const link = this.querySelector('a');
                if (link && e.target.tagName !== 'A') {
                    link.click();
                }
            });
        });
    });
</script>
</body>
</html>
