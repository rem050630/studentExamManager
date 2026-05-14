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
        .menu-item:hover { background:#f1f5f9; color:#059669; }
        .menu-item.active { background:linear-gradient(135deg,#ecfdf5,#d1fae5); color:#059669; font-weight:600; }
        .menu-item a { text-decoration:none; color:inherit; }
    </style>
</head>
<body>
<div class="sidebar">
    <div class="menu-item active">
        <i class="fas fa-tachometer-alt"></i>
        <a href="lwmteacher_index.jsp" target="rightFrame">主页</a>
    </div>
    <div class="menu-item">
        <i class="fas fa-database"></i>
        <a href="lwmteacherlist.jsp" target="rightFrame">试题信息</a>
    </div>
    <div class="menu-item">
        <i class="fas fa-calendar-alt"></i>
        <a href="#" target="rightFrame">考试管理</a>
    </div>
    <div class="menu-item">
        <i class="fas fa-search"></i>
        <a href="#" target="rightFrame">成绩查询</a>
    </div>
    <div class="menu-item">
        <i class="fas fa-chart-line"></i>
        <a href="#" target="rightFrame">统计分析</a>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // 获取所有菜单项
        const menuItems = document.querySelectorAll('.menu-item');

        // 为每个菜单项添加点击事件
        menuItems.forEach(item => {
            item.addEventListener('click', function(e) {
                // 如果点击的是链接内部，不阻止默认行为，但要处理高亮
                // 移除所有菜单项的active类
                menuItems.forEach(menu => {
                    menu.classList.remove('active');
                });
                // 为当前点击的菜单项添加active类
                this.classList.add('active');

                // 可选：如果有链接，可以保持链接跳转
                // 如果菜单项内有链接，且点击的不是链接本身，则模拟点击链接
                const link = this.querySelector('a');
                if (link && e.target.tagName !== 'A') {
                    // 如果点击的是菜单项其他区域，触发链接跳转
                    link.click();
                }
            });
        });

        // 根据当前URL高亮对应的菜单项
        const currentPath = window.location.pathname;
        const currentFile = currentPath.substring(currentPath.lastIndexOf('/') + 1);

        menuItems.forEach(item => {
            const link = item.querySelector('a');
            if (link) {
                const href = link.getAttribute('href');
                if (href === currentFile || (currentFile === 'lwmteacher_index.jsp' && href === 'lwmteacher_index.jsp')) {
                    menuItems.forEach(menu => menu.classList.remove('active'));
                    item.classList.add('active');
                }
            }
        });
    });
</script>
</body>
</html>