<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmStudent" %>
<%@ page import="com.example.lwmexam.service.lwmexam.MysqlConn" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.format.DateTimeParseException" %>
<%
    lwmStudent student = (lwmStudent) session.getAttribute("student");
    String role = (String) session.getAttribute("role");
    if (student == null || !"student".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Available exams (papers for student's class, not yet submitted)
    List<Map<String,Object>> availExams = new ArrayList<>();
    List<Map<String,Object>> myRecords = new ArrayList<>();
    List<Map<String,Object>> myScores = new ArrayList<>();

    MysqlConn db = new MysqlConn();
    try {
        ResultSet rs = db.doQuery(
            "SELECT p.* FROM lwmexampaper p " +
            "WHERE FIND_IN_SET(?, p.lwmclassname) " +
            "AND NOT EXISTS (SELECT 1 FROM lwmexamrecord r WHERE r.lwmpaperid = p.lwmpaperid AND r.lwmstudentid = ? AND r.lwmsubmitstatus IN (1, 2)) " +
            "ORDER BY p.lwmstarttime DESC",
            new Object[]{student.getLwmclassname(), student.getLwmstudentid()});
        while (rs.next()) {
            Map<String,Object> m = new HashMap<>();
            m.put("id", rs.getInt("lwmpaperid"));
            m.put("name", rs.getString("lwmpapername"));
            String start = rs.getString("lwmstarttime");
            String end = rs.getString("lwmendtime");
            m.put("start", start);
            m.put("end", end);
            m.put("time", rs.getInt("lwmexamtime"));
            m.put("score", rs.getInt("lwmexamsore"));

            // Determine time status: before, during, after
            String timeStatus = "during";
            if (start != null && !start.isEmpty() && end != null && !end.isEmpty()) {
                try {
                    String[] patterns = {"yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd HH:mm:ss.S", "yyyy-MM-dd'T'HH:mm", "yyyy-MM-dd HH:mm"};
                    LocalDateTime startTime = parseTimeStr(start, patterns);
                    LocalDateTime endTime = parseTimeStr(end, patterns);
                    LocalDateTime now = LocalDateTime.now();
                    if (startTime != null && endTime != null) {
                        if (now.isBefore(startTime)) timeStatus = "before";
                        else if (now.isAfter(endTime)) timeStatus = "after";
                    }
                } catch (Exception ignored) {}
            }
            m.put("timeStatus", timeStatus);
            availExams.add(m);
        }
    } catch (Exception e) { e.printStackTrace(); }
    db.close();

    db = new MysqlConn();
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
<%!
    private LocalDateTime parseTimeStr(String str, String[] patterns) {
        if (str == null || str.isEmpty()) return null;
        for (String p : patterns) {
            try { return LocalDateTime.parse(str, DateTimeFormatter.ofPattern(p)); } catch (DateTimeParseException ignored) {}
        }
        try { return LocalDateTime.parse(str.replace(" ", "T")); } catch (DateTimeParseException e) { return null; }
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
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
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #eef2f6 100%);
            color: #1e293b;
            line-height: 1.5;
        }

        /* 顶部导航栏优化 */
        .top-bar {
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 50%, #f39c12 100%);
            background-size: 200% 200%;
            animation: gradientShift 10s ease infinite;
            color: white;
            padding: 0 40px;
            height: 80px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 8px 32px rgba(0,0,0,0.12);
            position: sticky;
            top: 0;
            z-index: 1000;
        }

        @keyframes gradientShift {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }

        .logo-area {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .logo-icon {
            width: 48px;
            height: 48px;
            background: rgba(255,255,255,0.25);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            backdrop-filter: blur(10px);
            transition: transform 0.3s ease;
        }

        .logo-icon:hover {
            transform: scale(1.05);
        }

        .logo-icon i {
            font-size: 24px;
        }

        .logo-area h1 {
            font-size: 1.5rem;
            font-weight: 700;
            letter-spacing: -0.5px;
            margin-bottom: 4px;
        }

        .logo-area p {
            font-size: 0.75rem;
            opacity: 0.9;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 24px;
        }

        .user-name {
            display: flex;
            align-items: center;
            gap: 12px;
            background: rgba(255,255,255,0.2);
            padding: 8px 24px;
            border-radius: 50px;
            backdrop-filter: blur(10px);
            transition: all 0.3s ease;
        }

        .user-name:hover {
            background: rgba(255,255,255,0.3);
            transform: translateY(-2px);
        }

        .logout-btn {
            background: rgba(255,255,255,0.2);
            border: 1px solid rgba(255,255,255,0.3);
            color: white;
            padding: 8px 24px;
            border-radius: 50px;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            font-weight: 500;
        }

        .logout-btn:hover {
            background: rgba(255,255,255,0.3);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }

        /* 主布局优化 */
        .main-layout {
            display: flex;
            min-height: calc(100vh - 80px);
            background: transparent;
        }

        /* 侧边栏优化 */
        .sidebar {
            width: 300px;
            background: rgba(255,255,255,0.95);
            backdrop-filter: blur(20px);
            box-shadow: 4px 0 20px rgba(0,0,0,0.05);
            padding: 32px 0;
            border-right: 1px solid rgba(0,0,0,0.05);
        }

        .menu-item {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 14px 28px;
            margin: 6px 20px;
            border-radius: 16px;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            color: #475569;
            font-weight: 500;
            position: relative;
        }

        .menu-item i {
            width: 24px;
            font-size: 1.2rem;
            transition: transform 0.3s ease;
        }

        .menu-item:hover {
            background: linear-gradient(135deg, #fff5e6, #ffe8d4);
            color: #f39c12;
            transform: translateX(5px);
        }

        .menu-item:hover i {
            transform: scale(1.1);
        }

        .menu-item.active {
            background: linear-gradient(135deg, #f39c12, #e67e22);
            color: white;
            box-shadow: 0 8px 16px rgba(243, 156, 18, 0.3);
        }

        .menu-item.active::before {
            content: '';
            position: absolute;
            left: 0;
            top: 50%;
            transform: translateY(-50%);
            width: 4px;
            height: 60%;
            background: white;
            border-radius: 0 4px 4px 0;
        }

        /* 内容区域优化 */
        .content-area {
            flex: 1;
            padding: 32px 40px;
            overflow-y: auto;
            animation: fadeIn 0.5s ease;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* 欢迎卡片优化 */
        .welcome-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%);
            color: white;
            padding: 32px 40px;
            border-radius: 28px;
            margin-bottom: 32px;
            position: relative;
            overflow: hidden;
            box-shadow: 0 20px 40px rgba(0,0,0,0.15);
        }

        .welcome-card::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 1%, transparent 1%);
            background-size: 50px 50px;
            animation: shimmer 20s linear infinite;
        }

        @keyframes shimmer {
            from {
                transform: translateX(0) translateY(0);
            }
            to {
                transform: translateX(50px) translateY(50px);
            }
        }

        .welcome-card h2 {
            font-size: 1.8rem;
            margin-bottom: 12px;
            font-weight: 700;
            position: relative;
            z-index: 1;
        }

        .welcome-card p {
            font-size: 1rem;
            opacity: 0.95;
            position: relative;
            z-index: 1;
        }

        /* 统计卡片优化 */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 24px;
            margin-bottom: 32px;
        }

        .stat-card {
            background: white;
            padding: 28px 24px;
            border-radius: 24px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            border: 1px solid rgba(0,0,0,0.05);
            position: relative;
            overflow: hidden;
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #f39c12, #e67e22);
            transform: scaleX(0);
            transition: transform 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 28px rgba(0,0,0,0.12);
        }

        .stat-card:hover::before {
            transform: scaleX(1);
        }

        .stat-num {
            font-size: 2.5rem;
            font-weight: 800;
            background: linear-gradient(135deg, #f39c12, #e67e22);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
            margin-bottom: 8px;
        }

        .stat-label {
            color: #64748b;
            font-size: 0.9rem;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        /* 考试卡片优化 */
        .exam-card {
            background: white;
            border-radius: 20px;
            padding: 24px 28px;
            margin-bottom: 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            transition: all 0.3s ease;
            border: 1px solid #f0f0f0;
        }

        .exam-card:hover {
            transform: translateX(8px);
            box-shadow: 0 8px 24px rgba(0,0,0,0.12);
            border-color: #f39c12;
        }

        .exam-card h4 {
            font-size: 1.1rem;
            margin-bottom: 8px;
            font-weight: 600;
            color: #1e293b;
        }

        .exam-card p {
            color: #64748b;
            font-size: 0.85rem;
            margin-top: 4px;
        }

        .btn-exam {
            background: linear-gradient(135deg, #f39c12, #e67e22);
            color: white;
            border: none;
            padding: 12px 32px;
            border-radius: 40px;
            cursor: pointer;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(243, 156, 18, 0.3);
        }

        .btn-exam:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(243, 156, 18, 0.4);
        }

        /* 表格优化 */
        table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            background: white;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        }

        th {
            background: linear-gradient(135deg, #f8fafc, #f1f5f9);
            padding: 16px 20px;
            text-align: left;
            font-weight: 600;
            color: #475569;
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 2px solid #e2e8f0;
        }

        td {
            padding: 14px 20px;
            border-bottom: 1px solid #f1f5f9;
            font-size: 0.9rem;
            transition: background 0.2s ease;
        }

        tr:hover td {
            background: #fef9f0;
        }

        /* 徽章优化 */
        .badge {
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            display: inline-block;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }

        .badge-green {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
            box-shadow: 0 2px 8px rgba(16, 185, 129, 0.3);
        }

        .badge-blue {
            background: linear-gradient(135deg, #3b82f6, #2563eb);
            color: white;
            box-shadow: 0 2px 8px rgba(59, 130, 246, 0.3);
        }

        .badge-yellow {
            background: linear-gradient(135deg, #f59e0b, #d97706);
            color: white;
            box-shadow: 0 2px 8px rgba(245, 158, 11, 0.3);
        }

        /* 信息卡片优化 */
        .info-card {
            background: white;
            border-radius: 24px;
            padding: 32px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            border: 1px solid rgba(0,0,0,0.05);
        }

        .info-row {
            display: flex;
            padding: 16px 0;
            border-bottom: 1px solid #f1f5f9;
            transition: all 0.2s ease;
        }

        .info-row:hover {
            background: #fef9f0;
            padding-left: 12px;
        }

        .info-row .label {
            width: 100px;
            color: #64748b;
            font-weight: 600;
            font-size: 0.9rem;
        }

        .info-row div:last-child {
            color: #1e293b;
            font-weight: 500;
        }

        /* 滚动条美化 */
        ::-webkit-scrollbar {
            width: 8px;
            height: 8px;
        }

        ::-webkit-scrollbar-track {
            background: #f1f5f9;
            border-radius: 10px;
        }

        ::-webkit-scrollbar-thumb {
            background: linear-gradient(135deg, #f39c12, #e67e22);
            border-radius: 10px;
        }

        ::-webkit-scrollbar-thumb:hover {
            background: linear-gradient(135deg, #e67e22, #d35400);
        }

        /* 响应式优化 */
        @media (max-width: 768px) {
            .main-layout {
                flex-direction: column;
            }

            .sidebar {
                width: 100%;
                padding: 16px;
            }

            .menu-item {
                margin: 4px 0;
            }

            .content-area {
                padding: 20px;
            }

            .exam-card {
                flex-direction: column;
                gap: 16px;
                text-align: center;
            }

            table {
                font-size: 0.75rem;
            }

            th, td {
                padding: 10px 12px;
            }
        }

        /* 链接样式优化 */
        a {
            text-decoration: none;
            transition: all 0.2s ease;
        }

        a[href*="lwmViewExam"] {
            color: #3b82f6;
            font-weight: 500;
            position: relative;
        }

        a[href*="lwmViewExam"]:hover {
            color: #2563eb;
            text-decoration: underline;
        }

        a[href*="lwmDeleteExamRecord"] {
            color: #ef4444;
            font-weight: 500;
            margin-left: 12px;
        }

        a[href*="lwmDeleteExamRecord"]:hover {
            color: #dc2626;
            text-decoration: underline;
        }

        /* 空状态优化 */
        p[style*="color:#94a3b8"] {
            text-align: center;
            padding: 48px !important;
            background: white;
            border-radius: 20px;
            color: #94a3b8 !important;
            font-size: 0.95rem;
        }

        /* 模块面板切换动画 */
        .module-panel {
            display: none;
            animation: fadeIn 0.4s ease;
        }

        .module-panel.active {
            display: block;
        }

        /* 标题样式 */
        h3 {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 20px;
            background: linear-gradient(135deg, #1e293b, #334155);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
            letter-spacing: -0.3px;
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
            <span style="font-size:12px;">(<%= student.getLwmstudentno() %>)</span>
        </div>
        <a href="SystemExit" class="logout-btn" style="color:white;text-decoration:none;">退出</a>
    </div>
</div>

<div class="main-layout">
    <div class="sidebar">
        <div class="menu-item active" data-module="examCenter"><i class="fas fa-pen"></i> 考试中心</div>
        <div class="menu-item" data-module="myPapers"><i class="fas fa-file-alt"></i> 我的试卷</div>
        <a href="lwmMistakeBook" style="text-decoration:none;color:inherit;"><div class="menu-item"><i class="fas fa-book"></i> 我的错题本</div></a>
        <div class="menu-item" data-module="myInfo"><i class="fas fa-user"></i> 个人信息</div>
    </div>

    <div class="content-area">
        <!-- 考试中心 -->
        <div id="examCenter" class="module-panel active">
            <div class="welcome-card">
                <h2>加油，<%= student.getLwmstudentname() %> 同学！</h2>
                <p><%= student.getLwmmajor() %>专业 · <%= student.getLwmclassname() %></p>
            </div>
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-num"><%= availExams.size() %></div>
                    <div class="stat-label">待参加考试</div>
                </div>
                <div class="stat-card">
                    <div class="stat-num"><%= myRecords.size() %></div>
                    <div class="stat-label">考试记录</div>
                </div>
            </div>
            <h3 style="margin-bottom:16px;">可参加的考试</h3>
            <% if (availExams.isEmpty()) { %>
                <p style="color:#94a3b8;padding:20px;">暂无安排给你的考试</p>
            <% } else {
                for (Map<String,Object> e : availExams) {
                    String ts = (String) e.get("timeStatus");
                    boolean canEnter = "during".equals(ts);
                    String badgeText = "before".equals(ts) ? "未开始" : ("after".equals(ts) ? "已结束" : "进行中");
                    String badgeColor = "before".equals(ts) ? "#64748b" : ("after".equals(ts) ? "#ef4444" : "#16a34a");
            %>
                    <div class="exam-card">
                        <div>
                            <h4><%= e.get("name") %> <span style="font-size:0.75rem;display:inline-block;padding:2px 10px;border-radius:10px;color:white;background:<%= badgeColor %>;"><%= badgeText %></span></h4>
                            <p><%= e.get("start") %> ~ <%= e.get("end") %> | <%= e.get("time") %>分钟 | <%= e.get("score") %>分</p>
                        </div>
                        <% if (canEnter) { %>
                            <a href="lwmTakeExam?paperId=<%= e.get("id") %>" class="btn-exam">开始考试</a>
                        <% } else { %>
                            <span style="padding:10px 24px;border-radius:12px;font-weight:600;font-size:0.85rem;background:#e2e8f0;color:#94a3b8;"><%= "before".equals(ts) ? "等待开始" : "已结束" %></span>
                        <% } %>
                    </div>
            <% } } %>
        </div>

        <!-- 我的试卷 -->
        <div id="myPapers" class="module-panel">
            <h3 style="margin-bottom:16px;">我的考试记录</h3>
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
                                    <a href="lwmViewExam?recordId=<%= r.get("recordId") %>" style="color:#3b82f6;text-decoration:none;font-weight:500;">查看</a>
                                    <% if (status != 2) { %>
                                    <% } %>
                                <% } else { %>
                                    <span style="color:#94a3b8;">--</span>
                                <% } %>
                            </td>
                        </tr>
                <% } } %>
                </tbody>
            </table>
        </div>

        <!-- 个人信息 -->
        <div id="myInfo" class="module-panel">
            <h3 style="margin-bottom:16px;">个人信息</h3>
            <div class="info-card">
                <div class="info-row"><div class="label">学号</div><div><%= student.getLwmstudentno() %></div></div>
                <div class="info-row"><div class="label">姓名</div><div><%= student.getLwmstudentname() %></div></div>
                <div class="info-row"><div class="label">性别</div><div><%= student.getLwmgender() %></div></div>
                <div class="info-row"><div class="label">年级</div><div><%= student.getLwmgrade() %></div></div>
                <div class="info-row"><div class="label">专业</div><div><%= student.getLwmmajor() %></div></div>
                <div class="info-row"><div class="label">班级</div><div><%= student.getLwmclassname() %></div></div>
            </div>
        </div>
    </div>
</div>

<script>
    document.querySelectorAll('.menu-item').forEach(item => {
        item.addEventListener('click', function() {
            document.querySelectorAll('.menu-item').forEach(m => m.classList.remove('active'));
            this.classList.add('active');
            document.querySelectorAll('.module-panel').forEach(p => p.classList.remove('active'));
            document.getElementById(this.getAttribute('data-module')).classList.add('active');
        });
    });
    // Support ?tab= parameter to activate specific tab on load
    (function() {
        var params = new URLSearchParams(window.location.search);
        var tab = params.get('tab');
        if (tab) {
            var menuItem = document.querySelector('.menu-item[data-module="' + tab + '"]');
            if (menuItem) menuItem.click();
        }
    })();
</script>
</body>
</html>
