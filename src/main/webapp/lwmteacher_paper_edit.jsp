<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmExamPaper" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmExamQuestion" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmTeacher" %>
<%@ page import="com.example.lwmexam.dao.lwmexam.lwmCourseArrangeDAO" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmstudentcourseteacher" %>
<%@ page import="java.util.List" %>
<%
    lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
    if (teacher == null) { response.sendRedirect("login.jsp"); return; }

    lwmExamPaper paper = (lwmExamPaper) request.getAttribute("paper");
    List<lwmExamQuestion> currentQuestions = (List<lwmExamQuestion>) request.getAttribute("currentQuestions");
    List<lwmExamQuestion> subjectQuestions = (List<lwmExamQuestion>) request.getAttribute("subjectQuestions");
    boolean hasSubmit = request.getAttribute("hasSubmit") != null && (boolean) request.getAttribute("hasSubmit");

    lwmCourseArrangeDAO arrangeDao = new lwmCourseArrangeDAO();
    List<lwmstudentcourseteacher> courses = arrangeDao.lwmQuerySomeSct(
        "SELECT sct.*, sub.lwmsubjectname, tea.lwmteachername FROM lwmstudentcourseteacher sct LEFT JOIN lwmexamsubject sub ON sct.lwmsubjectid = sub.lwmsubjectid LEFT JOIN lwmteacher tea ON sct.lwmteacherid = tea.lwmteacherid WHERE sct.lwmteacherid = ?",
        new Object[]{teacher.getLwmteacherid()});
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>修改试卷</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; padding:24px; }
        .container { max-width:900px; margin:0 auto; background:white; padding:32px; border-radius:12px; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        h2 { margin-bottom:24px; color:#1e293b; }
        h3 { margin:20px 0 12px; color:#1e293b; font-size:1rem; }
        .form-group { margin-bottom:18px; }
        .form-group label { display:block; margin-bottom:6px; color:#475569; font-weight:500; font-size:0.9rem; }
        .form-group select, .form-group input { width:100%; padding:10px 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.9rem; }
        .inline-group { display:flex; gap:12px; }
        .inline-group .form-group { flex:1; }
        .warning { background:#fef3c7; color:#d97706; padding:12px 16px; border-radius:8px; margin-bottom:18px; font-size:0.85rem; }
        .q-section { border:1px solid #e2e8f0; border-radius:8px; padding:12px; margin-bottom:16px; max-height:300px; overflow-y:auto; }
        .q-item { display:flex; align-items:center; gap:10px; padding:8px 10px; border-bottom:1px solid #f1f5f9; font-size:0.85rem; }
        .q-item:last-child { border-bottom:none; }
        .q-item span { flex:1; }
        .q-item .badge { padding:2px 8px; border-radius:4px; font-size:0.75rem; background:#e2e8f0; color:#475569; white-space:nowrap; }
        .btn-remove { background:#ef4444; color:white; border:none; border-radius:4px; padding:4px 10px; cursor:pointer; font-size:0.75rem; }
        .btn-row { display:flex; gap:12px; justify-content:flex-end; margin-top:20px; }
        .btn { padding:10px 24px; border-radius:8px; cursor:pointer; border:none; font-size:0.9rem; text-decoration:none; }
        .btn-primary { background:#059669; color:white; }
        .btn-secondary { background:#e2e8f0; color:#475569; }
        .score-row { display:flex; gap:12px; margin-top:12px; }
        .score-row .form-group { flex:1; }
        .add-select { width:100%; padding:8px; border:1px solid #e2e8f0; border-radius:8px; }
    </style>
</head>
<body>
<div class="container">
    <h2>修改试卷</h2>
    <% if (hasSubmit) { %>
        <div class="warning">该试卷已有学生提交，不可修改试题组成，仅可修改基本信息。</div>
    <% } %>
    <form method="post" action="lwmUpdatePaper" id="paperForm">
        <input type="hidden" name="lwmpaperid" value="<%= paper.getLwmpaperid() %>">

        <div class="inline-group">
            <div class="form-group">
                <label>试卷名称</label>
                <input type="text" name="lwmpapername" required value="<%= paper.getLwmpapername() %>">
            </div>
        </div>

        <div class="form-group">
            <label>所属科目</label>
            <% if (hasSubmit) { %>
                <input type="text" value="<%= paper.getLwmsubjectname() %>" readonly style="background:#f8fafc;">
                <input type="hidden" name="lwmsubjectid" value="<%= paper.getLwmsubjectid() %>">
            <% } else { %>
                <select name="lwmsubjectid" required>
                    <% java.util.Set<Integer> seenSubjs = new java.util.HashSet<>();
                    for (lwmstudentcourseteacher c : courses) {
                        if (seenSubjs.add(c.getLwmsubjectid())) { %>
                            <option value="<%= c.getLwmsubjectid() %>" <%= paper.getLwmsubjectid() == c.getLwmsubjectid() ? "selected" : "" %>><%= c.getLwmsubjectname() %></option>
                    <% } } %>
                </select>
            <% } %>
        </div>

        <div class="inline-group">
            <div class="form-group">
                <label>考试开始时间</label>
                <input type="datetime-local" name="lwmstarttime" required value="<%= paper.getLwmstarttime().replace(" ", "T") %>">
            </div>
            <div class="form-group">
                <label>考试结束时间</label>
                <input type="datetime-local" name="lwmendtime" required value="<%= paper.getLwmendtime().replace(" ", "T") %>">
            </div>
        </div>

        <div class="inline-group">
            <div class="form-group">
                <label>考试时长（分钟）</label>
                <input type="number" name="lwmexamtime" required min="1" value="<%= paper.getLwmexamtime() %>">
            </div>
            <div class="form-group">
                <label>试卷总分（自动计算）</label>
                <input type="number" name="lwmexamsore" value="<%= paper.getLwmexamsore() %>" readonly style="background:#f8fafc;">
            </div>
        </div>

        <% if (!hasSubmit) { %>
            <h3 id="currentQuestionsTitle">当前试题（共 <%= currentQuestions != null ? currentQuestions.size() : 0 %> 道）</h3>
            <div class="q-section" id="currentQuestions">
                <% if (currentQuestions != null && !currentQuestions.isEmpty()) {
                    for (lwmExamQuestion q : currentQuestions) { %>
                        <div class="q-item">
                            <input type="checkbox" name="questionIds" value="<%= q.getLwmquestionid() %>" checked>
                            <span class="badge"><%= q.getLwmquestiontype() %></span>
                            <span><%= q.getLwmquestioncontent() %></span>
                            <button type="button" class="btn-remove" onclick="this.parentElement.remove();existingIds.delete(<%= q.getLwmquestionid() %>);updateTotal();editLoadQuestions()">移除</button>
                        </div>
                    <% }
                } else { %>
                    <p style="color:#94a3b8;">暂无试题</p>
                <% } %>
            </div>

            <div style="display:flex;gap:12px;margin-bottom:12px;align-items:center;">
                <h3 style="margin:0;">添加试题</h3>
                <div style="display:flex;gap:4px;">
                    <button type="button" class="mode-tab active" onclick="switchEditMode('manual', this)" style="padding:6px 16px;border:2px solid #e2e8f0;border-radius:8px;background:white;cursor:pointer;font-size:0.85rem;">手动组卷</button>
                    <button type="button" class="mode-tab" onclick="switchEditMode('auto', this)" style="padding:6px 16px;border:2px solid #e2e8f0;border-radius:8px;background:white;cursor:pointer;font-size:0.85rem;">自动组卷</button>
                </div>
            </div>
            <input type="hidden" id="editMode" value="manual">

            <%-- Manual mode area --%>
            <div id="editManualArea">
                <div style="display:flex;gap:8px;margin-bottom:8px;">
                    <button type="button" class="load-btn" onclick="editLoadQuestions()" style="background:#3b82f6;color:white;padding:8px 16px;border:none;border-radius:8px;cursor:pointer;">加载题库试题</button>
                    <select id="editTypeFilter" style="padding:8px 12px;border:1px solid #e2e8f0;border-radius:8px;font-size:0.9rem;" onchange="editLoadQuestions()">
                        <option value="">全部题型</option>
                        <option value="单选题">单选题</option>
                        <option value="多选题">多选题</option>
                        <option value="判断题">判断题</option>
                        <option value="简答题">简答题</option>
                    </select>
                    <button type="button" onclick="addSelectedQuestions()" style="background:#059669;color:white;padding:8px 16px;border:none;border-radius:8px;cursor:pointer;">+ 添加选中试题</button>
                </div>
                <div id="editQuestionList" class="q-section" style="max-height:300px;overflow-y:auto;">
                    <p style="color:#94a3b8;">点击"加载题库试题"查看可添加的试题</p>
                </div>
            </div>

            <%-- Auto mode area --%>
            <div id="editAutoArea" style="display:none;">
                <div class="inline-group" style="margin-bottom:12px;">
                    <div class="form-group"><label>单选题数量</label><input type="number" id="editDanxNum" value="0" min="0" style="width:100%;padding:8px;border:1px solid #e2e8f0;border-radius:8px;"></div>
                    <div class="form-group"><label>多选题数量</label><input type="number" id="editDuoxNum" value="0" min="0" style="width:100%;padding:8px;border:1px solid #e2e8f0;border-radius:8px;"></div>
                    <div class="form-group"><label>判断题数量</label><input type="number" id="editPdNum" value="0" min="0" style="width:100%;padding:8px;border:1px solid #e2e8f0;border-radius:8px;"></div>
                    <div class="form-group"><label>简答题数量</label><input type="number" id="editJdNum" value="0" min="0" style="width:100%;padding:8px;border:1px solid #e2e8f0;border-radius:8px;"></div>
                </div>
                <button type="button" onclick="editAutoPick()" style="background:#3b82f6;color:white;padding:8px 20px;border:none;border-radius:8px;cursor:pointer;">自动添加试题</button>
                <div id="editAutoStatus" style="margin-top:8px;"></div>
            </div>

            <div class="score-row">
                <div class="form-group">
                    <label>单选题分值</label>
                    <input type="number" name="danxscore" value="<%= paper.getLwmdanxscore() %>" min="1" onchange="updateTotal()">
                </div>
                <div class="form-group">
                    <label>多选题分值</label>
                    <input type="number" name="duoxscore" value="<%= paper.getLwmduoxscore() %>" min="1" onchange="updateTotal()">
                </div>
                <div class="form-group">
                    <label>判断题分值</label>
                    <input type="number" name="pdscore" value="<%= paper.getLwmpdscore() %>" min="1" onchange="updateTotal()">
                </div>
                <div class="form-group">
                    <label>简答题分值</label>
                    <input type="number" name="jdscore" value="<%= paper.getLwmjdscore() %>" min="1" onchange="updateTotal()">
                </div>
            </div>

            <script>
                var existingIds = new Set();
                <% if (currentQuestions != null) {
                    for (lwmExamQuestion q : currentQuestions) { %>
                        existingIds.add(<%= q.getLwmquestionid() %>);
                <% } } %>
                var paperSubjectId = <%= paper.getLwmsubjectid() %>;

                function switchEditMode(mode, btn) {
                    document.getElementById('editMode').value = mode;
                    document.querySelectorAll('.mode-tab').forEach(function(t) {
                        t.style.background = 'white'; t.style.borderColor = '#e2e8f0'; t.style.color = '#475569';
                    });
                    btn.style.background = '#ecfdf5'; btn.style.borderColor = '#059669'; btn.style.color = '#059669';
                    document.getElementById('editManualArea').style.display = mode === 'manual' ? 'block' : 'none';
                    document.getElementById('editAutoArea').style.display = mode === 'auto' ? 'block' : 'none';
                    if (mode === 'manual') editLoadQuestions();
                }

                function getExcludeParam() {
                    var ids = [];
                    existingIds.forEach(function(id) { ids.push(id); });
                    // Also add currently checked questionIds (not yet in existingIds)
                    var checked = document.querySelectorAll('#currentQuestions input[name="questionIds"]:checked');
                    checked.forEach(function(cb) {
                        var cid = parseInt(cb.value);
                        if (!existingIds.has(cid)) ids.push(cid);
                    });
                    return ids.length > 0 ? ids.join(',') : '';
                }

                function editLoadQuestions() {
                    var type = document.getElementById('editTypeFilter').value;
                    var exclude = getExcludeParam();
                    var url = 'lwmLoadQuestions?subject=' + paperSubjectId;
                    if (type) url += '&type=' + encodeURIComponent(type);
                    if (exclude) url += '&exclude=' + encodeURIComponent(exclude);
                    var list = document.getElementById('editQuestionList');
                    list.innerHTML = '<p style="color:#94a3b8;">加载中...</p>';
                    fetch(url).then(function(r) { return r.text(); }).then(function(html) {
                        list.innerHTML = html;
                    }).catch(function() {
                        list.innerHTML = '<p style="color:#ef4444;">加载失败</p>';
                    });
                }

                function addSelectedQuestions() {
                    var addChecks = document.querySelectorAll('#editQuestionList input[name="addQuestionIds"]:checked');
                    if (addChecks.length === 0) { alert('请先勾选要添加的试题'); return; }
                    var container = document.getElementById('currentQuestions');
                    // Remove empty placeholder
                    var placeholder = container.querySelector('p');
                    if (placeholder) placeholder.remove();
                    addChecks.forEach(function(cb) {
                        var qId = parseInt(cb.value);
                        if (existingIds.has(qId)) return;
                        existingIds.add(qId);
                        var qText = cb.parentElement.textContent.trim();
                        var typeMatch = qText.match(/^\[([^\]]+)\]\s*/);
                        var typeName = typeMatch ? typeMatch[1] : '';
                        var contentOnly = typeMatch ? qText.substring(typeMatch[0].length) : qText;
                        var div = document.createElement('div');
                        div.className = 'q-item';
                        div.innerHTML = '<input type="checkbox" name="questionIds" value="' + qId + '" checked> ' +
                            '<span class="badge">' + typeName + '</span> ' +
                            '<span>' + contentOnly + '</span> ' +
                            '<button type="button" class="btn-remove" onclick="this.parentElement.remove();existingIds.delete(' + qId + ');updateTotal();editLoadQuestions()">移除</button>';
                        container.appendChild(div);
                        cb.parentElement.remove();
                    });
                    updateTotal();
                }

                function editAutoPick() {
                    var danxN = parseInt(document.getElementById('editDanxNum').value) || 0;
                    var duoxN = parseInt(document.getElementById('editDuoxNum').value) || 0;
                    var pdN = parseInt(document.getElementById('editPdNum').value) || 0;
                    var jdN = parseInt(document.getElementById('editJdNum').value) || 0;
                    if (danxN + duoxN + pdN + jdN <= 0) { alert('请至少设置一种题型的数量'); return; }
                    var exclude = getExcludeParam();
                    var url = 'lwmRandomPickQuestions?subject=' + paperSubjectId +
                        '&danxnum=' + danxN + '&duoxnum=' + duoxN + '&pdnum=' + pdN + '&jdnum=' + jdN;
                    if (exclude) url += '&exclude=' + encodeURIComponent(exclude);
                    document.getElementById('editAutoStatus').innerHTML = '<span style="color:#3b82f6;">正在自动组卷...</span>';
                    fetch(url).then(function(r) { return r.text(); }).then(function(html) {
                        if (html.indexOf('数量不足') >= 0) {
                            document.getElementById('editAutoStatus').innerHTML = html;
                            return;
                        }
                        if (!html.trim()) { document.getElementById('editAutoStatus').innerHTML = ''; return; }
                        var container = document.getElementById('currentQuestions');
                        var placeholder = container.querySelector('p');
                        if (placeholder) placeholder.remove();
                        var temp = document.createElement('div');
                        temp.innerHTML = html;
                        var items = temp.querySelectorAll('.q-item');
                        items.forEach(function(item) {
                            var cb = item.querySelector('input[type="checkbox"]');
                            if (cb) {
                                var qId = parseInt(cb.value);
                                if (!existingIds.has(qId)) {
                                    existingIds.add(qId);
                                    container.appendChild(item);
                                }
                            }
                        });
                        document.getElementById('editAutoStatus').innerHTML = '<span style="color:#059669;">成功添加 ' + items.length + ' 道试题</span>';
                        // Reset inputs
                        document.getElementById('editDanxNum').value = 0;
                        document.getElementById('editDuoxNum').value = 0;
                        document.getElementById('editPdNum').value = 0;
                        document.getElementById('editJdNum').value = 0;
                        updateTotal();
                    }).catch(function() {
                        document.getElementById('editAutoStatus').innerHTML = '<span style="color:#ef4444;">加载失败</span>';
                    });
                }

                function updateTotal() {
                    var checked = document.querySelectorAll('#currentQuestions input[type=checkbox]:checked');
                    var titleEl = document.getElementById('currentQuestionsTitle');
                    if (titleEl) titleEl.textContent = '当前试题（共 ' + checked.length + ' 道）';
                    var danxS = parseInt(document.querySelector('input[name="danxscore"]').value) || 0;
                    var duoxS = parseInt(document.querySelector('input[name="duoxscore"]').value) || 0;
                    var pdS = parseInt(document.querySelector('input[name="pdscore"]').value) || 0;
                    var jdS = parseInt(document.querySelector('input[name="jdscore"]').value) || 0;
                    var total = 0;
                    checked.forEach(function(cb) {
                        var item = cb.parentElement;
                        var badge = item.querySelector('.badge');
                        if (badge) {
                            var type = badge.textContent.trim();
                            if (type === '单选题') total += danxS;
                            else if (type === '多选题') total += duoxS;
                            else if (type === '判断题') total += pdS;
                            else if (type === '简答题') total += jdS;
                        }
                    });
                    document.getElementById('totalScore').textContent = total;
                }
            </script>
        <% } %>

        <div class="form-group" style="text-align:right;padding:12px 0;border-top:2px solid #e2e8f0;margin-top:8px;">
            <span style="font-weight:600;font-size:1.1rem;color:#059669;">试卷总分：<span id="totalScore" style="font-size:1.3rem;"><%= paper.getLwmexamsore() %></span> 分</span>
        </div>
        <div class="btn-row">
            <a href="lwmQueryPaper" class="btn btn-secondary">取消</a>
            <button type="submit" class="btn btn-primary">保存修改</button>
        </div>
    </form>
</div>
</body>
</html>
