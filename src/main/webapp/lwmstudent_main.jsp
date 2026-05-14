<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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

    // Available exams (papers for student's class, not yet submitted)
    List<Map<String,Object>> availExams = new ArrayList<>();
    List<Map<String,Object>> myRecords = new ArrayList<>();
    List<Map<String,Object>> myScores = new ArrayList<>();

    MysqlConn db = new MysqlConn();
    try {
        ResultSet rs = db.doQuery(
            "SELECT p.* FROM lwmexampaper p " +
            "WHERE p.lwmclassname = ? " +
            "AND NOT EXISTS (SELECT 1 FROM lwmexamrecord r WHERE r.lwmpaperid = p.lwmpaperid AND r.lwmstudentid = ? AND r.lwmsubmitstatus = 1) " +
            "ORDER BY p.lwmstarttime DESC",
            new Object[]{student.getLwmclassname(), student.getLwmstudentid()});
        while (rs.next()) {
            Map<String,Object> m = new HashMap<>();
            m.put("id", rs.getInt("lwmpaperid"));
            m.put("name", rs.getString("lwmpapername"));
            m.put("start", rs.getString("lwmstarttime"));
            m.put("end", rs.getString("lwmendtime"));
            m.put("time", rs.getInt("lwmexamtime"));
            m.put("score", rs.getInt("lwmexamsore"));
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
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>高校在线考试系统 - 学生学习中心</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; color:#1e293b; }
        .top-bar { background:linear-gradient(135deg,#f59e0b,#d97706); color:white; padding:0 32px; height:70px; display:flex; align-items:center; justify-content:space-between; box-shadow:0 2px 10px rgba(0,0,0,0.1); }
        .logo-area { display:flex; align-items:center; gap:12px; }
        .logo-icon { width:40px; height:40px; background:rgba(255,255,255,0.2); border-radius:12px; display:flex; align-items:center; justify-content:center; }
        .user-info { display:flex; align-items:center; gap:20px; }
        .user-name { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.15); padding:8px 20px; border-radius:40px; }
        .logout-btn { background:rgba(255,255,255,0.2); border:none; color:white; padding:8px 20px; border-radius:40px; cursor:pointer; }
        .main-layout { display:flex; min-height:calc(100vh - 70px); }
        .sidebar { width:280px; background:white; box-shadow:2px 0 8px rgba(0,0,0,0.05); padding:24px 0; }
        .menu-item { display:flex; align-items:center; gap:12px; padding:12px 24px; margin:4px 16px; border-radius:12px; cursor:pointer; transition:all 0.3s; color:#475569; }
        .menu-item:hover { background:#fef3c7; color:#f59e0b; }
        .menu-item.active { background:linear-gradient(135deg,#fffbeb,#fef3c7); color:#f59e0b; font-weight:600; }
        .content-area { flex:1; padding:28px 32px; overflow-y:auto; }
        .welcome-card { background:linear-gradient(135deg,#f59e0b,#d97706); color:white; padding:28px 32px; border-radius:24px; margin-bottom:28px; }
        .welcome-card h2 { font-size:1.6rem; margin-bottom:8px; }
        .stats-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(200px,1fr)); gap:16px; margin-bottom:28px; }
        .stat-card { background:white; padding:20px; border-radius:16px; box-shadow:0 1px 3px rgba(0,0,0,0.1); }
        .stat-num { font-size:2rem; font-weight:700; color:#f59e0b; }
        .stat-label { color:#64748b; font-size:0.85rem; margin-top:4px; }
        .exam-card { background:white; border-radius:16px; padding:20px; margin-bottom:14px; display:flex; justify-content:space-between; align-items:center; box-shadow:0 1px 3px rgba(0,0,0,0.1); }
        .exam-card h4 { margin-bottom:4px; }
        .exam-card p { color:#64748b; font-size:0.85rem; }
        .btn-exam { background:linear-gradient(135deg,#f59e0b,#d97706); color:white; border:none; padding:10px 24px; border-radius:12px; cursor:pointer; font-weight:600; text-decoration:none; display:inline-block; }
        .module-panel { display:none; }
        .module-panel.active { display:block; }
        table { width:100%; border-collapse:collapse; background:white; border-radius:12px; overflow:hidden; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        th { background:#f8fafc; padding:12px 14px; text-align:left; font-weight:600; color:#475569; font-size:0.85rem; }
        td { padding:10px 14px; border-bottom:1px solid #f1f5f9; font-size:0.85rem; }
        .badge { padding:4px 10px; border-radius:12px; font-size:0.8rem; }
        .badge-green { background:#dcfce7; color:#16a34a; }
        .badge-yellow { background:#fef3c7; color:#d97706; }
        .info-card { background:white; border-radius:16px; padding:24px; box-shadow:0 1px 3px rgba(0,0,0,0.1); }
        .info-row { display:flex; padding:10px 0; border-bottom:1px solid #f1f5f9; }
        .info-row .label { width:100px; color:#64748b; font-weight:500; }
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
                for (Map<String,Object> e : availExams) { %>
                    <div class="exam-card">
                        <div>
                            <h4><%= e.get("name") %></h4>
                            <p><%= e.get("start") %> ~ <%= e.get("end") %> | <%= e.get("time") %>分钟 | <%= e.get("score") %>分</p>
                        </div>
                        <a href="lwmTakeExam?paperId=<%= e.get("id") %>" class="btn-exam">开始考试</a>
                    </div>
            <% } } %>
        </div>

        <!-- 我的试卷 -->
        <div id="myPapers" class="module-panel">
            <h3 style="margin-bottom:16px;">我的考试记录</h3>
            <table>
                <thead><tr><th>试卷名称</th><th>考试时间</th><th>状态</th><th>成绩</th></tr></thead>
                <tbody>
                <% if (myRecords.isEmpty()) { %>
                    <tr><td colspan="4" style="text-align:center;color:#94a3b8;padding:24px;">暂无考试记录</td></tr>
                <% } else {
                    for (Map<String,Object> r : myRecords) {
                        int status = (int) r.get("status");
                        Object scoreObj = r.get("score"); %>
                        <tr>
                            <td><%= r.get("paperName") %></td>
                            <td><%= r.get("startTime") %></td>
                            <td><span class="badge <%= status == 1 ? "badge-green" : "badge-yellow" %>"><%= status == 1 ? "已提交" : "未提交" %></span></td>
                            <td><strong><%= scoreObj != null ? scoreObj + "分" : status == 1 ? "待批阅" : "--" %></strong></td>
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
</script>
</body>
</html>
