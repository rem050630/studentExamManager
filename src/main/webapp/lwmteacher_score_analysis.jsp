<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    List<String[]> subjectList = (List<String[]>) request.getAttribute("subjectList");
    List<String[]> paperList = (List<String[]>) request.getAttribute("paperList");
    List<String> classList = (List<String>) request.getAttribute("classList");
    String selectedPaperId = (String) request.getAttribute("selectedPaperId");
    String selectedClass = (String) request.getAttribute("selectedClass");
    String selectedSubjectId = (String) request.getAttribute("selectedSubjectId");
    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
    int[] distribution = (int[]) request.getAttribute("distribution");
    Double passRateObj = (Double) request.getAttribute("passRate");
    double passRate = passRateObj != null ? passRateObj : 0;
    Integer passLineObj = (Integer) request.getAttribute("passLine");
    int passLine = passLineObj != null ? passLineObj : 60;
    Integer b2EndObj = (Integer) request.getAttribute("b2End");
    int b2End = b2EndObj != null ? b2EndObj : 70;
    Integer b3EndObj = (Integer) request.getAttribute("b3End");
    int b3End = b3EndObj != null ? b3EndObj : 80;
    Integer excelLineObj = (Integer) request.getAttribute("excelLine");
    int excelLine = excelLineObj != null ? excelLineObj : 90;
    String[] bracketLabels = (String[]) request.getAttribute("bracketLabels");
    if (bracketLabels == null) bracketLabels = new String[]{"0-59","60-69","70-79","80-89","90-100"};
    List<Map<String, Object>> studentScores = (List<Map<String, Object>>) request.getAttribute("studentScores");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>成绩分析</title>
    <script src="https://cdn.jsdelivr.net/npm/echarts@5.5.0/dist/echarts.min.js"></script>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; padding:24px; }
        .container { max-width:1300px; margin:0 auto; }
        .header { margin-bottom:20px; }
        .header h2 { color:#1e293b; font-size:1.5rem; }

        .filter-bar { background:white; padding:16px 20px; border-radius:12px; margin-bottom:20px; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        .filter-bar form { display:flex; align-items:center; gap:12px; flex-wrap:wrap; }
        .filter-bar label { font-weight:500; color:#475569; font-size:0.9rem; }
        .filter-bar select, .filter-bar input { padding:8px 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.9rem; background:white; }
        .filter-bar select { min-width:180px; }

        .btn { padding:8px 20px; border-radius:8px; cursor:pointer; font-size:0.9rem; border:none; text-decoration:none; display:inline-block; }
        .btn-primary { background:#3b82f6; color:white; }
        .btn-secondary { background:#e2e8f0; color:#475569; }

        .tabs { display:flex; gap:0; margin-bottom:0; }
        .tab-btn { padding:10px 24px; background:#e2e8f0; color:#475569; border:none; cursor:pointer; font-size:0.9rem; border-radius:10px 10px 0 0; margin-right:4px; transition:background 0.2s; }
        .tab-btn.active { background:white; color:#3b82f6; font-weight:600; }
        .tab-btn:hover:not(.active) { background:#cbd5e1; }

        .tab-content { display:none; background:white; border-radius:0 12px 12px 12px; padding:24px; box-shadow:0 1px 3px rgba(0,0,0,0.08); min-height:400px; }
        .tab-content.active { display:block; }

        .stats-grid { display:grid; grid-template-columns:repeat(5,1fr); gap:16px; margin-bottom:24px; }
        .stat-card { background:#f8fafc; border:1px solid #e2e8f0; border-radius:10px; padding:16px; text-align:center; }
        .stat-card .stat-value { font-size:1.6rem; font-weight:700; color:#1e293b; }
        .stat-card .stat-label { font-size:0.8rem; color:#64748b; margin-top:4px; }
        .stat-card.highlight { border-color:#3b82f6; background:#eff6ff; }
        .stat-card.warn { border-color:#f59e0b; background:#fffbeb; }

        .charts-row { display:flex; gap:20px; margin-bottom:24px; }
        .chart-box { flex:1; background:#f8fafc; border:1px solid #e2e8f0; border-radius:10px; padding:16px; }
        .chart-box h4 { font-size:0.9rem; color:#475569; margin-bottom:12px; }

        .pass-gauge { text-align:center; padding:20px; }
        .pass-gauge .gauge-circle { width:120px; height:120px; border-radius:50%; display:inline-flex; align-items:center; justify-content:center; font-size:1.8rem; font-weight:700; }
        .pass-gauge .gauge-label { font-size:0.85rem; color:#64748b; margin-top:8px; }

        table { width:100%; border-radius:10px; overflow:hidden; }
        th { background:#f8fafc; padding:10px 14px; text-align:left; font-weight:600; color:#475569; font-size:0.85rem; border-bottom:2px solid #e2e8f0; }
        td { padding:10px 14px; border-bottom:1px solid #f1f5f9; color:#334155; font-size:0.85rem; }
        tr:hover { background:#f8fafc; }
        .empty { text-align:center; padding:40px; color:#94a3b8; }

        .stars { color:#f59e0b; font-size:0.95rem; letter-spacing:2px; }
        .badge { padding:4px 10px; border-radius:12px; font-size:0.78rem; font-weight:500; }
        .badge-red { background:#fef2f2; color:#dc2626; }
        .badge-green { background:#ecfdf5; color:#059669; }
        .badge-yellow { background:#fffbeb; color:#d97706; }
        .badge-blue { background:#eff6ff; color:#2563eb; }

        .heatmap-row { display:flex; flex-wrap:wrap; gap:6px; margin-bottom:20px; }
        .heatmap-cell { width:60px; height:60px; border-radius:8px; display:flex; flex-direction:column; align-items:center; justify-content:center; font-size:0.7rem; color:white; cursor:pointer; transition:transform 0.2s; }
        .heatmap-cell:hover { transform:scale(1.08); }
        .heatmap-cell .cell-name { font-weight:600; font-size:0.65rem; text-align:center; line-height:1.2; }
        .heatmap-cell .cell-rate { font-size:0.9rem; font-weight:700; margin-top:2px; }

        @media (max-width:900px) {
            .stats-grid { grid-template-columns:repeat(2,1fr); }
            .charts-row { flex-direction:column; }
        }
    </style>
</head>
<body>
<div class="container">
    <div class="header"><h2>成绩分析</h2></div>

    <!-- Filter Bar -->
    <div class="filter-bar">
        <form method="get" action="lwmScoreAnalysis" id="filterForm">
            <label>科目：</label>
            <select name="subjectid" id="subjectSelect" onchange="onSubjectChange()">
                <option value="">-- 全部科目 --</option>
                <% if (subjectList != null) {
                    for (String[] sub : subjectList) { %>
                        <option value="<%= sub[0] %>" <%= sub[0].equals(selectedSubjectId) ? "selected" : "" %>><%= sub[1] %></option>
                <% } } %>
            </select>
            <label>试卷：</label>
            <select name="paperid" id="paperSelect">
                <option value="">-- 请选择试卷 --</option>
                <% if (paperList != null) {
                    for (String[] p : paperList) { %>
                        <option value="<%= p[0] %>" data-subject="<%= p[3] %>" data-class="<%= p[2] %>" <%= p[0].equals(selectedPaperId) ? "selected" : "" %>><%= p[1] %> (<%= p[2] %>)</option>
                <% } } %>
            </select>
            <label>班级：</label>
            <select name="classname" id="classSelect">
                <option value="">-- 全部班级 --</option>
                <% if (classList != null) {
                    for (String cls : classList) { %>
                        <option value="<%= cls %>" <%= cls.equals(selectedClass) ? "selected" : "" %>><%= cls %></option>
                <% } } %>
            </select>
            <button type="submit" class="btn btn-primary">查询</button>
            <% if (selectedPaperId != null && !selectedPaperId.isEmpty()) { %>
                <a href="lwmScoreAnalysis" class="btn btn-secondary">重置</a>
            <% } %>
        </form>
    </div>

    <% if (selectedPaperId != null && !selectedPaperId.isEmpty()) { %>

    <!-- Tabs -->
    <div class="tabs">
        <button class="tab-btn active" onclick="switchTab('overview')">成绩概览</button>
        <button class="tab-btn" onclick="switchTab('quality')">试题质量</button>
        <button class="tab-btn" onclick="switchTab('knowledge')">知识点分析</button>
        <button class="tab-btn" onclick="switchTab('compare')">班级对比</button>
    </div>

    <!-- Tab 1: 成绩概览 -->
    <div class="tab-content active" id="tab-overview">
        <% if (stats != null) { %>
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-value"><%= stats.get("cnt") %></div>
                    <div class="stat-label">参考人数</div>
                </div>
                <div class="stat-card highlight">
                    <div class="stat-value"><%= String.format("%.1f", stats.get("avg")) %></div>
                    <div class="stat-label">平均分</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value"><%= stats.get("max") %></div>
                    <div class="stat-label">最高分</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value"><%= stats.get("min") %></div>
                    <div class="stat-label">最低分</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value"><%= stats.get("stddev") != null ? String.format("%.1f", stats.get("stddev")) : "--" %></div>
                    <div class="stat-label">标准差</div>
                </div>
            </div>

            <div class="charts-row">
                <div class="chart-box">
                    <h4>分数分布</h4>
                    <div id="distChart" style="width:100%;height:300px;"></div>
                </div>
                <div class="chart-box">
                    <h4>及格率</h4>
                    <div class="pass-gauge">
                        <div class="gauge-circle" style="background:conic-gradient(#059669 0% <%= ((int) passRate) * 3.6 %>deg, #e2e8f0 <%= ((int) passRate) * 3.6 %>deg 360deg); display:inline-flex; align-items:center; justify-content:center;">
                            <span style="background:white; width:90px; height:90px; border-radius:50%; display:inline-flex; align-items:center; justify-content:center; font-size:1.5rem;"><%= String.format("%.1f", passRate) %>%</span>
                        </div>
                        <div class="gauge-label"><%= passRate >= 60 ? "及格情况良好" : "及格率偏低，需重点关注" %></div>
                    </div>
                </div>
            </div>

            <%-- Student Score Table --%>
            <h4 style="color:#1e293b; margin-bottom:12px; font-size:1rem;">学生成绩明细</h4>
            <div style="overflow-x:auto;">
                <table>
                    <thead>
                        <tr><th>序号</th><th>学号</th><th>姓名</th><th>班级</th><th>分数</th><th>等级</th></tr>
                    </thead>
                    <tbody>
                        <% if (studentScores != null && !studentScores.isEmpty()) {
                            int idx = 1;
                            for (Map<String, Object> ss : studentScores) {
                                int score = (int) ss.get("score");
                                String grade = score >= excelLine ? "优秀" : (score >= b3End ? "良好" : (score >= b2End ? "中等" : (score >= passLine ? "及格" : "不及格")));
                                String badgeClass = score >= excelLine ? "badge-green" : (score >= b3End ? "badge-blue" : (score >= b2End ? "badge-yellow" : (score >= passLine ? "badge-yellow" : "badge-red")));
                        %>
                            <tr>
                                <td><%= idx++ %></td>
                                <td><%= ss.get("no") %></td>
                                <td><%= ss.get("name") %></td>
                                <td><%= ss.get("classname") %></td>
                                <td><strong><%= score %></strong></td>
                                <td><span class="badge <%= badgeClass %>"><%= grade %></span></td>
                            </tr>
                        <% } } else { %>
                            <tr><td colspan="6" class="empty">暂无成绩数据</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } else { %>
            <div class="empty">暂无统计数据，请确认该试卷已有学生提交并评分</div>
        <% } %>
    </div>

    <!-- Tab 2: 试题质量 -->
    <div class="tab-content" id="tab-quality">
        <div id="qualityLoading" style="text-align:center;padding:40px;color:#94a3b8;">加载中...</div>
        <div id="qualityTable" style="display:none;overflow-x:auto;">
            <table>
                <thead>
                    <tr><th>题号</th><th>题型</th><th>试题内容</th><th>知识点</th><th>难度</th><th>区分度</th></tr>
                </thead>
                <tbody id="qualityBody"></tbody>
            </table>
        </div>
        <div id="qualityEmpty" class="empty" style="display:none;">暂无试题数据</div>
    </div>

    <!-- Tab 3: 知识点分析 -->
    <div class="tab-content" id="tab-knowledge">
        <div id="kpLoading" style="text-align:center;padding:40px;color:#94a3b8;">加载中...</div>
        <div id="kpContent" style="display:none;">
            <div class="heatmap-row" id="kpHeatmap"></div>
            <h4 style="color:#1e293b; margin-bottom:12px; margin-top:20px; font-size:1rem;">知识点详细数据</h4>
            <div style="overflow-x:auto;">
                <table>
                    <thead>
                        <tr><th>知识点ID</th><th>知识点名称</th><th>关联试题数</th><th>得分率</th><th>状态</th></tr>
                    </thead>
                    <tbody id="kpBody"></tbody>
                </table>
            </div>
        </div>
        <div id="kpEmpty" class="empty" style="display:none;">暂无知识点数据</div>
    </div>

    <!-- Tab 4: 班级对比 -->
    <div class="tab-content" id="tab-compare">
        <div style="text-align:center; padding:60px 20px;">
            <p style="font-size:1.1rem; color:#475569; margin-bottom:20px;">查看不同班级在本次考试中各知识点的横向对比</p>
            <a href="lwmteacher_class_compare.jsp?paperid=<%= selectedPaperId %>" class="btn btn-primary" style="font-size:1rem; padding:12px 32px;">前往班级对比页面</a>
        </div>
    </div>

    <% } else { %>
    <div style="background:white; padding:60px; border-radius:12px; text-align:center; box-shadow:0 1px 3px rgba(0,0,0,0.08);">
        <p style="color:#94a3b8; font-size:1.1rem;">请选择科目和试卷进行成绩分析</p>
    </div>
    <% } %>
</div>

<script>
// Tab switching
function switchTab(tabName) {
    document.querySelectorAll('.tab-btn').forEach(function(btn) { btn.classList.remove('active'); });
    document.querySelectorAll('.tab-content').forEach(function(tc) { tc.classList.remove('active'); });
    document.getElementById('tab-' + tabName).classList.add('active');
    var btns = document.querySelectorAll('.tab-btn');
    var tabOrder = ['overview','quality','knowledge','compare'];
    for (var i = 0; i < tabOrder.length; i++) {
        if (tabOrder[i] === tabName) { btns[i].classList.add('active'); break; }
    }

    if (tabName === 'quality') loadQuestionQuality();
    if (tabName === 'knowledge') loadKnowledgeAnalysis();
}
function onSubjectChange() {
    var subId = document.getElementById('subjectSelect').value;
    var paperSel = document.getElementById('paperSelect');
    var opts = paperSel.options;
    // Show/hide paper options based on subject filter
    for (var i = 0; i < opts.length; i++) {
        if (opts[i].value === '') continue;
        var paperSub = opts[i].getAttribute('data-subject');
        if (subId === '' || paperSub === subId) {
            opts[i].style.display = '';
        } else {
            opts[i].style.display = 'none';
        }
    }
    // Reset paper selection if hidden
    if (paperSel.selectedIndex > 0) {
        var selOpt = paperSel.options[paperSel.selectedIndex];
        if (selOpt.style.display === 'none') {
            paperSel.selectedIndex = 0;
        }
    }
}

// Initialize subject filter on load
window.addEventListener('DOMContentLoaded', function() {
    onSubjectChange();

    <% if (selectedPaperId != null && !selectedPaperId.isEmpty() && stats != null && distribution != null) { %>
    // Distribution chart
    var distDom = document.getElementById('distChart');
    if (distDom) {
        var distChart = echarts.init(distDom);
        distChart.setOption({
            tooltip: { trigger: 'axis' },
            xAxis: { data: ['<%= bracketLabels[0] %>','<%= bracketLabels[1] %>','<%= bracketLabels[2] %>','<%= bracketLabels[3] %>','<%= bracketLabels[4] %>'], axisLabel: { fontSize: 11 } },
            yAxis: { type: 'value', name: '人数', minInterval: 1 },
            series: [{
                type: 'bar',
                data: [
                    { value: <%= distribution[0] %>, itemStyle: { color: '#ef4444' } },
                    { value: <%= distribution[1] %>, itemStyle: { color: '#f59e0b' } },
                    { value: <%= distribution[2] %>, itemStyle: { color: '#3b82f6' } },
                    { value: <%= distribution[3] %>, itemStyle: { color: '#10b981' } },
                    { value: <%= distribution[4] %>, itemStyle: { color: '#059669' } }
                ],
                barWidth: '50%',
                label: { show: true, position: 'top', fontSize: 11 }
            }],
            grid: { left:40, right:20, top:20, bottom:30 }
        });
        window.addEventListener('resize', function() { distChart.resize(); });
    }
    <% } %>
});

var qualityLoaded = false;
var kpLoaded = false;

function loadQuestionQuality() {
    if (qualityLoaded) return;
    qualityLoaded = true;
    var paperId = '<%= selectedPaperId != null ? selectedPaperId : "" %>';
    if (!paperId) { document.getElementById('qualityLoading').style.display = 'none'; document.getElementById('qualityEmpty').style.display = 'block'; return; }

    fetch('lwmQuestionQuality?paperid=' + encodeURIComponent(paperId))
        .then(function(r) { return r.json(); })
        .then(function(data) {
            document.getElementById('qualityLoading').style.display = 'none';
            if (!data || data.length === 0) {
                document.getElementById('qualityEmpty').style.display = 'block';
                return;
            }
            var html = '';
            for (var i = 0; i < data.length; i++) {
                var q = data[i];
                var starsHtml = '';
                for (var s = 0; s < q.stars; s++) starsHtml += '★';
                for (var s = q.stars; s < 4; s++) starsHtml += '☆';
                var diffLabel = q.difficulty >= 0.75 ? '容易' : (q.difficulty >= 0.5 ? '中等' : (q.difficulty >= 0.25 ? '较难' : '困难'));
                var discClass = q.discrimination >= 0.3 ? 'badge-green' : (q.discrimination >= 0.15 ? 'badge-blue' : 'badge-red');
                html += '<tr>';
                html += '<td>' + q.qid + '</td>';
                html += '<td>' + q.type + '</td>';
                html += '<td title="' + q.content.replace(/"/g,'&quot;') + '">' + q.content + '</td>';
                html += '<td>' + (q.kps || '--') + '</td>';
                html += '<td><span class="stars">' + starsHtml + '</span> ' + diffLabel + '</td>';
                html += '<td><span class="badge ' + discClass + '">' + q.discrimination + '</span></td>';
                html += '</tr>';
            }
            document.getElementById('qualityBody').innerHTML = html;
            document.getElementById('qualityTable').style.display = 'block';
        })
        .catch(function() {
            document.getElementById('qualityLoading').style.display = 'none';
            document.getElementById('qualityEmpty').style.display = 'block';
        });
}

function loadKnowledgeAnalysis() {
    if (kpLoaded) return;
    kpLoaded = true;
    var paperId = '<%= selectedPaperId != null ? selectedPaperId : "" %>';
    if (!paperId) { document.getElementById('kpLoading').style.display = 'none'; document.getElementById('kpEmpty').style.display = 'block'; return; }

    fetch('lwmKnowledgeAnalysis?paperid=' + encodeURIComponent(paperId))
        .then(function(r) { return r.json(); })
        .then(function(data) {
            document.getElementById('kpLoading').style.display = 'none';
            if (!data || data.length === 0) {
                document.getElementById('kpEmpty').style.display = 'block';
                return;
            }
            // Heatmap
            var heatHtml = '';
            for (var i = 0; i < data.length; i++) {
                var r = data[i].rate;
                var bgColor = r >= 0.8 ? '#059669' : (r >= 0.6 ? '#3b82f6' : (r >= 0.4 ? '#f59e0b' : '#ef4444'));
                heatHtml += '<div class="heatmap-cell" style="background:' + bgColor + '">';
                heatHtml += '<span class="cell-name">' + data[i].kpname + '</span>';
                heatHtml += '<span class="cell-rate">' + Math.round(r * 100) + '%</span>';
                heatHtml += '</div>';
            }
            document.getElementById('kpHeatmap').innerHTML = heatHtml;

            // Table
            var tHtml = '';
            for (var i = 0; i < data.length; i++) {
                var wk = data[i].weak;
                var bgClass = wk ? 'badge-red' : 'badge-green';
                tHtml += '<tr>';
                tHtml += '<td>' + data[i].kpid + '</td>';
                tHtml += '<td>' + data[i].kpname + '</td>';
                tHtml += '<td>' + data[i].qcnt + '</td>';
                tHtml += '<td>' + Math.round(data[i].rate * 100) + '%</td>';
                tHtml += '<td><span class="badge ' + bgClass + '">' + (wk ? '薄弱' : '良好') + '</span></td>';
                tHtml += '</tr>';
            }
            document.getElementById('kpBody').innerHTML = tHtml;
            document.getElementById('kpContent').style.display = 'block';
        })
        .catch(function() {
            document.getElementById('kpLoading').style.display = 'none';
            document.getElementById('kpEmpty').style.display = 'block';
        });
}
</script>
</body>
</html>
