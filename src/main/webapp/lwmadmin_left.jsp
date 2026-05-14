<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmAdmin" %>
<%
    // 验证管理员登录状态
    lwmAdmin admin = (lwmAdmin) session.getAttribute("admin");
    String role = (String) session.getAttribute("role");

    if (admin == null || !"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>高校在线考试系统 - 管理员控制台</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: #f0f2f5;
            color: #1e293b;
        }

        /* 顶部导航栏 */
        .top-bar {
            background: linear-gradient(135deg, #1e3a8a, #1e40af);
            color: white;
            padding: 0 32px;
            height: 70px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .logo-area {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .logo-icon {
            width: 40px;
            height: 40px;
            background: rgba(255,255,255,0.2);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .logo-icon i {
            font-size: 24px;
        }

        .logo-text h1 {
            font-size: 1.3rem;
            font-weight: 600;
        }

        .logo-text p {
            font-size: 0.7rem;
            opacity: 0.8;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .user-name {
            display: flex;
            align-items: center;
            gap: 10px;
            background: rgba(255,255,255,0.15);
            padding: 8px 20px;
            border-radius: 40px;
        }

        .user-name i {
            font-size: 18px;
        }

        .logout-btn {
            background: rgba(255,255,255,0.2);
            border: none;
            color: white;
            padding: 8px 20px;
            border-radius: 40px;
            cursor: pointer;
            transition: all 0.3s;
            font-size: 14px;
        }

        .logout-btn:hover {
            background: rgba(255,255,255,0.3);
        }

        /* 主体布局 */
        .main-layout {
            display: flex;
            min-height: calc(100vh - 70px);
        }

        /* 侧边栏 */
        .sidebar {
            width: 280px;
            background: white;
            box-shadow: 2px 0 8px rgba(0,0,0,0.05);
            padding: 24px 0;
        }

        .menu-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 24px;
            margin: 4px 16px;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.3s;
            color: #475569;
        }

        .menu-item i {
            width: 24px;
            font-size: 1.2rem;
        }


        .menu-item:hover {
            background: #f1f5f9;
            color: #1e40af;
        }

        .menu-item.active {
            background: linear-gradient(135deg, #eef2ff, #e0e7ff);
            color: #1e3a8a;
            font-weight: 600;
        }

        /* 内容区域 */
        .content-area {
            flex: 1;
            padding: 28px 32px;
            overflow-y: auto;
        }

        /* 欢迎卡片 */
        .welcome-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 28px 32px;
            border-radius: 24px;
            margin-bottom: 28px;
        }

        .welcome-card h2 {
            font-size: 1.8rem;
            margin-bottom: 8px;
        }

        /* 统计卡片 */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 20px;
            margin-bottom: 28px;
        }

        .stat-card {
            background: white;
            padding: 24px;
            border-radius: 20px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }

        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        }

        .stat-icon {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, #eef2ff, #e0e7ff);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 16px;
        }

        .stat-icon i {
            font-size: 28px;
            color: #1e3a8a;
        }

        .stat-number {
            font-size: 2rem;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 8px;
        }

        .stat-label {
            color: #64748b;
            font-size: 0.9rem;
        }

        /* 数据表格 */
        .data-card {
            background: white;
            border-radius: 20px;
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 16px;
            border-bottom: 2px solid #e2e8f0;
        }

        .card-header h3 {
            font-size: 1.3rem;
            color: #0f172a;
        }

        .btn-primary {
            background: linear-gradient(135deg, #1e3a8a, #1e40af);
            color: white;
            border: none;
            padding: 8px 20px;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.3s;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(30,58,138,0.3);
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th {
            text-align: left;
            padding: 12px;
            background: #f8fafc;
            color: #475569;
            font-weight: 600;
            border-bottom: 2px solid #e2e8f0;
        }

        td {
            padding: 12px;
            border-bottom: 1px solid #e2e8f0;
        }




        @media (max-width: 768px) {
            .sidebar {
                width: 80px;
            }
            .menu-item span {
                display: none;
            }
            .menu-item {
                justify-content: center;
            }
        }
    </style>
</head>
<body>
<div class="main-layout">
    <div class="sidebar" style="width: 200px">
        <div class="menu-item active">
            <i class="fas fa-tachometer-alt" style="width: 24px;"></i>
            <a href="lwmadmin_index.jsp" target="rightFrame" style="text-decoration: none; color: inherit;">主页</a>
        </div>
        <div class="menu-item">
            <i class="fas fa-user-graduate" style="width: 24px;"></i>
            <a href="lwmstudent_xx" target="rightFrame" style="text-decoration: none; color: inherit;">学生信息</a>
        </div>
        <div class="menu-item">
            <i class="fas fa-chalkboard-user" style="width: 24px;"></i>
            <a href="lwmteacher_xx" target="rightFrame" style="text-decoration: none; color: inherit;">教师信息</a>
        </div>
        <div class="menu-item">
            <i class="fas fa-book-open" style="width: 24px;"></i>
            <a href="lwmsubject_xx" target="rightFrame" style="text-decoration: none; color: inherit;">课程信息</a>
        </div>
        <div class="menu-item">
            <i class="fas fa-calendar-alt" style="width: 24px;"></i>
            <a href="lwmcourse_xx" target="rightFrame" style="text-decoration: none; color: inherit;">排课信息</a>
        </div>
        <div class="menu-item">
            <i class="fas fa-file-alt" style="width: 24px;"></i>
            <a href="#" target="rightFrame" style="text-decoration: none; color: inherit;">试卷信息</a>
        </div>
        <div class="menu-item">
            <i class="fas fa-chart-line" style="width: 24px;"></i>
            <a href="#" target="rightFrame" style="text-decoration: none; color: inherit;">成绩管理</a>
        </div>
    </div>
</div>
<script>
    // 侧边栏菜单点击高亮功能
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
                if (href === currentFile || (currentFile === 'lwmadmin_index.jsp' && href === 'lwmadmin_index.jsp')) {
                    menuItems.forEach(menu => menu.classList.remove('active'));
                    item.classList.add('active');
                }
            }
        });
    });
</script>
</body>
</html>