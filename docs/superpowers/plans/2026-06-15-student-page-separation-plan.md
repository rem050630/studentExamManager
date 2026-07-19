# Student Page Separation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor the single-page `lwmstudent_main.jsp` into a frameset-based layout following the teacher-side pattern, separating exam center, my papers, and personal info into their own pages.

**Architecture:** Frameset layout matching `lwmteacher_main.jsp` — top frame (88px) + left sidebar (187px) + right content area. Navigation uses `<a target="rightFrame">`. Each content page carries its own styles and session/auth guard.

**Tech Stack:** JSP + HTML frameset + inline CSS (orange/gold student theme)

---

### Task 1: Rewrite lwmstudent_main.jsp as frameset

**Files:**
- Modify: `src/main/webapp/lwmstudent_main.jsp`

- [ ] **Step 1: Replace entire file content with frameset structure**

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>
<frameset rows="88,*" cols="*" frameborder="no" border="0" framespacing="0">
    <frame src="lwmstudent_top.jsp" name="topFrame" scrolling="No" noresize="noresize" id="topFrame" title="topFrame" />
    <frameset cols="187,*" frameborder="no" border="0" framespacing="0">
        <frame src="lwmstudent_left.jsp" name="leftFrame" scrolling="No" noresize="noresize" id="leftFrame" title="leftFrame" />
        <frame src="lwmstudent_index.jsp" name="rightFrame" id="rightFrame" title="rightFrame" />
    </frameset>
</frameset>
<noframes><body>
</body></noframes>
</html>
```

- [ ] **Step 2: Verify the file was written correctly**

Run: `wc -l src/main/webapp/lwmstudent_main.jsp`
Expected: ~17 lines (frameset only)

- [ ] **Step 3: Commit**

```bash
git add src/main/webapp/lwmstudent_main.jsp
git commit -m "refactor: convert lwmstudent_main.jsp to frameset layout"
```

---

### Task 2: Rewrite lwmstudent_top.jsp with top bar

**Files:**
- Modify: `src/main/webapp/lwmstudent_top.jsp`

- [ ] **Step 1: Write the top bar page with session guard and orange/gold theme**

```jsp
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
```

- [ ] **Step 2: Commit**

```bash
git add src/main/webapp/lwmstudent_top.jsp
git commit -m "feat: write lwmstudent_top.jsp with student top bar"
```

---

### Task 3: Rewrite lwmstudent_left.jsp with correct sidebar navigation

**Files:**
- Modify: `src/main/webapp/lwmstudent_left.jsp`

- [ ] **Step 1: Write the left sidebar with proper links, session guard, and styling**

```jsp
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
```

- [ ] **Step 2: Commit**

```bash
git add src/main/webapp/lwmstudent_left.jsp
git commit -m "feat: write lwmstudent_left.jsp with correct sidebar navigation"
```

---

### Task 4: Rewrite lwmstudent_index.jsp with exam center content

**Files:**
- Modify: `src/main/webapp/lwmstudent_index.jsp`

- [ ] **Step 1: Write the exam center page with welcome card, stats, and available exams list**

```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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

    List<Map<String,Object>> availExams = new ArrayList<>();
    List<Map<String,Object>> myRecords = new ArrayList<>();

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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; color:#1e293b; }
        .content-area { flex:1; padding:28px 32px; overflow-y:auto; }
        .welcome-card {
            background:linear-gradient(135deg,#667eea 0%,#764ba2 50%,#f093fb 100%);
            color:white; padding:32px 40px; border-radius:28px;
            margin-bottom:32px; position:relative; overflow:hidden;
            box-shadow:0 20px 40px rgba(0,0,0,0.15);
        }
        .welcome-card h2 { font-size:1.8rem; margin-bottom:12px; font-weight:700; position:relative; z-index:1; }
        .welcome-card p { font-size:1rem; opacity:0.95; position:relative; z-index:1; }
        .stats-grid {
            display:grid; grid-template-columns:repeat(auto-fit,minmax(240px,1fr));
            gap:24px; margin-bottom:32px;
        }
        .stat-card {
            background:white; padding:28px 24px; border-radius:24px;
            box-shadow:0 4px 12px rgba(0,0,0,0.08); transition:all 0.3s;
            border:1px solid rgba(0,0,0,0.05);
        }
        .stat-card:hover { transform:translateY(-5px); box-shadow:0 12px 28px rgba(0,0,0,0.12); }
        .stat-num {
            font-size:2.5rem; font-weight:800;
            background:linear-gradient(135deg,#f39c12,#e67e22);
            -webkit-background-clip:text; background-clip:text;
            color:transparent; margin-bottom:8px;
        }
        .stat-label {
            color:#64748b; font-size:0.9rem; font-weight:500;
            text-transform:uppercase; letter-spacing:0.5px;
        }
        .exam-card {
            background:white; border-radius:20px; padding:24px 28px;
            margin-bottom:16px; display:flex; justify-content:space-between;
            align-items:center; box-shadow:0 2px 8px rgba(0,0,0,0.06);
            transition:all 0.3s; border:1px solid #f0f0f0;
        }
        .exam-card:hover {
            transform:translateX(8px); box-shadow:0 8px 24px rgba(0,0,0,0.12);
            border-color:#f39c12;
        }
        .exam-card h4 { font-size:1.1rem; margin-bottom:8px; font-weight:600; color:#1e293b; }
        .exam-card p { color:#64748b; font-size:0.85rem; margin-top:4px; }
        .btn-exam {
            background:linear-gradient(135deg,#f39c12,#e67e22); color:white;
            border:none; padding:12px 32px; border-radius:40px; cursor:pointer;
            font-weight:600; text-decoration:none; display:inline-block;
            transition:all 0.3s; box-shadow:0 4px 12px rgba(243,156,18,0.3);
        }
        .btn-exam:hover { transform:translateY(-2px); box-shadow:0 6px 20px rgba(243,156,18,0.4); }
        h3 { font-size:1.5rem; font-weight:700; color:#1e293b; margin-bottom:20px; }
    </style>
</head>
<body>
<div class="content-area">
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
    <h3>可参加的考试</h3>
    <% if (availExams.isEmpty()) { %>
        <p style="text-align:center;color:#94a3b8;padding:48px;background:white;border-radius:20px;">暂无安排给你的考试</p>
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
                    <a href="lwmTakeExam?paperId=<%= e.get("id") %>" class="btn-exam" target="rightFrame">开始考试</a>
                <% } else { %>
                    <span style="padding:10px 24px;border-radius:12px;font-weight:600;font-size:0.85rem;background:#e2e8f0;color:#94a3b8;"><%= "before".equals(ts) ? "等待开始" : "已结束" %></span>
                <% } %>
            </div>
    <% } } %>
</div>
</body>
</html>
```

- [ ] **Step 2: Commit**

```bash
git add src/main/webapp/lwmstudent_index.jsp
git commit -m "feat: write lwmstudent_index.jsp with exam center and available exams"
```

---

### Task 5: Rewrite lwmstudent_paper.jsp with exam records

**Files:**
- Modify: `src/main/webapp/lwmstudent_paper.jsp`

- [ ] **Step 1: Write the my papers page with exam records table**

```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmStudent" %>
<%@ page import="com.example.lwmexam.service.lwmexam.MysqlConn" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.*" %>
<%
    lwmStudent student = (lwmStudent) session.getAttribute("student");
    String role = (String) session.getAttribute("role");
    if (student == null || !"student".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Map<String,Object>> myRecords = new ArrayList<>();
    MysqlConn db = new MysqlConn();
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
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; color:#1e293b; }
        .content-area { flex:1; padding:28px 32px; overflow-y:auto; }
        table { width:100%; border-collapse:separate; border-spacing:0; background:white; border-radius:20px; overflow:hidden; box-shadow:0 4px 12px rgba(0,0,0,0.08); }
        th { background:linear-gradient(135deg,#f8fafc,#f1f5f9); padding:16px 20px; text-align:left; font-weight:600; color:#475569; font-size:0.85rem; text-transform:uppercase; letter-spacing:0.5px; border-bottom:2px solid #e2e8f0; }
        td { padding:14px 20px; border-bottom:1px solid #f1f5f9; font-size:0.9rem; }
        tr:hover td { background:#fef9f0; }
        .badge { padding:6px 14px; border-radius:20px; font-size:0.75rem; font-weight:600; display:inline-block; }
        .badge-blue { background:linear-gradient(135deg,#3b82f6,#2563eb); color:white; }
        .badge-green { background:linear-gradient(135deg,#10b981,#059669); color:white; }
        .badge-yellow { background:linear-gradient(135deg,#f59e0b,#d97706); color:white; }
        h3 { font-size:1.5rem; font-weight:700; color:#1e293b; margin-bottom:20px; }
        a { text-decoration:none; transition:all 0.2s; }
        a[href*="lwmViewExam"] { color:#3b82f6; font-weight:500; }
        a[href*="lwmViewExam"]:hover { color:#2563eb; text-decoration:underline; }
    </style>
</head>
<body>
<div class="content-area">
    <h3>我的考试记录</h3>
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
                            <a href="lwmViewExam?recordId=<%= r.get("recordId") %>">查看</a>
                        <% } else { %>
                            <span style="color:#94a3b8;">--</span>
                        <% } %>
                    </td>
                </tr>
        <% } } %>
        </tbody>
    </table>
</div>
</body>
</html>
```

- [ ] **Step 2: Commit**

```bash
git add src/main/webapp/lwmstudent_paper.jsp
git commit -m "feat: write lwmstudent_paper.jsp with exam records table"
```

---

### Task 6: Rewrite lwmstudent_message.jsp with personal info

**Files:**
- Modify: `src/main/webapp/lwmstudent_message.jsp`

- [ ] **Step 1: Write the personal info page (reads from session, no DB query)**

```jsp
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
        body { font-family:'Inter',sans-serif; background:#f0f2f5; color:#1e293b; }
        .content-area { flex:1; padding:28px 32px; overflow-y:auto; }
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
```

- [ ] **Step 2: Commit**

```bash
git add src/main/webapp/lwmstudent_message.jsp
git commit -m "feat: write lwmstudent_message.jsp with personal info card"
```

---

### Task 7: Update cross-references in mistake book

**Files:**
- Modify: `src/main/webapp/lwmstudent_mistakebook.jsp:90`

- [ ] **Step 1: Update the "学习中心" link to point to the frameset page**

The current line 90:
```html
<a href="lwmstudent_main.jsp"><i class="fas fa-home"></i> 学习中心</a>
```

No change needed — `lwmstudent_main.jsp` is still the entry point (frameset), so this link is already correct.

- [ ] **Step 2: Mark cross-references as verified**

The following files reference `lwmstudent_main.jsp` and are already correct (they redirect/navigate to the frameset entry point):
- `lwmLogin.java:77` — login redirect → `lwmstudent_main.jsp` ✓
- `lwmSaveExamDraft.java:66,100` — after save, redirect → `lwmstudent_main.jsp` ✓
- `lwmSubmitExam.java:98,100` — after submit, redirect → `lwmstudent_main.jsp` ✓
- `lwmViewExam.java:55,63` — error redirect → `lwmstudent_main.jsp` ✓
- `lwmstudent_view_exam.jsp:78` — back link → `lwmstudent_main.jsp` ✓
- `lwmstudent_mistakebook.jsp:90` — sidebar link → `lwmstudent_main.jsp` ✓

- [ ] **Step 3: Commit (if any changes were needed, otherwise skip)**

None needed — all cross-references remain correct.

---

### Task 8: Verify all files are consistent

**Files:**
- Check: all modified JSP files

- [ ] **Step 1: Verify git status shows the expected files**

Run: `git status --short -- src/main/webapp/lwmstudent_*.jsp`
Expected: 6 files modified (main, top, left, index, paper, message)

- [ ] **Step 2: Quick sanity check — verify each page has a session guard**

Run: `grep -l "response.sendRedirect(\"login.jsp\")" src/main/webapp/lwmstudent_{main,top,left,index,paper,message}.jsp`
Expected: 5 files (main.jsp is a frameset, no session check needed)

- [ ] **Step 3: Commit all remaining changes**

```bash
git add src/main/webapp/lwmstudent_main.jsp src/main/webapp/lwmstudent_top.jsp src/main/webapp/lwmstudent_left.jsp src/main/webapp/lwmstudent_index.jsp src/main/webapp/lwmstudent_paper.jsp src/main/webapp/lwmstudent_message.jsp
git commit -m "refactor: separate student main page into frameset layout

- Convert lwmstudent_main.jsp to frameset (top + left + right)
- Extract top bar into lwmstudent_top.jsp
- Extract sidebar navigation into lwmstudent_left.jsp
- Extract exam center into lwmstudent_index.jsp
- Extract exam records into lwmstudent_paper.jsp
- Extract personal info into lwmstudent_message.jsp
- Preserve orange/gold student theme throughout"
```
