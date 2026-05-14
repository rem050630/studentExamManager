<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmStudent" %>
<%
    lwmStudent student = (lwmStudent) session.getAttribute("student");
    String role = (String) session.getAttribute("role");

    if (student == null || !"student".equals(role)) {
        response.sendRedirect("lwm_login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>高校在线考试系统 - 学生学习中心</title>
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

        .top-bar {
            background: linear-gradient(135deg, #f59e0b, #d97706);
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

        .logout-btn {
            background: rgba(255,255,255,0.2);
            border: none;
            color: white;
            padding: 8px 20px;
            border-radius: 40px;
            cursor: pointer;
        }

        .main-layout {
            display: flex;
            min-height: calc(100vh - 70px);
        }

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

        .menu-item:hover {
            background: #fef3c7;
            color: #f59e0b;
        }

        .menu-item.active {
            background: linear-gradient(135deg, #fffbeb, #fef3c7);
            color: #f59e0b;
            font-weight: 600;
        }

        .content-area {
            flex: 1;
            padding: 28px 32px;
            overflow-y: auto;
        }

        .welcome-card {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
            color: white;
            padding: 28px 32px;
            border-radius: 24px;
            margin-bottom: 28px;
        }

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
        }

        .exam-card {
            background: white;
            border-radius: 16px;
            padding: 20px;
            margin-bottom: 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }

        .btn-exam {
            background: linear-gradient(135deg, #f59e0b, #d97706);
            color: white;
            border: none;
            padding: 10px 24px;
            border-radius: 12px;
            cursor: pointer;
        }

        .data-card {
            background: white;
            border-radius: 20px;
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #e2e8f0;
        }

        .module-panel {
            display: none;
        }

        .module-panel.active {
            display: block;
        }

        .score-high {
            color: #f59e0b;
            font-weight: bold;
        }
    </style>
</head>
<body>
<div class="top-bar">
    <div class="logo-area">
        <div class="logo-icon"><i class="fas fa-user-graduate"></i></div>
        <div><h1>高校在线考试系统</h1><p>学生学习中心</p></div>
    </div>
    <div class="user-info">
        <div class="user-name">
            <i class="fas fa-user"></i>
            <span><%= student.getLwmstudentname() %></span>
            <span style="font-size: 12px;">(<%= student.getLwmstudentno() %>)</span>
        </div>
        <button class="logout-btn" onclick="logout()">退出登录</button>
    </div>
</div>

<div class="main-layout">
    <div class="sidebar">
        <div class="menu-item active" data-module="examCenter">📝 考试中心</div>
        <div class="menu-item" data-module="myPapers">📄 我的试卷</div>
        <div class="menu-item" data-module="personalScore">📊 个人成绩</div>
    </div>

    <div class="content-area">
        <div id="examCenter" class="module-panel active">
            <div class="welcome-card">
                <h2>加油，<%= student.getLwmstudentname() %> 同学！</h2>
                <p><%= student.getLwmmajor() %>专业 · <%= student.getLwmclassname() %></p>
            </div>
            <div class="exam-card">
                <div><h3>数据库原理 期中测试</h3><p>2025-04-15 14:00-16:00 | 120分钟</p></div>
                <button class="btn-exam" onclick="alert('开始考试')">开始考试</button>
            </div>
            <div class="exam-card">
                <div><h3>高等数学 单元测验</h3><p>2025-04-17 10:00-11:30 | 90分钟</p></div>
                <button class="btn-exam" onclick="alert('进入考场')">进入考场</button>
            </div>
        </div>

        <div id="myPapers" class="module-panel">
            <div class="data-card">
                <h3>我的试卷记录</h3>
                <table>
                    <thead><tr><th>试卷名称</th><th>考试时间</th><th>得分</th><th>操作</th></tr></thead>
                    <tbody>
                    <tr><td>数据库原理期末</td><td>2025-01-10</td><td>87</td><td><button class="action-btn" onclick="alert('查看详情')">查看详情</button></td></tr>
                    <tr><td>数据结构期中</td><td>2024-12-05</td><td>92</td><td><button onclick="alert('查看详情')">查看详情</button></td></tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div id="personalScore" class="module-panel">
            <div class="data-card">
                <h3>个人成绩单</h3>
                <table>
                    <thead><tr><th>课程</th><th>成绩</th><th>学分绩点</th><th>班级排名</th></tr></thead>
                    <tbody>
                    <tr><td>数据库原理</td><td class="score-high">87</td><td>3.7</td><td>12/85</td></tr>
                    <tr><td>数据结构</td><td class="score-high">92</td><td>4.0</td><td>3/82</td></tr>
                    <tr><td>高等数学</td><td>78</td><td>3.0</td><td>45/120</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script>
    document.querySelectorAll('.menu-item').forEach(item => {
        item.addEventListener('click', function() {
            const module = this.getAttribute('data-module');
            document.querySelectorAll('.menu-item').forEach(m => m.classList.remove('active'));
            this.classList.add('active');
            document.querySelectorAll('.module-panel').forEach(p => p.classList.remove('active'));
            document.getElementById(module).classList.add('active');
        });
    });

    function logout() {
        if(confirm('确定要退出登录吗？')) {
            window.location.href = 'SystemExit';
        }
    }
</script>
</body>
</html>