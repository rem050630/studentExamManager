<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmTeacher" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%
    lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
    String role = (String) session.getAttribute("role");
    if (teacher == null || !"teacher".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
    String teacherName = teacher.getLwmteachername() != null ? teacher.getLwmteachername() : "老师";
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>教师主页</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; color:#1e293b; }
        .content-area { flex:1; padding:28px 32px; overflow-y:auto; }
        .welcome-card {
            background:linear-gradient(135deg,#10b981,#059669); color:white;
            padding:28px 32px; border-radius:24px; margin-bottom:28px;
        }
        .welcome-card h2 { font-size:1.8rem; margin-bottom:8px; }
        .stats-grid {
            display:grid; grid-template-columns:repeat(auto-fit,minmax(240px,1fr));
            gap:20px; margin-bottom:28px;
        }
        .stat-card {
            background:white; padding:24px; border-radius:20px;
            box-shadow:0 1px 3px rgba(0,0,0,0.1); transition:transform 0.2s;
        }
        .stat-card:hover { transform:translateY(-4px); }
        .stat-icon {
            width:50px; height:50px; background:#ecfdf5; border-radius:16px;
            display:flex; align-items:center; justify-content:center; margin-bottom:16px;
        }
        .stat-icon i { font-size:28px; color:#059669; }
        .stat-number { font-size:2rem; font-weight:700; color:#0f172a; margin-bottom:8px; }
        .stat-label { color:#64748b; font-size:0.9rem; }
        .data-card {
            background:white; border-radius:20px; padding:24px; margin-bottom:24px;
            box-shadow:0 1px 3px rgba(0,0,0,0.1);
        }
        .card-header {
            display:flex; justify-content:space-between; align-items:center;
            margin-bottom:20px; padding-bottom:16px; border-bottom:2px solid #e2e8f0;
        }
        .card-header h3 { font-size:1.3rem; color:#0f172a; }
        .btn-primary {
            background:linear-gradient(135deg,#059669,#10b981); color:white; border:none;
            padding:8px 20px; border-radius:12px; cursor:pointer;
        }
        table { width:100%; border-collapse:collapse; }
        th { text-align:left; padding:12px; background:#f8fafc; color:#475569; font-weight:600; border-bottom:2px solid #e2e8f0; }
        td { padding:12px; border-bottom:1px solid #e2e8f0; }
        .badge { background:#d1fae5; color:#059669; padding:4px 12px; border-radius:20px; font-size:0.8rem; font-weight:600; }
    </style>
</head>
<body>
<div class="content-area">
    <div class="welcome-card">
        <h2>欢迎回来，<%= teacherName %> 老师！</h2>
        <p><%= new SimpleDateFormat("yyyy年MM月dd日 EEEE").format(new Date()) %></p>
    </div>

    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-question-circle"></i></div>
            <div class="stat-number">156</div>
            <div class="stat-label">试题总数</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-file-alt"></i></div>
            <div class="stat-number">8</div>
            <div class="stat-label">进行中考试</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-check-circle"></i></div>
            <div class="stat-number">23</div>
            <div class="stat-label">待批阅试卷</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-users"></i></div>
            <div class="stat-number">156</div>
            <div class="stat-label">所授学生总数</div>
        </div>
    </div>

    <div class="data-card">
        <div class="card-header">
            <h3><i class="fas fa-clock"></i> 近期考试安排</h3>
            <button class="btn-primary">查看全部</button>
        </div>
        <table>
            <thead>
            <tr><th>考试名称</th><th>日期</th><th>班级</th><th>状态</th></tr>
            </thead>
            <tbody>
            <tr><td>数据库期中考试</td><td>2025-04-15</td><td>计科2101</td><td><span class="badge">即将开始</span></td></tr>
            <tr><td>数据结构期末考试</td><td>2025-04-20</td><td>软工2102</td><td><span class="badge">组卷中</span></td></tr>
            </tbody>
        </table>
    </div>
</div>
</body>
</html>