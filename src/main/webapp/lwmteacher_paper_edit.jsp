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

        <div class="inline-group">
            <div class="form-group">
                <label>所属科目</label>
                <select name="lwmsubjectid" required>
                    <% java.util.Set<Integer> seenSubjs = new java.util.HashSet<>();
                    for (lwmstudentcourseteacher c : courses) {
                        if (seenSubjs.add(c.getLwmsubjectid())) { %>
                            <option value="<%= c.getLwmsubjectid() %>" <%= paper.getLwmsubjectid() == c.getLwmsubjectid() ? "selected" : "" %>><%= c.getLwmsubjectname() %></option>
                    <% } } %>
                </select>
            </div>
            <div class="form-group">
                <label>分配班级</label>
                <select name="lwmclassname" required>
                    <% java.util.Set<String> seenClasses = new java.util.HashSet<>();
                    for (lwmstudentcourseteacher c : courses) {
                        if (seenClasses.add(c.getLwmclassname())) { %>
                            <option value="<%= c.getLwmclassname() %>" <%= paper.getLwmclassname().equals(c.getLwmclassname()) ? "selected" : "" %>><%= c.getLwmclassname() %></option>
                    <% } } %>
                </select>
            </div>
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
                <input type="number" name="lwmexamtime" required value="<%= paper.getLwmexamtime() %>">
            </div>
            <div class="form-group">
                <label>试卷总分（自动计算）</label>
                <input type="number" name="lwmexamsore" value="<%= paper.getLwmexamsore() %>" readonly style="background:#f8fafc;">
            </div>
        </div>

        <% if (!hasSubmit) { %>
            <h3>当前试题（共 <%= currentQuestions != null ? currentQuestions.size() : 0 %> 道）</h3>
            <div class="q-section" id="currentQuestions">
                <% if (currentQuestions != null && !currentQuestions.isEmpty()) {
                    for (lwmExamQuestion q : currentQuestions) { %>
                        <div class="q-item">
                            <input type="checkbox" name="questionIds" value="<%= q.getLwmquestionid() %>" checked>
                            <span class="badge"><%= q.getLwmquestiontype() %></span>
                            <span><%= q.getLwmquestioncontent() %></span>
                            <button type="button" class="btn-remove" onclick="this.parentElement.remove();updateTotal()">移除</button>
                        </div>
                    <% }
                } else { %>
                    <p style="color:#94a3b8;">暂无试题</p>
                <% } %>
            </div>

            <h3>添加试题</h3>
            <select class="add-select" id="addQuestionSelect" onchange="addQuestion()">
                <option value="">-- 选择题库中的试题添加 --</option>
                <% if (subjectQuestions != null) {
                    for (lwmExamQuestion q : subjectQuestions) { %>
                        <option value="<%= q.getLwmquestionid() %>"><%= "[" + q.getLwmquestiontype() + "] " + q.getLwmquestioncontent() %></option>
                <% } } %>
            </select>

            <div class="score-row">
                <div class="form-group">
                    <label>单选题分值</label>
                    <input type="number" name="danxscore" value="<%= paper.getLwmdanxscore() %>" min="0">
                </div>
                <div class="form-group">
                    <label>多选题分值</label>
                    <input type="number" name="duoxscore" value="<%= paper.getLwmduoxscore() %>" min="0">
                </div>
                <div class="form-group">
                    <label>判断题分值</label>
                    <input type="number" name="pdscore" value="<%= paper.getLwmpdscore() %>" min="0">
                </div>
                <div class="form-group">
                    <label>简答题分值</label>
                    <input type="number" name="jdscore" value="<%= paper.getLwmjdscore() %>" min="0">
                </div>
            </div>

            <script>
                // Track added question IDs to avoid duplicates
                var existingIds = new Set();
                <% if (currentQuestions != null) {
                    for (lwmExamQuestion q : currentQuestions) { %>
                        existingIds.add(<%= q.getLwmquestionid() %>);
                <% } } %>

                function addQuestion() {
                    var select = document.getElementById('addQuestionSelect');
                    var qId = select.value;
                    var qText = select.options[select.selectedIndex].text;
                    if (!qId || existingIds.has(parseInt(qId))) { select.value=''; return; }
                    existingIds.add(parseInt(qId));

                    var div = document.createElement('div');
                    div.className = 'q-item';
                    div.innerHTML = '<input type="checkbox" name="questionIds" value="'+qId+'" checked> ' +
                        '<span style="font-size:0.85rem;">'+qText+'</span> ' +
                        '<button type="button" class="btn-remove" onclick="this.parentElement.remove();existingIds.delete('+qId+');updateTotal()">移除</button>';
                    document.getElementById('currentQuestions').appendChild(div);
                    select.value = '';
                    updateTotal();
                }
                function updateTotal() {
                    var checked = document.querySelectorAll('#currentQuestions input[type=checkbox]:checked');
                    document.querySelector('h3').textContent = '当前试题（共 ' + checked.length + ' 道）';
                }
            </script>
        <% } %>

        <div class="btn-row">
            <a href="lwmQueryPaper" class="btn btn-secondary">取消</a>
            <button type="submit" class="btn btn-primary">保存修改</button>
        </div>
    </form>
</div>
</body>
</html>
