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

    // Load questions for manual mode if subject selected
    String selSubject = request.getParameter("selSubject");
    String selMode = request.getParameter("selMode");
    List<lwmExamQuestion> allQuestions = null;
    if (selSubject != null && !selSubject.isEmpty() && "manual".equals(selMode)) {
        lwmquestionDAO qDao = new lwmquestionDAO();
        allQuestions = qDao.lwmQueryBySubjectType(selSubject, null, null);
    }
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
        <div class="inline-group">
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
            <div class="form-group">
                <label>分配班级</label>
                <select name="lwmclassname" required>
                    <option value="">请选择</option>
                    <% java.util.Set<String> seenClasses = new java.util.HashSet<>();
                    for (lwmstudentcourseteacher c : courses) {
                        if (seenClasses.add(c.getLwmclassname())) { %>
                        <option value="<%= c.getLwmclassname() %>"><%= c.getLwmclassname() %></option>
                    <% } } %>
                </select>
            </div>
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
            <input type="number" name="lwmexamtime" value="120" required>
        </div>

        <div class="mode-tabs">
            <div class="mode-tab active" onclick="switchMode('manual')">手动组卷</div>
            <div class="mode-tab" onclick="switchMode('auto')">自动组卷</div>
        </div>
        <input type="hidden" name="mode" id="mode" value="manual">

        <div id="manualArea">
            <button type="button" class="load-btn" onclick="loadQuestions()">加载题库试题</button>
            <div id="questionList" class="q-list" style="margin-top:12px;">
                <% if (allQuestions != null && !allQuestions.isEmpty()) {
                    for (lwmExamQuestion q : allQuestions) { %>
                        <div class="q-item">
                            <input type="checkbox" name="questionIds" value="<%= q.getLwmquestionid() %>">
                            <span>[<%= q.getLwmquestiontype() %>] <%= q.getLwmquestioncontent() %></span>
                        </div>
                    <% }
                } else { %>
                    <p style="color:#94a3b8;">选择科目并点击"加载题库试题"</p>
                <% } %>
            </div>
            <div class="inline-group">
                <div class="form-group"><label>单选题分值</label><input type="number" name="danxscore" value="2" min="0"></div>
                <div class="form-group"><label>多选题分值</label><input type="number" name="duoxscore" value="2" min="0"></div>
                <div class="form-group"><label>判断题分值</label><input type="number" name="pdscore" value="1" min="0"></div>
                <div class="form-group"><label>简答题分值</label><input type="number" name="jdscore" value="5" min="0"></div>
            </div>
        </div>
        <div id="autoArea" style="display:none;">
            <div class="inline-group">
                <div class="form-group"><label>单选题数量</label><input type="number" name="danxnum" value="0" min="0"></div>
                <div class="form-group"><label>单选题分值</label><input type="number" name="danxscore" value="2" min="0"></div>
            </div>
            <div class="inline-group">
                <div class="form-group"><label>多选题数量</label><input type="number" name="duoxnum" value="0" min="0"></div>
                <div class="form-group"><label>多选题分值</label><input type="number" name="duoxscore" value="2" min="0"></div>
            </div>
            <div class="inline-group">
                <div class="form-group"><label>判断题数量</label><input type="number" name="pdnum" value="0" min="0"></div>
                <div class="form-group"><label>判断题分值</label><input type="number" name="pdscore" value="1" min="0"></div>
            </div>
            <div class="inline-group">
                <div class="form-group"><label>简答题数量</label><input type="number" name="jdnum" value="0" min="0"></div>
                <div class="form-group"><label>简答题分值</label><input type="number" name="jdscore" value="5" min="0"></div>
            </div>
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
    }
    function loadQuestions() {
        var subjectId = document.getElementById('subjectSelect').value;
        if (!subjectId) { alert('请先选择科目'); return; }
        window.location.href = 'lwmteacher_paper_create.jsp?selSubject=' + subjectId + '&selMode=manual';
    }
</script>
</body>
</html>
