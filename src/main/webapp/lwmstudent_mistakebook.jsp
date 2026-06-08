<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmStudent" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmMistakeBook" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmKnowledgePoint" %>
<%@ page import="com.example.lwmexam.service.lwmexam.Fpage" %>
<%@ page import="java.util.List" %>
<%
    lwmStudent student = (lwmStudent) session.getAttribute("student");
    if (student == null) { response.sendRedirect("login.jsp"); return; }
    List<lwmMistakeBook> mistakes = (List<lwmMistakeBook>) request.getAttribute("mistakes");
    List<lwmKnowledgePoint> allKPs = (List<lwmKnowledgePoint>) request.getAttribute("allKPs");
    List<lwmKnowledgePoint> filteredKPs = (List<lwmKnowledgePoint>) request.getAttribute("filteredKPs");
    String subjectId = (String) request.getAttribute("subjectId");
    String kpId = (String) request.getAttribute("kpId");
    String reviewStatus = (String) request.getAttribute("reviewStatus");
    Fpage fp = (Fpage) request.getAttribute("fp");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>我的错题本</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; }
        .top-bar { background:linear-gradient(135deg,#1e3c72 0%,#2a5298 50%,#f39c12 100%); color:white; padding:0 40px; height:70px; display:flex; align-items:center; justify-content:space-between; }
        .top-bar .logo { font-size:1.3rem; font-weight:700; display:flex; align-items:center; gap:12px; }
        .top-bar .user-info { display:flex; align-items:center; gap:16px; }
        .top-bar a { color:white; text-decoration:none; padding:8px 20px; background:rgba(255,255,255,0.2); border-radius:50px; }
        .main-layout { display:flex; min-height:calc(100vh - 70px); }
        .sidebar { width:260px; background:white; padding:20px 0; box-shadow:2px 0 8px rgba(0,0,0,0.05); }
        .sidebar a { display:flex; align-items:center; gap:10px; padding:12px 28px; color:#475569; text-decoration:none; font-weight:500; transition:all 0.2s; }
        .sidebar a:hover, .sidebar a.active { background:#fef3c7; color:#f39c12; }
        .content-area { flex:1; padding:28px 36px; overflow-y:auto; }
        .tab-nav { display:flex; gap:0; margin-bottom:24px; background:white; border-radius:12px; overflow:hidden; box-shadow:0 1px 3px rgba(0,0,0,0.06); }
        .tab-nav button { flex:1; padding:14px 24px; border:none; background:none; cursor:pointer; font-size:0.95rem; font-weight:600; color:#64748b; transition:all 0.2s; }
        .tab-nav button.active { background:#059669; color:white; }
        .tab-panel { display:none; }
        .tab-panel.active { display:block; }
        .filter-bar { display:flex; gap:10px; margin-bottom:20px; align-items:center; background:white; padding:14px 20px; border-radius:12px; box-shadow:0 1px 3px rgba(0,0,0,0.06); }
        .filter-bar select, .filter-bar button { padding:8px 14px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.85rem; }
        .filter-bar button { background:#059669; color:white; border:none; cursor:pointer; }
        .mistake-card { background:white; border-radius:12px; padding:18px 22px; margin-bottom:12px; box-shadow:0 1px 3px rgba(0,0,0,0.06); transition:all 0.2s; }
        .mistake-card:hover { box-shadow:0 4px 12px rgba(0,0,0,0.1); }
        .mistake-header { display:flex; justify-content:space-between; align-items:center; cursor:pointer; }
        .mistake-header .type-badge { padding:3px 10px; border-radius:12px; font-size:0.75rem; font-weight:600; }
        .type-badge.danx { background:#dbeafe; color:#2563eb; }
        .type-badge.duox { background:#fef3c7; color:#d97706; }
        .type-badge.pand { background:#d1fae5; color:#059669; }
        .type-badge.jiand { background:#ede9fe; color:#7c3aed; }
        .status-badge { padding:3px 10px; border-radius:12px; font-size:0.75rem; font-weight:600; }
        .status-0 { background:#fee2e2; color:#dc2626; }
        .status-1 { background:#fef3c7; color:#d97706; }
        .status-2 { background:#d1fae5; color:#059669; }
        .kp-tag { display:inline-block; padding:2px 8px; background:#f1f5f9; border-radius:6px; font-size:0.75rem; margin:2px 4px 2px 0; color:#64748b; }
        .mistake-detail { display:none; margin-top:14px; padding-top:14px; border-top:1px solid #f1f5f9; }
        .mistake-detail.open { display:block; }
        .answer-compare { display:flex; gap:20px; margin-top:10px; }
        .answer-compare div { flex:1; padding:12px; border-radius:8px; }
        .answer-compare .wrong-box { background:#fef2f2; border:1px solid #fecaca; }
        .answer-compare .correct-box { background:#f0fdf4; border:1px solid #bbf7d0; }
        .btn-sm { padding:6px 14px; border-radius:6px; border:none; cursor:pointer; font-size:0.8rem; font-weight:500; }
        .btn-review { background:#f59e0b; color:white; }
        .btn-mastered { background:#059669; color:white; }
        .pagination { display:flex; gap:6px; margin-top:20px; justify-content:center; }
        .pagination a, .pagination span { padding:8px 14px; border-radius:8px; text-decoration:none; font-size:0.85rem; color:#475569; background:white; box-shadow:0 1px 3px rgba(0,0,0,0.06); }
        .pagination a:hover { background:#059669; color:white; }
        .pagination .current { background:#059669; color:white; }
        #radarChart { width:100%; height:450px; }
        .kp-table { width:100%; margin-top:16px; background:white; border-radius:12px; box-shadow:0 1px 3px rgba(0,0,0,0.06); }
        .kp-table th { background:#f8fafc; padding:12px 16px; text-align:left; font-weight:600; color:#475569; font-size:0.85rem; }
        .kp-table td { padding:10px 16px; border-bottom:1px solid #f1f5f9; font-size:0.85rem; }
        .empty-state { text-align:center; padding:60px; color:#94a3b8; }
    </style>
</head>
<body>
<div class="top-bar">
    <div class="logo"><i class="fas fa-user-graduate"></i> 高校在线考试系统</div>
    <div class="user-info">
        <span><%= student.getLwmstudentname() %> (<%= student.getLwmstudentno() %>)</span>
        <a href="SystemExit">退出</a>
    </div>
</div>
<div class="main-layout">
    <div class="sidebar">
        <a href="lwmstudent_main.jsp"><i class="fas fa-home"></i> 学习中心</a>
        <a href="lwmMistakeBook" class="active"><i class="fas fa-book"></i> 我的错题本</a>
    </div>
    <div class="content-area">
        <div class="tab-nav">
            <button class="active" onclick="switchTab('mistakeList')">错题列表</button>
            <button onclick="switchTab('radar')">知识点分析</button>
        </div>

        <!-- Tab: Mistake List -->
        <div id="tab-mistakeList" class="tab-panel active">
            <form class="filter-bar" method="get" action="lwmMistakeBook">
                <select name="subjectid" id="subjectFilter" onchange="this.form.submit()">
                    <option value="">全部科目</option>
                    <% if (allKPs != null) {
                        java.util.Set<String> seenSub = new java.util.LinkedHashSet<>();
                        for (lwmKnowledgePoint kp : allKPs) {
                            String key = kp.getLwmsubjectid() + "|" + kp.getLwmsubjectname();
                            if (seenSub.add(key)) {
                    %>
                        <option value="<%= kp.getLwmsubjectid() %>" <%= String.valueOf(kp.getLwmsubjectid()).equals(subjectId) ? "selected" : "" %>><%= kp.getLwmsubjectname() %></option>
                    <% } } } %>
                </select>
                <select name="kpid" onchange="this.form.submit()">
                    <option value="">全部知识点</option>
                    <% if (filteredKPs != null) {
                        for (lwmKnowledgePoint kp : filteredKPs) { %>
                            <option value="<%= kp.getLwmkpid() %>" <%= String.valueOf(kp.getLwmkpid()).equals(kpId) ? "selected" : "" %>><%= kp.getLwmkpname() %></option>
                    <% } } %>
                </select>
                <select name="reviewstatus" onchange="this.form.submit()">
                    <option value="">全部状态</option>
                    <option value="0" <%="0".equals(reviewStatus) ? "selected" : "" %>>未复习</option>
                    <option value="1" <%="1".equals(reviewStatus) ? "selected" : "" %>>已复习</option>
                    <option value="2" <%="2".equals(reviewStatus) ? "selected" : "" %>>已掌握</option>
                </select>
                <button type="submit">筛选</button>
            </form>

            <% if (mistakes == null || mistakes.isEmpty()) { %>
                <div class="empty-state"><i class="fas fa-check-circle" style="font-size:3rem;display:block;margin-bottom:16px;"></i>暂无错题记录，继续保持！</div>
            <% } else {
                for (lwmMistakeBook mb : mistakes) {
                    String typeClass = "";
                    String typeLabel = mb.getLwmquestiontype();
                    if ("单选题".equals(typeLabel)) typeClass = "danx";
                    else if ("多选题".equals(typeLabel)) typeClass = "duox";
                    else if ("判断题".equals(typeLabel)) typeClass = "pand";
                    else typeClass = "jiand";
            %>
                <div class="mistake-card">
                    <div class="mistake-header" onclick="toggleDetail(this)">
                        <div style="flex:1;">
                            <span class="type-badge <%= typeClass %>"><%= typeLabel %></span>
                            <span style="margin-left:8px;color:#334155;"><%= mb.getLwmquestioncontent().length() > 60 ? mb.getLwmquestioncontent().substring(0, 60) + "..." : mb.getLwmquestioncontent() %></span>
                            <span style="margin-left:8px;font-size:0.75rem;color:#94a3b8;"><%= mb.getLwmsubjectname() %></span>
                        </div>
                        <div style="display:flex;align-items:center;gap:8px;">
                            <% if (mb.getLwmkpnames() != null && !mb.getLwmkpnames().isEmpty()) {
                                for (String kpn : mb.getLwmkpnames().split(", ")) { %>
                                    <span class="kp-tag"><%= kpn %></span>
                            <% } } %>
                            <% String statusLabel = mb.getLwmreviewstatus() == 2 ? "已掌握" : (mb.getLwmreviewstatus() == 1 ? "已复习" : "未复习"); %>
                            <span class="status-badge status-<%= mb.getLwmreviewstatus() %>"><%= statusLabel %></span>
                            <span style="font-size:0.75rem;color:#94a3b8;"><%= mb.getLwmlastupdatetime() %></span>
                            <i class="fas fa-chevron-down" style="color:#94a3b8;"></i>
                        </div>
                    </div>
                    <div class="mistake-detail">
                        <div style="margin-bottom:8px;font-weight:600;">完整题目：</div>
                        <div style="margin-bottom:10px;"><%= mb.getLwmquestioncontent() %></div>
                        <% if (mb.getLwmoptiona() != null && !mb.getLwmoptiona().isEmpty()) { %>
                            <div>A. <%= mb.getLwmoptiona() %></div>
                            <div>B. <%= mb.getLwmoptionb() %></div>
                            <div>C. <%= mb.getLwmoptionc() %></div>
                            <div>D. <%= mb.getLwmoptiond() %></div>
                        <% } %>
                        <div class="answer-compare">
                            <div class="wrong-box">
                                <strong>你的答案：</strong><br><%= mb.getLwmstudentanswer() != null ? mb.getLwmstudentanswer() : "(未作答)" %>
                            </div>
                            <div class="correct-box">
                                <strong>正确答案：</strong><br><%= mb.getLwmcorrectanswer() %>
                            </div>
                        </div>
                        <div style="margin-top:12px;display:flex;gap:8px;">
                            <form method="post" action="lwmMistakeBook" style="display:inline;">
                                <input type="hidden" name="action" value="updateStatus">
                                <input type="hidden" name="questionId" value="<%= mb.getLwmquestionid() %>">
                                <input type="hidden" name="status" value="1">
                                <button type="submit" class="btn-sm btn-review">标记已复习</button>
                            </form>
                            <form method="post" action="lwmMistakeBook" style="display:inline;">
                                <input type="hidden" name="action" value="updateStatus">
                                <input type="hidden" name="questionId" value="<%= mb.getLwmquestionid() %>">
                                <input type="hidden" name="status" value="2">
                                <button type="submit" class="btn-sm btn-mastered">标记已掌握</button>
                            </form>
                        </div>
                    </div>
                </div>
            <% } } %>

            <% if (fp != null && fp.getPageCount() > 1) { %>
            <div class="pagination">
                <% if (fp.getPageNow() > 0) { %>
                    <a href="lwmMistakeBook?page=<%= fp.getPageNow() - 1 %>&subjectid=<%= subjectId %>&kpid=<%= kpId %>&reviewstatus=<%= reviewStatus %>">上一页</a>
                <% } %>
                <% for (int i = 0; i < fp.getPageCount(); i++) { %>
                    <% if (i == fp.getPageNow()) { %>
                        <span class="current"><%= i + 1 %></span>
                    <% } else { %>
                        <a href="lwmMistakeBook?page=<%= i %>&subjectid=<%= subjectId %>&kpid=<%= kpId %>&reviewstatus=<%= reviewStatus %>"><%= i + 1 %></a>
                    <% } %>
                <% } %>
                <% if (fp.getPageNow() < fp.getPageCount() - 1) { %>
                    <a href="lwmMistakeBook?page=<%= fp.getPageNow() + 1 %>&subjectid=<%= subjectId %>&kpid=<%= kpId %>&reviewstatus=<%= reviewStatus %>">下一页</a>
                <% } %>
            </div>
            <% } %>
        </div>

        <!-- Tab: Knowledge Radar -->
        <div id="tab-radar" class="tab-panel">
            <div class="filter-bar">
                <select id="radarSubject" onchange="loadRadar()">
                    <% if (allKPs != null) {
                        java.util.Set<String> seenSub = new java.util.LinkedHashSet<>();
                        for (lwmKnowledgePoint kp : allKPs) {
                            String key = kp.getLwmsubjectid() + "|" + kp.getLwmsubjectname();
                            if (seenSub.add(key)) {
                    %>
                        <option value="<%= kp.getLwmsubjectid() %>" <%= String.valueOf(kp.getLwmsubjectid()).equals(subjectId) ? "selected" : "" %>><%= kp.getLwmsubjectname() %></option>
                    <% } } } %>
                </select>
                <button onclick="loadRadar()">查看分析</button>
            </div>
            <div id="radarChart"></div>
            <div id="radarEmpty" class="empty-state" style="display:none;">该科目暂无知识点数据或错题记录</div>
            <table class="kp-table" id="radarTable" style="display:none;">
                <thead><tr><th>知识点</th><th>涉及题数</th><th>做错题数</th><th>掌握度</th></tr></thead>
                <tbody id="radarTableBody"></tbody>
            </table>
        </div>
    </div>
</div>
<script>
function switchTab(name) {
    document.querySelectorAll('.tab-nav button').forEach(b => b.classList.remove('active'));
    document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
    document.getElementById('tab-' + name).classList.add('active');
    document.querySelectorAll('.tab-nav button')[name === 'mistakeList' ? 0 : 1].classList.add('active');
    if (name === 'radar') loadRadar();
}
function toggleDetail(header) {
    var detail = header.nextElementSibling;
    detail.classList.toggle('open');
    var icon = header.querySelector('.fa-chevron-down');
    if (detail.classList.contains('open')) {
        icon.style.transform = 'rotate(180deg)';
    } else {
        icon.style.transform = 'rotate(0deg)';
    }
}
function loadRadar() {
    var subjectId = document.getElementById('radarSubject').value;
    if (!subjectId) return;
    fetch('lwmKnowledgeMastery?subjectid=' + subjectId)
        .then(r => r.json())
        .then(data => {
            if (!data || data.length === 0) {
                document.getElementById('radarEmpty').style.display = 'block';
                document.getElementById('radarChart').style.display = 'none';
                document.getElementById('radarTable').style.display = 'none';
                return;
            }
            document.getElementById('radarEmpty').style.display = 'none';
            document.getElementById('radarChart').style.display = 'block';
            document.getElementById('radarTable').style.display = '';
            var chart = echarts.init(document.getElementById('radarChart'));
            chart.setOption({
                radar: {
                    indicator: data.map(function(d) { return {name: d.kpname, max: 1}; }),
                    center: ['50%', '55%'],
                    radius: '65%'
                },
                series: [{
                    type: 'radar',
                    data: [{value: data.map(function(d) { return d.mastery; }), name: '掌握度'}],
                    areaStyle: { color: 'rgba(5,150,105,0.2)' },
                    lineStyle: { color: '#059669' },
                    itemStyle: { color: '#059669' }
                }]
            });
            window.addEventListener('resize', function() { chart.resize(); });
            var tbody = document.getElementById('radarTableBody');
            tbody.innerHTML = '';
            data.forEach(function(d) {
                var rate = Math.round(d.mastery * 100) + '%';
                var color = d.mastery >= 0.7 ? '#059669' : (d.mastery >= 0.4 ? '#d97706' : '#dc2626');
                tbody.innerHTML += '<tr><td>' + d.kpname + '</td><td>' + d.total + '</td><td>' + d.wrong + '</td><td style="color:' + color + ';font-weight:600;">' + rate + '</td></tr>';
            });
        });
}
</script>
</body>
</html>
