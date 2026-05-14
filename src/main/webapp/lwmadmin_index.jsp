<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmAdmin" %>
<%@ page import="com.example.lwmexam.dao.lwmexam.lwmstudentDAO" %>
<%@ page import="com.example.lwmexam.dao.lwmexam.lwmTeacherDAO" %>
<%@ page import="com.example.lwmexam.dao.lwmexam.lwmsubjectDAO" %>
<%@ page import="com.example.lwmexam.dao.lwmexam.lwmCourseArrangeDAO" %>
<%
    // 验证管理员登录状态
    lwmAdmin admin = (lwmAdmin) session.getAttribute("admin");
    String role = (String) session.getAttribute("role");

    if (admin == null || !"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 查询学生总数（绝对不报错写法）
    lwmstudentDAO dao = new lwmstudentDAO();
    int stuCount = dao.getStudentCount();
    request.setAttribute("stuCount", String.valueOf(stuCount));

    lwmTeacherDAO dao2 = new lwmTeacherDAO();
    int teacherCount = dao2.getTeacherCount();
    request.setAttribute("teacherCount", String.valueOf(teacherCount));

    lwmsubjectDAO dao3 = new lwmsubjectDAO();
    int subjectCount = dao3.getSubjectCount();
    request.setAttribute("subjectCount", String.valueOf(subjectCount));

    lwmCourseArrangeDAO dao4 = new lwmCourseArrangeDAO();
    int courseCount = dao4.getstudentcourseteacherCount();
    request.setAttribute("courseCount", String.valueOf(courseCount));
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

        .badge {
            background: #e0e7ff;
            color: #1e3a8a;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .action-btn {
            background: none;
            border: none;
            color: #3b82f6;
            cursor: pointer;
            margin-right: 12px;
            font-size: 0.9rem;
        }

        .action-btn:hover {
            color: #1e40af;
        }

        /* 模块切换 */
        .module-panel {
            display: none;
        }

        .module-panel.active {
            display: block;
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
            .content-area {
                padding: 20px;
            }
        }
    </style>
</head>
<body>


    <div class="content-area">
        <!-- 仪表盘模块 -->
        <div id="dashboard" class="module-panel active">
            <div class="welcome-card">
                <h2>欢迎回来，<%= admin.getLwmadminname() %>！</h2>
                <p>今天是 <%= new java.text.SimpleDateFormat("yyyy年MM月dd日 EEEE").format(new java.util.Date()) %></p>
            </div>
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon blue"><i class="fas fa-user-graduate"></i></div>
                    <div class="stat-number">${stuCount}</div>
                    <div class="stat-label">在校学生总数</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon green"><i class="fas fa-chalkboard-user"></i></div>
                    <div class="stat-number">${teacherCount}</div>
                    <div class="stat-label">在校教师总数</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon purple"><i class="fas fa-book-open"></i></div>
                    <div class="stat-number">${subjectCount}</div>
                    <div class="stat-label">课程总数</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon orange"><i class="fas fa-calendar-check"></i></div>
                    <div class="stat-number">${courseCount}</div>
                    <div class="stat-label">排课总数</div>
                </div>
            </div>
            <div class="data-card">
                <div class="card-header">
                    <h3><i class="fas fa-clock"></i> 最近考试安排</h3>
                    <button class="btn-primary" onclick="alert('跳转到考试安排页面')">查看全部</button>
                </div>
                <table>
                    <thead>
                    <tr><th>考试名称</th><th>日期</th><th>参考人数</th><th>状态</th></tr>
                    </thead>
                    <tbody>
                    <tr><td>数据库原理期中考试</td><td>2025-04-15</td><td>120</td><td><span class="badge">即将开始</span></td></tr>
                    <tr><td>数据结构期末考试</td><td>2025-04-20</td><td>95</td><td><span class="badge">组卷中</span></td></tr>
                    <tr><td>高等数学单元测试</td><td>2025-04-18</td><td>210</td><td><span class="badge">报名中</span></td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>