<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmExamQuestion" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmTeacher" %>
<%@ page import="com.example.lwmexam.dao.lwmexam.lwmCourseArrangeDAO" %>
<%@ page import="com.example.lwmexam.dao.lwmexam.lwmKnowledgePointDAO" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmstudentcourseteacher" %>
<%@ page import="java.util.List" %>
<%
    lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
    if (teacher == null) { response.sendRedirect("login.jsp"); return; }

    lwmExamQuestion question = (lwmExamQuestion) request.getAttribute("question");
    boolean isEdit = question != null;

    lwmCourseArrangeDAO arrangeDao = new lwmCourseArrangeDAO();
    List<lwmstudentcourseteacher> courses = arrangeDao.lwmQuerySomeSct(
        "SELECT sct.*, sub.lwmsubjectname, tea.lwmteachername FROM lwmstudentcourseteacher sct LEFT JOIN lwmexamsubject sub ON sct.lwmsubjectid = sub.lwmsubjectid LEFT JOIN lwmteacher tea ON sct.lwmteacherid = tea.lwmteacherid WHERE sct.lwmteacherid = ?",
        new Object[]{teacher.getLwmteacherid()});
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title><%= isEdit ? "编辑试题" : "添加试题" %></title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; padding:24px; }
        .container { max-width:700px; margin:0 auto; background:white; padding:32px; border-radius:12px; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        h2 { margin-bottom:24px; color:#1e293b; }
        .form-group { margin-bottom:18px; }
        .form-group label { display:block; margin-bottom:6px; color:#475569; font-weight:500; font-size:0.9rem; }
        .form-group select, .form-group input, .form-group textarea { width:100%; padding:10px 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.9rem; font-family:inherit; }
        .form-group textarea { resize:vertical; min-height:80px; }
        .options-area { display:none; }
        .options-area.show { display:block; }
        .btn-row { display:flex; gap:12px; justify-content:flex-end; margin-top:20px; }
        .btn { padding:10px 24px; border-radius:8px; cursor:pointer; border:none; font-size:0.9rem; text-decoration:none; }
        .btn-primary { background:#059669; color:white; }
        .btn-secondary { background:#e2e8f0; color:#475569; }
    </style>
</head>
<body>
<div class="container">
    <h2><%= isEdit ? "编辑试题" : "添加试题" %></h2>
    <form method="post" action="<%= isEdit ? "lwmUpdateQuestion" : "lwmAddQuestion" %>" id="questionForm" onsubmit="return validateForm()">
        <% if (isEdit) { %>
            <input type="hidden" name="lwmquestionid" value="<%= question.getLwmquestionid() %>">
        <% } %>
        <div class="form-group">
            <label>所属科目</label>
            <select name="lwmsubjectid" id="subjectSelect" required onchange="loadKnowledgePoints()">
                <option value="">请选择科目</option>
                <% java.util.Set<Integer> seenSubjects = new java.util.HashSet<>();
                for (lwmstudentcourseteacher c : courses) {
                    if (seenSubjects.add(c.getLwmsubjectid())) { %>
                    <option value="<%= c.getLwmsubjectid() %>" <%= isEdit && question.getLwmsubjectid() == c.getLwmsubjectid() ? "selected" : "" %>><%= c.getLwmsubjectname() %></option>
                <% } } %>
            </select>
        </div>
        <div class="form-group" id="kpSection">
            <label>关联知识点</label>
            <div id="kpCheckboxes" style="max-height:160px;overflow-y:auto;border:1px solid #e2e8f0;border-radius:8px;padding:10px 14px;margin-bottom:8px;">
                <span id="kpPlaceholder" style="color:#94a3b8;font-size:0.85rem;">请先选择科目</span>
            </div>
            <div style="display:flex;gap:8px;">
                <input type="text" id="newKpName" placeholder="快速添加新知识点..." style="flex:1;padding:8px 12px;border:1px solid #e2e8f0;border-radius:8px;font-size:0.85rem;">
                <button type="button" id="addKpBtn" onclick="quickAddKP()" class="btn btn-primary" style="padding:6px 14px;font-size:0.85rem;">添加</button>
            </div>
        </div>
        <div class="form-group">
            <label>题型</label>
            <select name="lwmquestiontype" id="questiontype" required onchange="toggleOptions()">
                <option value="">请选择题型</option>
                <option value="单选题" <%= isEdit && "单选题".equals(question.getLwmquestiontype()) ? "selected" : "" %>>单选题</option>
                <option value="多选题" <%= isEdit && "多选题".equals(question.getLwmquestiontype()) ? "selected" : "" %>>多选题</option>
                <option value="判断题" <%= isEdit && "判断题".equals(question.getLwmquestiontype()) ? "selected" : "" %>>判断题</option>
                <option value="简答题" <%= isEdit && "简答题".equals(question.getLwmquestiontype()) ? "selected" : "" %>>简答题</option>
            </select>
        </div>
        <div class="form-group">
            <label>题目内容</label>
            <textarea name="lwmquestioncontent" required><%= isEdit ? question.getLwmquestioncontent() : "" %></textarea>
        </div>
        <%
            String editAnswer = isEdit ? question.getLwmcorrectanswer() : "";
            String qtype = isEdit ? question.getLwmquestiontype() : "";
            boolean isMultiEdit = "多选题".equals(qtype);
            boolean isA = editAnswer.contains("A"), isB = editAnswer.contains("B");
            boolean isC = editAnswer.contains("C"), isD = editAnswer.contains("D");
        %>
        <div id="optionsArea" class="options-area <%= isEdit && ("单选题".equals(qtype) || isMultiEdit) ? "show" : "" %>">
            <div class="form-group" style="display:flex;align-items:center;gap:10px;">
                <input type="<%= isMultiEdit ? "checkbox" : "radio" %>" name="lwmcorrectanswer" value="A" <%= isA ? "checked" : "" %> class="answer-select" style="width:18px;height:18px;">
                <label style="flex:1;">选项A</label>
                <input type="text" name="lwmoptiona" style="flex:2;" value="<%= isEdit ? question.getLwmoptiona() : "" %>">
            </div>
            <div class="form-group" style="display:flex;align-items:center;gap:10px;">
                <input type="<%= isMultiEdit ? "checkbox" : "radio" %>" name="lwmcorrectanswer" value="B" <%= isB ? "checked" : "" %> class="answer-select" style="width:18px;height:18px;">
                <label style="flex:1;">选项B</label>
                <input type="text" name="lwmoptionb" style="flex:2;" value="<%= isEdit ? question.getLwmoptionb() : "" %>">
            </div>
            <div class="form-group" style="display:flex;align-items:center;gap:10px;">
                <input type="<%= isMultiEdit ? "checkbox" : "radio" %>" name="lwmcorrectanswer" value="C" <%= isC ? "checked" : "" %> class="answer-select" style="width:18px;height:18px;">
                <label style="flex:1;">选项C</label>
                <input type="text" name="lwmoptionc" style="flex:2;" value="<%= isEdit ? question.getLwmoptionc() : "" %>">
            </div>
            <div class="form-group" style="display:flex;align-items:center;gap:10px;">
                <input type="<%= isMultiEdit ? "checkbox" : "radio" %>" name="lwmcorrectanswer" value="D" <%= isD ? "checked" : "" %> class="answer-select" style="width:18px;height:18px;">
                <label style="flex:1;">选项D</label>
                <input type="text" name="lwmoptiond" style="flex:2;" value="<%= isEdit ? question.getLwmoptiond() : "" %>">
            </div>
        </div>

        <div id="judgeAnswer" class="form-group" style="display:<%= "判断题".equals(qtype) ? "block" : "none" %>;">
            <label>正确答案</label>
            <div style="display:flex;gap:24px;padding-top:6px;">
                <label><input type="radio" name="lwmcorrectanswer" value="对" <%= "对".equals(editAnswer) ? "checked" : "" %>> 对</label>
                <label><input type="radio" name="lwmcorrectanswer" value="错" <%= "错".equals(editAnswer) ? "checked" : "" %>> 错</label>
            </div>
        </div>

        <div id="textAnswer" class="form-group" style="display:<%= "简答题".equals(qtype) ? "block" : "none" %>;">
            <label>正确答案</label>
            <input type="text" name="lwmcorrectanswer" id="textAnswerInput" value="<%= ("简答题".equals(qtype) && isEdit) ? editAnswer : "" %>">
        </div>
        <div class="btn-row">
            <a href="lwmQueryQuestion" class="btn btn-secondary">取消</a>
            <button type="submit" class="btn btn-primary">保存</button>
        </div>
    </form>
</div>
<script>
    var editAnswer = '<%= isEdit ? editAnswer.replace("'", "\\'") : "" %>';
    function toggleOptions() {
        var type = document.getElementById('questiontype').value;
        var optArea = document.getElementById('optionsArea');
        var judgeAnswer = document.getElementById('judgeAnswer');
        var textAnswer = document.getElementById('textAnswer');
        var selects = document.querySelectorAll('.answer-select');
        var textInput = document.getElementById('textAnswerInput');

        optArea.classList.remove('show');
        judgeAnswer.style.display = 'none';
        textAnswer.style.display = 'none';
        if (textInput) textInput.value = '';

        if (type === '单选题') {
            optArea.classList.add('show');
            selects.forEach(function(el) { el.type = 'radio'; });
        } else if (type === '多选题') {
            optArea.classList.add('show');
            selects.forEach(function(el) { el.type = 'checkbox'; });
        } else if (type === '判断题') {
            judgeAnswer.style.display = 'block';
        } else if (type === '简答题') {
            textAnswer.style.display = 'block';
            if (textInput && editAnswer) textInput.value = editAnswer;
        }
    }
    function validateForm() {
        var type = document.getElementById('questiontype').value;
        if (!type) { alert('请选择题型'); return false; }

        // Validate correct answer
        var answerSelected = false;
        if (type === '单选题' || type === '多选题') {
            var checks = document.querySelectorAll('#optionsArea input[name="lwmcorrectanswer"]:checked');
            answerSelected = checks.length > 0;
            // Validate all ABCD options are filled
            var optA = document.querySelector('input[name="lwmoptiona"]').value.trim();
            var optB = document.querySelector('input[name="lwmoptionb"]').value.trim();
            var optC = document.querySelector('input[name="lwmoptionc"]').value.trim();
            var optD = document.querySelector('input[name="lwmoptiond"]').value.trim();
            if (!optA || !optB || !optC || !optD) {
                alert('请填写全部ABCD选项的内容'); return false;
            }
            // Validate no duplicate options
            var opts = [optA, optB, optC, optD];
            var hasDup = false;
            for (var i = 0; i < opts.length; i++) {
                for (var j = i + 1; j < opts.length; j++) {
                    if (opts[i] === opts[j]) { hasDup = true; break; }
                }
                if (hasDup) break;
            }
            if (hasDup) { alert('ABCD选项中有重复内容，请修改'); return false; }
        } else if (type === '判断题') {
            var radios = document.querySelectorAll('#judgeAnswer input[name="lwmcorrectanswer"]:checked');
            answerSelected = radios.length > 0;
        } else if (type === '简答题') {
            var textVal = document.getElementById('textAnswerInput').value.trim();
            answerSelected = textVal.length > 0;
        }
        if (!answerSelected) { alert('请选择正确答案'); return false; }
        return true;
    }
    // Restore options/answer area visibility after history.go(-1) or bfcache restore
    window.addEventListener('pageshow', function() { toggleOptions(); });

    // Knowledge point loading
    var existingKpIds = [];
    <% if (isEdit) {
        lwmKnowledgePointDAO kpDao = new lwmKnowledgePointDAO();
        List<Integer> kpIds = kpDao.getKPIdsByQuestion(question.getLwmquestionid());
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < kpIds.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append(kpIds.get(i));
        }
    %>
    existingKpIds = [<%= sb.toString() %>];
    <% } %>

    function loadKnowledgePoints() {
        var subjectId = document.getElementById('subjectSelect').value;
        var container = document.getElementById('kpCheckboxes');
        if (!subjectId) {
            container.innerHTML = '<span id="kpPlaceholder" style="color:#94a3b8;font-size:0.85rem;">请先选择科目</span>';
            return;
        }
        container.innerHTML = '<span style="color:#94a3b8;font-size:0.85rem;">加载中...</span>';
        fetch('lwmManageKnowledgePoint?subjectid=' + encodeURIComponent(subjectId))
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (!data || data.length === 0) {
                    container.innerHTML = '<span style="color:#94a3b8;font-size:0.85rem;">暂无知识点，请添加</span>';
                    return;
                }
                var html = '';
                for (var i = 0; i < data.length; i++) {
                    var kp = data[i];
                    var checked = '';
                    for (var j = 0; j < existingKpIds.length; j++) {
                        if (existingKpIds[j] === kp.kpid) { checked = ' checked'; break; }
                    }
                    html += '<span class="kp-item" style="display:inline-block;margin-right:16px;margin-bottom:6px;">';
                    html += '<label style="font-size:0.85rem;cursor:pointer;">';
                    html += '<input type="checkbox" name="kpids" value="' + kp.kpid + '"' + checked + ' style="margin-right:4px;">';
                    html += kp.kpname;
                    html += '</label>';
                    html += '<span onclick="deleteKP(' + kp.kpid + ')" style="cursor:pointer;color:#ef4444;margin-left:4px;font-size:0.85rem;" title="删除知识点">×</span>';
                    html += '</span>';
                }
                container.innerHTML = html;
            })
            .catch(function() {
                container.innerHTML = '<span style="color:#ef4444;font-size:0.85rem;">加载失败</span>';
            });
    }

    function quickAddKP() {
        var subjectId = document.getElementById('subjectSelect').value;
        var nameInput = document.getElementById('newKpName');
        var kpname = nameInput.value.trim();
        if (!subjectId) { alert('请先选择科目'); return; }
        if (!kpname) { alert('请输入知识点名称'); return; }

        var formData = new URLSearchParams();
        formData.append('action', 'add');
        formData.append('subjectid', subjectId);
        formData.append('kpname', kpname);
        formData.append('kpdesc', '');

        document.getElementById('addKpBtn').disabled = true;
        document.getElementById('addKpBtn').textContent = '添加中...';

        fetch('lwmManageKnowledgePoint', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData.toString()
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            document.getElementById('addKpBtn').disabled = false;
            document.getElementById('addKpBtn').textContent = '添加';
            if (data.success) {
                nameInput.value = '';
                existingKpIds.push(data.kpid);
                loadKnowledgePoints();
            } else {
                alert('添加失败: ' + (data.message || '未知错误'));
            }
        })
        .catch(function() {
            document.getElementById('addKpBtn').disabled = false;
            document.getElementById('addKpBtn').textContent = '添加';
            alert('网络错误，添加失败');
        });
    }

    var deletingKpId = 0;
    function deleteKP(kpId) {
        if (deletingKpId) return;
        if (!confirm('确定删除该知识点？删除后不可恢复')) return;
        deletingKpId = kpId;
        var formData = new URLSearchParams();
        formData.append('action', 'delete');
        formData.append('kpid', kpId);
        fetch('lwmManageKnowledgePoint', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData.toString()
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                existingKpIds = existingKpIds.filter(function(id) { return id !== kpId; });
                loadKnowledgePoints();
            } else {
                alert(data.message || '删除失败');
            }
            deletingKpId = 0;
        })
        .catch(function() {
            alert('网络错误，删除失败');
            deletingKpId = 0;
        });
    }

    // Load KPs on page load if editing with a subject already selected
    window.addEventListener('DOMContentLoaded', function() {
        var subjectId = document.getElementById('subjectSelect').value;
        if (subjectId) { loadKnowledgePoints(); }
    });
</script>
</body>
</html>
