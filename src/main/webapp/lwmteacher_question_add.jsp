<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmExamQuestion" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmTeacher" %>
<%@ page import="com.example.lwmexam.dao.lwmexam.lwmCourseArrangeDAO" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmstudentcourseteacher" %>
<%@ page import="java.util.List" %>
<%
    lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
    if (teacher == null) { response.sendRedirect("login.jsp"); return; }

    lwmExamQuestion question = (lwmExamQuestion) request.getAttribute("question");
    boolean isEdit = question != null;

    lwmCourseArrangeDAO arrangeDao = new lwmCourseArrangeDAO();
    List<lwmstudentcourseteacher> courses = arrangeDao.lwmQuerySomeSct(
        "SELECT DISTINCT sct.lwmsubjectid, sub.lwmsubjectname FROM lwmstudentcourseteacher sct LEFT JOIN lwmexamsubject sub ON sct.lwmsubjectid = sub.lwmsubjectid WHERE sct.lwmteacherid = ?",
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
    <form method="post" action="<%= isEdit ? "lwmUpdateQuestion" : "lwmAddQuestion" %>">
        <% if (isEdit) { %>
            <input type="hidden" name="lwmquestionid" value="<%= question.getLwmquestionid() %>">
        <% } %>
        <div class="form-group">
            <label>所属科目</label>
            <select name="lwmsubjectid" required>
                <option value="">请选择科目</option>
                <% for (lwmstudentcourseteacher c : courses) { %>
                    <option value="<%= c.getLwmsubjectid() %>" <%= isEdit && question.getLwmsubjectid() == c.getLwmsubjectid() ? "selected" : "" %>><%= c.getLwmsubjectname() %></option>
                <% } %>
            </select>
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
        <div id="optionsArea" class="options-area <%= isEdit && ("单选题".equals(question.getLwmquestiontype()) || "多选题".equals(question.getLwmquestiontype())) ? "show" : "" %>">
            <div class="form-group"><label>选项A</label><input type="text" name="lwmoptiona" value="<%= isEdit ? question.getLwmoptiona() : "" %>"></div>
            <div class="form-group"><label>选项B</label><input type="text" name="lwmoptionb" value="<%= isEdit ? question.getLwmoptionb() : "" %>"></div>
            <div class="form-group"><label>选项C</label><input type="text" name="lwmoptionc" value="<%= isEdit ? question.getLwmoptionc() : "" %>"></div>
            <div class="form-group"><label>选项D</label><input type="text" name="lwmoptiond" value="<%= isEdit ? question.getLwmoptiond() : "" %>"></div>
        </div>
        <div class="form-group">
            <label>正确答案<%= isEdit && "多选题".equals(question.getLwmquestiontype()) ? "（多选用逗号分隔，如 A,B,C）" : "" %></label>
            <input type="text" name="lwmcorrectanswer" required value="<%= isEdit ? question.getLwmcorrectanswer() : "" %>">
        </div>
        <div class="btn-row">
            <a href="lwmQueryQuestion" class="btn btn-secondary">取消</a>
            <button type="submit" class="btn btn-primary">保存</button>
        </div>
    </form>
</div>
<script>
    function toggleOptions() {
        var type = document.getElementById('questiontype').value;
        var area = document.getElementById('optionsArea');
        if (type === '单选题' || type === '多选题') {
            area.classList.add('show');
        } else {
            area.classList.remove('show');
        }
    }
</script>
</body>
</html>
