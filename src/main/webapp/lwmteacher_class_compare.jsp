<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmTeacher" %>
<%@ page import="com.example.lwmexam.dao.lwmexam.lwmCourseArrangeDAO" %>
<%@ page import="com.example.lwmexam.dao.lwmexam.lwmpaperDAO" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmstudentcourseteacher" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmExamPaper" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%
    lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
    if (teacher == null) { response.sendRedirect("login.jsp"); return; }

    String selectedPaperId = request.getParameter("paperid");

    lwmCourseArrangeDAO arrangeDao = new lwmCourseArrangeDAO();
    List<lwmstudentcourseteacher> courses = arrangeDao.lwmQuerySomeSct(
        "SELECT sct.*, sub.lwmsubjectname, tea.lwmteachername FROM lwmstudentcourseteacher sct " +
        "LEFT JOIN lwmexamsubject sub ON sct.lwmsubjectid = sub.lwmsubjectid " +
        "LEFT JOIN lwmteacher tea ON sct.lwmteacherid = tea.lwmteacherid " +
        "WHERE sct.lwmteacherid = ? ORDER BY sub.lwmsubjectname",
        new Object[]{teacher.getLwmteacherid()});

    lwmpaperDAO paperDao = new lwmpaperDAO();
    List<lwmExamPaper> papers = paperDao.lwmQueryByTeacher(teacher.getLwmteacherid());
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>班级对比</title>
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
        .filter-bar select { padding:8px 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.9rem; background:white; min-width:180px; }

        .class-checkboxes { display:flex; gap:10px; flex-wrap:wrap; padding:8px 0; }
        .class-checkboxes label { display:inline-flex; align-items:center; gap:4px; font-weight:400; font-size:0.85rem; cursor:pointer; padding:4px 12px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:6px; transition:all 0.2s; }
        .class-checkboxes label.checked { background:#eff6ff; border-color:#3b82f6; color:#2563eb; }
        .class-checkboxes input[type="checkbox"] { display:none; }

        .btn { padding:8px 20px; border-radius:8px; cursor:pointer; font-size:0.9rem; border:none; text-decoration:none; display:inline-block; }
        .btn-primary { background:#3b82f6; color:white; }
        .btn-secondary { background:#e2e8f0; color:#475569; }
        .btn-primary:disabled { background:#94a3b8; cursor:not-allowed; }

        .tabs { display:flex; gap:0; margin-bottom:0; }
        .tab-btn { padding:10px 24px; background:#e2e8f0; color:#475569; border:none; cursor:pointer; font-size:0.9rem; border-radius:10px 10px 0 0; margin-right:4px; transition:background 0.2s; }
        .tab-btn.active { background:white; color:#3b82f6; font-weight:600; }
        .tab-btn:hover:not(.active) { background:#cbd5e1; }

        .tab-content { display:none; background:white; border-radius:0 12px 12px 12px; padding:24px; box-shadow:0 1px 3px rgba(0,0,0,0.08); min-height:400px; }
        .tab-content.active { display:block; }

        .chart-box { width:100%; height:400px; margin-bottom:24px; }

        table { width:100%; border-radius:10px; overflow:hidden; }
        th { background:#f8fafc; padding:10px 14px; text-align:left; font-weight:600; color:#475569; font-size:0.85rem; border-bottom:2px solid #e2e8f0; }
        td { padding:10px 14px; border-bottom:1px solid #f1f5f9; color:#334155; font-size:0.85rem; }
        tr:hover { background:#f8fafc; }
        .empty { text-align:center; padding:40px; color:#94a3b8; }
        .badge { padding:4px 10px; border-radius:12px; font-size:0.78rem; font-weight:500; }
        .badge-red { background:#fef2f2; color:#dc2626; }
        .badge-green { background:#ecfdf5; color:#059669; }
        .badge-blue { background:#eff6ff; color:#2563eb; }
        .loading { text-align:center; padding:60px; color:#94a3b8; font-size:0.95rem; }
    </style>
</head>
<body>
<div class="container">
    <div class="header"><h2>班级对比</h2></div>

    <!-- Filter Bar -->
    <div class="filter-bar">
        <div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
            <label>科目：</label>
            <select id="subjectSelect" onchange="onSubjectChange()">
                <option value="">-- 全部科目 --</option>
                <% Set<Integer> seenSubjects = new HashSet<>();
                for (lwmstudentcourseteacher c : courses) {
                    if (seenSubjects.add(c.getLwmsubjectid())) { %>
                        <option value="<%= c.getLwmsubjectid() %>"><%= c.getLwmsubjectname() %></option>
                <% } } %>
            </select>
            <label>试卷：</label>
            <select id="paperSelect" onchange="onPaperChange()">
                <option value="">-- 请选择试卷 --</option>
                <% for (lwmExamPaper p : papers) {
                    String classes = p.getLwmclassname();
                    if (classes != null && !classes.isEmpty()) { %>
                        <option value="<%= p.getLwmpaperid() %>"
                                data-subject="<%= p.getLwmsubjectid() %>"
                                data-classes="<%= classes %>"
                                <%= (selectedPaperId != null && selectedPaperId.equals(String.valueOf(p.getLwmpaperid()))) ? "selected" : "" %>>
                            <%= p.getLwmpapername() %> (<%= classes %>)
                        </option>
                <% } } %>
            </select>
        </div>
        <div style="margin-top:12px;">
            <label style="font-weight:500;color:#475569;font-size:0.9rem;">选择班级（至少2个）：</label>
            <div class="class-checkboxes" id="classCheckboxes">
                <span style="color:#94a3b8;font-size:0.85rem;">请先选择试卷</span>
            </div>
        </div>
        <div style="margin-top:12px;">
            <button class="btn btn-primary" id="compareBtn" onclick="startCompare()" disabled>开始对比</button>
            <span id="classCount" style="color:#64748b;font-size:0.85rem;margin-left:12px;"></span>
        </div>
    </div>

    <!-- Tabs (initially hidden until compare data loaded) -->
    <div id="tabsContainer" style="display:none;">
        <div class="tabs">
            <button class="tab-btn active" onclick="switchTab('core')">核心指标</button>
            <button class="tab-btn" onclick="switchTab('distribution')">分数分布</button>
            <button class="tab-btn" onclick="switchTab('knowledge')">知识点对比</button>
        </div>

        <!-- Tab 1: 核心指标 -->
        <div class="tab-content active" id="tab-core">
            <div class="chart-box" id="coreChart"></div>
            <div id="coreTable"></div>
        </div>

        <!-- Tab 2: 分数分布 -->
        <div class="tab-content" id="tab-distribution">
            <div class="chart-box" id="distChart"></div>
        </div>

        <!-- Tab 3: 知识点对比 -->
        <div class="tab-content" id="tab-knowledge">
            <div class="chart-box" id="kpChart"></div>
            <div class="loading" id="kpLoading" style="display:none;">加载中...</div>
            <div class="empty" id="kpEmpty" style="display:none;">暂无知识点数据</div>
        </div>
    </div>

    <div id="noData" class="empty" style="background:white;border-radius:12px;padding:60px;box-shadow:0 1px 3px rgba(0,0,0,0.08);display:none;">
        暂无对比数据，请确认所选班级已有学生提交并完成考试
    </div>
</div>

<script>
var compareData = null;
var bracketLabels = null;
var classNames = [];
var coreChartInst = null;
var distChartInst = null;
var kpChartInst = null;
var allPaperOptions = [];

// Initialize on page load
window.addEventListener('DOMContentLoaded', function() {
    // Cache all paper options (skip the placeholder at index 0)
    var paperSel = document.getElementById('paperSelect');
    allPaperOptions = [];
    for (var i = 1; i < paperSel.options.length; i++) {
        allPaperOptions.push({
            value: paperSel.options[i].value,
            text: paperSel.options[i].text,
            subject: paperSel.options[i].getAttribute('data-subject'),
            classes: paperSel.options[i].getAttribute('data-classes')
        });
    }
    onSubjectChange();
    if (paperSel.value) {
        onPaperChange();
    }
    <% if (selectedPaperId != null && !selectedPaperId.isEmpty()) { %>
        // Auto-trigger compare if paperid provided in URL
        setTimeout(function() {
            var cb = document.querySelectorAll('#classCheckboxes input[type="checkbox"]:checked');
            if (cb.length >= 2) {
                startCompare();
            }
        }, 300);
    <% } %>
});

function onSubjectChange() {
    var subId = document.getElementById('subjectSelect').value;
    var paperSel = document.getElementById('paperSelect');
    var currentVal = paperSel.value;

    // Clear dropdown
    paperSel.innerHTML = '';

    // Add placeholder
    var placeholder = document.createElement('option');
    placeholder.value = '';
    placeholder.textContent = '-- 请选择试卷 --';
    paperSel.appendChild(placeholder);

    // Re-add matching options from cache
    var foundCurrent = false;
    for (var i = 0; i < allPaperOptions.length; i++) {
        var opt = allPaperOptions[i];
        if (subId === '' || opt.subject === subId) {
            var el = document.createElement('option');
            el.value = opt.value;
            el.textContent = opt.text;
            el.setAttribute('data-subject', opt.subject);
            el.setAttribute('data-classes', opt.classes);
            if (opt.value === currentVal) {
                el.selected = true;
                foundCurrent = true;
            }
            paperSel.appendChild(el);
        }
    }

    // If previously selected paper is no longer in list, reset to placeholder
    if (!foundCurrent) {
        paperSel.selectedIndex = 0;
    }

    onPaperChange();
}

function onPaperChange() {
    var paperSel = document.getElementById('paperSelect');
    var container = document.getElementById('classCheckboxes');
    var selectedOpt = paperSel.options[paperSel.selectedIndex];

    if (!selectedOpt || !selectedOpt.value) {
        container.innerHTML = '<span style="color:#94a3b8;font-size:0.85rem;">请先选择试卷</span>';
        document.getElementById('compareBtn').disabled = true;
        document.getElementById('classCount').textContent = '';
        return;
    }

    var classesStr = selectedOpt.getAttribute('data-classes');
    if (!classesStr) {
        container.innerHTML = '<span style="color:#94a3b8;font-size:0.85rem;">该试卷无班级信息</span>';
        document.getElementById('compareBtn').disabled = true;
        document.getElementById('classCount').textContent = '';
        return;
    }

    var classes = classesStr.split(',');
    var html = '';
    for (var i = 0; i < classes.length; i++) {
        var cls = classes[i].trim();
        if (!cls) continue;
        html += '<label id="lbl_' + i + '">';
        html += '<input type="checkbox" value="' + cls + '" onclick="updateClassCount()">';
        html += cls;
        html += '</label>';
    }
    container.innerHTML = html;
    document.getElementById('compareBtn').disabled = true;
    document.getElementById('classCount').textContent = '';
}

function updateClassCount() {
    var checked = document.querySelectorAll('#classCheckboxes input[type="checkbox"]:checked');
    document.getElementById('classCount').textContent = '已选 ' + checked.length + ' 个班级';
    document.getElementById('compareBtn').disabled = checked.length < 2;
    // Also update the label styles
    var allLabels = document.querySelectorAll('#classCheckboxes label');
    for (var i = 0; i < allLabels.length; i++) {
        var cb = allLabels[i].querySelector('input[type="checkbox"]');
        if (cb && cb.checked) {
            allLabels[i].classList.add('checked');
        } else {
            allLabels[i].classList.remove('checked');
        }
    }
}

function getSelectedClasses() {
    var checked = document.querySelectorAll('#classCheckboxes input[type="checkbox"]:checked');
    var classes = [];
    for (var i = 0; i < checked.length; i++) {
        classes.push(checked[i].value);
    }
    return classes;
}

function startCompare() {
    var paperId = document.getElementById('paperSelect').value;
    var classes = getSelectedClasses();
    if (!paperId || classes.length < 2) {
        alert('请选择试卷和至少2个班级');
        return;
    }
    classNames = classes;
    document.getElementById('compareBtn').disabled = true;
    document.getElementById('compareBtn').textContent = '加载中...';

    var url = 'lwmScoreAnalysis?action=compare&paperid=' + encodeURIComponent(paperId) +
              '&classnames=' + encodeURIComponent(classes.join(','));

    fetch(url)
        .then(function(r) { return r.json(); })
        .then(function(data) {
            document.getElementById('compareBtn').disabled = false;
            document.getElementById('compareBtn').textContent = '开始对比';

            // Reset render flags so re-compare re-renders everything
            coreMetricsRendered = false;
            distRendered = false;
            kpLoaded = false;

            // Dispose old chart instances
            if (coreChartInst) { coreChartInst.dispose(); coreChartInst = null; }
            if (distChartInst) { distChartInst.dispose(); distChartInst = null; }
            if (kpChartInst) { kpChartInst.dispose(); kpChartInst = null; }

            // Clear old table content
            document.getElementById('coreTable').innerHTML = '';
            document.getElementById('distChart').innerHTML = '';
            document.getElementById('kpChart').innerHTML = '';
            document.getElementById('kpChart').style.display = 'block';
            document.getElementById('kpEmpty').style.display = 'none';
            document.getElementById('kpLoading').style.display = 'none';

            if (!data || !data.data || data.data.length === 0) {
                document.getElementById('tabsContainer').style.display = 'none';
                document.getElementById('noData').style.display = 'block';
                return;
            }
            compareData = data.data;
            bracketLabels = data.bracketLabels || ['0-59','60-69','70-79','80-89','90-100'];
            document.getElementById('tabsContainer').style.display = 'block';
            document.getElementById('noData').style.display = 'none';
            renderCoreMetrics();
        })
        .catch(function() {
            document.getElementById('compareBtn').disabled = false;
            document.getElementById('compareBtn').textContent = '开始对比';
            alert('加载对比数据失败，请重试');
        });
}

// Tab switching
function switchTab(tabName) {
    var tabs = ['core', 'distribution', 'knowledge'];
    var btns = document.querySelectorAll('.tab-btn');
    var contents = document.querySelectorAll('.tab-content');

    for (var i = 0; i < tabs.length; i++) {
        btns[i].classList.remove('active');
        contents[i].classList.remove('active');
    }

    document.getElementById('tab-' + tabName).classList.add('active');
    var idx = tabs.indexOf(tabName);
    if (idx >= 0) btns[idx].classList.add('active');

    if (tabName === 'core') renderCoreMetrics();
    if (tabName === 'distribution') renderDistribution();
    if (tabName === 'knowledge') loadKnowledgeComparison();
}

// Tab 1: Core metrics chart + table
var coreMetricsRendered = false;
function renderCoreMetrics() {
    if (coreMetricsRendered || !compareData) return;
    coreMetricsRendered = true;

    // Multi-series bar chart: avg, max, min per class
    var dom = document.getElementById('coreChart');
    var names = [];
    var avgData = [];
    var maxData = [];
    var minData = [];

    for (var i = 0; i < compareData.length; i++) {
        var d = compareData[i];
        names.push(d.classname);
        avgData.push(d.avg);
        maxData.push(d.max);
        minData.push(d.min);
    }

    if (coreChartInst) coreChartInst.dispose();
    coreChartInst = echarts.init(dom);
    coreChartInst.setOption({
        title: { text: '核心指标对比', left: 'center', top: 10, textStyle: { fontSize: 14, color: '#1e293b' } },
        tooltip: { trigger: 'axis' },
        legend: { data: ['平均分', '最高分', '最低分'], bottom: 0 },
        xAxis: { type: 'category', data: names },
        yAxis: { type: 'value', name: '分数' },
        series: [
            { name: '平均分', type: 'bar', data: avgData, itemStyle: { color: '#3b82f6' }, label: { show: true, position: 'top', fontSize: 11 } },
            { name: '最高分', type: 'bar', data: maxData, itemStyle: { color: '#10b981' }, label: { show: true, position: 'top', fontSize: 11 } },
            { name: '最低分', type: 'bar', data: minData, itemStyle: { color: '#ef4444' }, label: { show: true, position: 'top', fontSize: 11 } }
        ],
        grid: { left: 50, right: 20, top: 60, bottom: 40 }
    });

    // Comparison table
    var tableHtml = '<h4 style="color:#1e293b;margin-bottom:12px;font-size:1rem;">详细数据对比</h4>';
    tableHtml += '<div style="overflow-x:auto;"><table><thead><tr>';
    tableHtml += '<th>班级</th><th>参考人数</th><th>平均分</th><th>最高分</th><th>最低分</th><th>及格率</th><th>优秀率</th>';
    tableHtml += '</tr></thead><tbody>';
    for (var i = 0; i < compareData.length; i++) {
        var d = compareData[i];
        var passClass = d.passRate >= 80 ? 'badge-green' : (d.passRate >= 60 ? 'badge-blue' : 'badge-red');
        var excelClass = d.excellenceRate >= 30 ? 'badge-green' : (d.excellenceRate >= 15 ? 'badge-blue' : 'badge-red');
        tableHtml += '<tr>';
        tableHtml += '<td><strong>' + d.classname + '</strong></td>';
        tableHtml += '<td>' + d.count + '</td>';
        tableHtml += '<td>' + d.avg + '</td>';
        tableHtml += '<td>' + d.max + '</td>';
        tableHtml += '<td>' + d.min + '</td>';
        tableHtml += '<td><span class="badge ' + passClass + '">' + d.passRate + '%</span></td>';
        tableHtml += '<td><span class="badge ' + excelClass + '">' + d.excellenceRate + '%</span></td>';
        tableHtml += '</tr>';
    }
    tableHtml += '</tbody></table></div>';
    document.getElementById('coreTable').innerHTML = tableHtml;
}

// Tab 2: Score distribution grouped bar chart
var distRendered = false;
function renderDistribution() {
    if (distRendered || !compareData) return;
    distRendered = true;

    var dom = document.getElementById('distChart');
    var brackets = bracketLabels || ['0-59', '60-69', '70-79', '80-89', '90-100'];
    var series = [];

    for (var i = 0; i < compareData.length; i++) {
        series.push({
            name: compareData[i].classname,
            type: 'bar',
            data: compareData[i].dist,
            label: { show: true, position: 'top', fontSize: 10 }
        });
    }

    if (distChartInst) distChartInst.dispose();
    distChartInst = echarts.init(dom);
    distChartInst.setOption({
        title: { text: '分数分布对比', left: 'center', top: 10, textStyle: { fontSize: 14, color: '#1e293b' } },
        tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
        legend: { data: classNames, bottom: 0 },
        xAxis: { type: 'category', data: brackets },
        yAxis: { type: 'value', name: '人数', minInterval: 1 },
        series: series,
        grid: { left: 50, right: 20, top: 60, bottom: 40 }
    });
}

// Tab 3: Knowledge point comparison (radar chart)
var kpLoaded = false;
function loadKnowledgeComparison() {
    if (kpLoaded) return;
    kpLoaded = true;

    var paperId = document.getElementById('paperSelect').value;
    if (!paperId || classNames.length === 0) {
        document.getElementById('kpLoading').style.display = 'none';
        document.getElementById('kpEmpty').style.display = 'block';
        return;
    }

    document.getElementById('kpLoading').style.display = 'block';
    document.getElementById('kpEmpty').style.display = 'none';
    var chartDom = document.getElementById('kpChart');
    if (kpChartInst) { kpChartInst.dispose(); kpChartInst = null; }
    chartDom.innerHTML = '';

    var url = 'lwmKnowledgeAnalysis?paperid=' + encodeURIComponent(paperId) +
              '&classnames=' + encodeURIComponent(classNames.join(','));

    fetch(url)
        .then(function(r) { return r.json(); })
        .then(function(data) {
            document.getElementById('kpLoading').style.display = 'none';

            if (!data || Object.keys(data).length === 0) {
                document.getElementById('kpEmpty').style.display = 'block';
                document.getElementById('kpChart').style.display = 'none';
                return;
            }

            // Data format: { "classA": [{kpid, kpname, rate}...], "classB": [...] }
            // Extract common KP names from first class
            var firstClass = classNames[0];
            var firstData = data[firstClass];
            if (!firstData || firstData.length === 0) {
                document.getElementById('kpEmpty').style.display = 'block';
                document.getElementById('kpChart').style.display = 'none';
                return;
            }

            // Build indicator (KP names) and series data
            var indicators = [];
            var seriesData = {};

            for (var c = 0; c < classNames.length; c++) {
                seriesData[classNames[c]] = [];
            }

            for (var i = 0; i < firstData.length; i++) {
                var kp = firstData[i];
                indicators.push({ name: kp.kpname, max: 1 });
                seriesData[firstClass].push(kp.rate);

                // Get rate for other classes
                for (var c = 1; c < classNames.length; c++) {
                    var clsName = classNames[c];
                    var clsData = data[clsName];
                    var rate = 0;
                    if (clsData) {
                        for (var j = 0; j < clsData.length; j++) {
                            if (clsData[j].kpid === kp.kpid) {
                                rate = clsData[j].rate;
                                break;
                            }
                        }
                    }
                    seriesData[clsName].push(rate);
                }
            }

            // Build series
            var radarSeries = [];
            var colors = ['#3b82f6', '#ef4444', '#10b981', '#f59e0b', '#8b5cf6', '#ec4899'];
            for (var c = 0; c < classNames.length; c++) {
                radarSeries.push({
                    name: classNames[c],
                    type: 'radar',
                    data: [{ value: seriesData[classNames[c]], name: classNames[c] }],
                    itemStyle: { color: colors[c % colors.length] },
                    lineStyle: { color: colors[c % colors.length] }
                });
            }

            document.getElementById('kpChart').style.display = 'block';
            kpChartInst = echarts.init(document.getElementById('kpChart'));
            kpChartInst.setOption({
                title: { text: '知识点掌握率对比', left: 'center', top: -2, textStyle: { fontSize: 14, color: '#1e293b'} },
                tooltip: {},
                legend: { data: classNames, bottom: 0 },
                radar: {
                    indicator: indicators,
                    shape: 'polygon',
                    splitNumber: 5,
                    axisName: { color: '#475569', fontSize: 10 }
                },
                series: radarSeries
            });
        })
        .catch(function() {
            document.getElementById('kpLoading').style.display = 'none';
            document.getElementById('kpEmpty').style.display = 'block';
        });
}

// Chart resize
window.addEventListener('resize', function() {
    if (coreChartInst) coreChartInst.resize();
    if (distChartInst) distChartInst.resize();
    if (kpChartInst) kpChartInst.resize();
});
</script>
</body>
</html>
