<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmTeacher" %>
<%@ page import="com.example.lwmexam.dao.lwmexam.lwmCourseArrangeDAO" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmstudentcourseteacher" %>
<%@ page import="com.example.lwmexam.dao.lwmexam.lwmquestionDAO" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmExamQuestion" %>
<%@ page import="java.util.List" %>
<%
    lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
    if (teacher == null) { response.sendRedirect("login.jsp"); return; }

    lwmCourseArrangeDAO arrangeDao = new lwmCourseArrangeDAO();
    List<lwmstudentcourseteacher> courses = arrangeDao.lwmQuerySomeSct(
        "SELECT sct.*, sub.lwmsubjectname, tea.lwmteachername FROM lwmstudentcourseteacher sct LEFT JOIN lwmexamsubject sub ON sct.lwmsubjectid = sub.lwmsubjectid LEFT JOIN lwmteacher tea ON sct.lwmteacherid = tea.lwmteacherid WHERE sct.lwmteacherid = ?",
        new Object[]{teacher.getLwmteacherid()});

%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>创建试卷</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; padding:24px; }
        .container { max-width:900px; margin:0 auto; background:white; padding:32px; border-radius:12px; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        h2 { margin-bottom:24px; color:#1e293b; }
        .form-group { margin-bottom:18px; }
        .form-group label { display:block; margin-bottom:6px; color:#475569; font-weight:500; font-size:0.9rem; }
        .form-group select, .form-group input { width:100%; padding:10px 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.9rem; }
        .inline-group { display:flex; gap:12px; }
        .inline-group .form-group { flex:1; }
        .mode-tabs { display:flex; gap:12px; margin-bottom:20px; }
        .mode-tab { padding:10px 24px; border-radius:8px; cursor:pointer; border:2px solid #e2e8f0; background:white; font-size:0.9rem; }
        .mode-tab.active { border-color:#059669; background:#ecfdf5; color:#059669; font-weight:600; }
        .q-list { max-height:400px; overflow-y:auto; border:1px solid #e2e8f0; border-radius:8px; padding:12px; margin-bottom:18px; }
        .q-item { padding:8px 12px; border-bottom:1px solid #f1f5f9; font-size:0.85rem; display:flex; align-items:center; gap:8px; }
        .q-item:last-child { border-bottom:none; }
        .btn-row { display:flex; gap:12px; justify-content:flex-end; margin-top:20px; }
        .btn { padding:10px 24px; border-radius:8px; cursor:pointer; border:none; font-size:0.9rem; text-decoration:none; }
        .btn-primary { background:#059669; color:white; }
        .btn-secondary { background:#e2e8f0; color:#475569; }
        .load-btn { background:#3b82f6; color:white; padding:8px 16px; border:none; border-radius:8px; cursor:pointer; }
    </style>
</head>
<body>
<div class="container">
    <h2>创建试卷</h2>
    <form method="post" action="lwmCreatePaper">
        <div class="form-group">
            <label>试卷名称</label>
            <input type="text" name="lwmpapername" required placeholder="如：2023级高数期末试卷">
        </div>
        <div class="form-group">
            <label>所属科目</label>
            <select name="lwmsubjectid" id="subjectSelect" required>
                <option value="">请选择</option>
                <% java.util.Set<Integer> seenSubjs = new java.util.HashSet<>();
                for (lwmstudentcourseteacher c : courses) {
                    if (seenSubjs.add(c.getLwmsubjectid())) { %>
                    <option value="<%= c.getLwmsubjectid() %>"><%= c.getLwmsubjectname() %></option>
                <% } } %>
            </select>
        </div>
        <div class="inline-group">
            <div class="form-group">
                <label>考试开始时间</label>
                <input type="datetime-local" name="lwmstarttime" required>
            </div>
            <div class="form-group">
                <label>考试结束时间</label>
                <input type="datetime-local" name="lwmendtime" required>
            </div>
        </div>
        <div class="form-group">
            <label>考试时长（分钟）</label>
            <input type="number" name="lwmexamtime" value="120" min="1" required>
        </div>

        <div class="mode-tabs">
            <div class="mode-tab active" onclick="switchMode('manual')">手动组卷</div>
            <div class="mode-tab" onclick="switchMode('auto')">自动组卷</div>
        </div>
        <input type="hidden" name="mode" id="mode" value="manual">

        <div id="manualArea">
            <button type="button" class="load-btn" onclick="loadQuestions()">加载题库试题</button>
            <select id="typeFilter" style="padding:8px 12px;border:1px solid #e2e8f0;border-radius:8px;font-size:0.9rem;margin-left:8px;" onchange="loadQuestions()">
                <option value="">全部题型</option>
                <option value="单选题">单选题</option>
                <option value="多选题">多选题</option>
                <option value="判断题">判断题</option>
                <option value="简答题">简答题</option>
            </select>
            <div id="questionList" class="q-list" style="margin-top:12px;">
                <p style="color:#94a3b8;">选择科目并点击"加载题库试题"</p>
            </div>
            <div class="inline-group">
                <div class="form-group"><label>单选题分值</label><input type="number" name="danxscore" value="2" min="0" onchange="updateTotal()"></div>
                <div class="form-group"><label>多选题分值</label><input type="number" name="duoxscore" value="2" min="0" onchange="updateTotal()"></div>
                <div class="form-group"><label>判断题分值</label><input type="number" name="pdscore" value="1" min="0" onchange="updateTotal()"></div>
                <div class="form-group"><label>简答题分值</label><input type="number" name="jdscore" value="5" min="0" onchange="updateTotal()"></div>
            </div>
        </div>
        <div id="autoArea" style="display:none;">
            <div class="inline-group">
                <div class="form-group"><label>单选题数量</label><input type="number" name="danxnum" value="0" min="0" onchange="updateTotal()"></div>
                <div class="form-group"><label>单选题分值</label><input type="number" name="danxscore" value="2" min="0" onchange="updateTotal()"></div>
            </div>
            <div class="inline-group">
                <div class="form-group"><label>多选题数量</label><input type="number" name="duoxnum" value="0" min="0" onchange="updateTotal()"></div>
                <div class="form-group"><label>多选题分值</label><input type="number" name="duoxscore" value="2" min="0" onchange="updateTotal()"></div>
            </div>
            <div class="inline-group">
                <div class="form-group"><label>判断题数量</label><input type="number" name="pdnum" value="0" min="0" onchange="updateTotal()"></div>
                <div class="form-group"><label>判断题分值</label><input type="number" name="pdscore" value="1" min="0" onchange="updateTotal()"></div>
            </div>
            <div class="inline-group">
                <div class="form-group"><label>简答题数量</label><input type="number" name="jdnum" value="0" min="0" onchange="updateTotal()"></div>
                <div class="form-group"><label>简答题分值</label><input type="number" name="jdscore" value="5" min="0" onchange="updateTotal()"></div>
            </div>
        </div>

        <div class="form-group" style="text-align:right;padding:12px 0;border-top:2px solid #e2e8f0;margin-top:8px;">
            <span style="font-weight:600;font-size:1.1rem;color:#059669;">试卷总分：<span id="totalScore" style="font-size:1.3rem;">0</span> 分</span>
        </div>
        <div class="btn-row">
            <a href="lwmQueryPaper" class="btn btn-secondary">取消</a>
            <button type="submit" class="btn btn-primary">创建试卷</button>
        </div>
    </form>
</div>
<script>
    function switchMode(mode) {
        document.getElementById('mode').value = mode;
        document.querySelectorAll('.mode-tab').forEach(function(t) { t.classList.remove('active'); });
        event.target.classList.add('active');
        document.getElementById('manualArea').style.display = mode === 'manual' ? 'block' : 'none';
        document.getElementById('autoArea').style.display = mode === 'auto' ? 'block' : 'none';
        setTimeout(updateTotal, 100);
    }
    function updateTotal() {
        var mode = document.getElementById('mode').value;
        var total = 0;
        if (mode === 'manual') {
            var checkboxes = document.querySelectorAll('#questionList input[name="questionIds"]:checked');
            var danxS = parseInt(document.querySelector('input[name="danxscore"]').value) || 0;
            var duoxS = parseInt(document.querySelector('input[name="duoxscore"]').value) || 0;
            var pdS = parseInt(document.querySelector('input[name="pdscore"]').value) || 0;
            var jdS = parseInt(document.querySelector('input[name="jdscore"]').value) || 0;
            checkboxes.forEach(function(cb) {
                var text = cb.parentElement.textContent;
                if (text.indexOf('[单选题]') >= 0) total += danxS;
                else if (text.indexOf('[多选题]') >= 0) total += duoxS;
                else if (text.indexOf('[判断题]') >= 0) total += pdS;
                else if (text.indexOf('[简答题]') >= 0) total += jdS;
            });
        } else {
            var autoArea = document.getElementById('autoArea');
            var danxN = parseInt(autoArea.querySelector('input[name="danxnum"]').value) || 0;
            var duoxN = parseInt(autoArea.querySelector('input[name="duoxnum"]').value) || 0;
            var pdN = parseInt(autoArea.querySelector('input[name="pdnum"]').value) || 0;
            var jdN = parseInt(autoArea.querySelector('input[name="jdnum"]').value) || 0;
            var danxS = parseInt(autoArea.querySelector('input[name="danxscore"]').value) || 0;
            var duoxS = parseInt(autoArea.querySelector('input[name="duoxscore"]').value) || 0;
            var pdS = parseInt(autoArea.querySelector('input[name="pdscore"]').value) || 0;
            var jdS = parseInt(autoArea.querySelector('input[name="jdscore"]').value) || 0;
            total = danxN*danxS + duoxN*duoxS + pdN*pdS + jdN*jdS;
        }
        document.getElementById('totalScore').textContent = total;
    }
    function loadQuestions() {
        var subjectId = document.getElementById('subjectSelect').value;
        if (!subjectId) { alert('请先选择科目'); return; }
        var typeFilter = document.getElementById('typeFilter');
        var type = typeFilter ? typeFilter.value : '';
        var url = 'lwmLoadQuestions?subject=' + subjectId;
        if (type) url += '&type=' + encodeURIComponent(type);
        var list = document.getElementById('questionList');
        list.innerHTML = '<p style="color:#94a3b8;">加载中...</p>';
        fetch(url).then(function(r) { return r.text(); }).then(function(html) {
            list.innerHTML = html;
            var cbs = list.querySelectorAll('input[name="addQuestionIds"]');
            cbs.forEach(function(cb) { cb.name = 'questionIds'; });
            if (typeof updateTotal === 'function') updateTotal();
        }).catch(function() {
            list.innerHTML = '<p style="color:#ef4444;">加载失败，请重试</p>';
        });
    }
</script>
<script>
document.getElementById('questionList').addEventListener('change', function(e) {
    if (e.target.type === 'checkbox' && e.target.name === 'questionIds') updateTotal();
});
</script>
</body>
</html>
