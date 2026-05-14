<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmExamPaper" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmTeacher" %>
<%@ page import="com.example.lwmexam.dao.lwmexam.lwmCourseArrangeDAO" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmstudentcourseteacher" %>
<%@ page import="java.util.List" %>
<%
    lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
    if (teacher == null) { response.sendRedirect("login.jsp"); return; }

    lwmExamPaper paper = (lwmExamPaper) request.getAttribute("paper");
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
        .container { max-width:700px; margin:0 auto; background:white; padding:32px; border-radius:12px; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        h2 { margin-bottom:24px; color:#1e293b; }
        .form-group { margin-bottom:18px; }
        .form-group label { display:block; margin-bottom:6px; color:#475569; font-weight:500; font-size:0.9rem; }
        .form-group select, .form-group input { width:100%; padding:10px 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.9rem; }
        .inline-group { display:flex; gap:12px; }
        .inline-group .form-group { flex:1; }
        .warning { background:#fef3c7; color:#d97706; padding:12px 16px; border-radius:8px; margin-bottom:18px; font-size:0.85rem; }
        .btn-row { display:flex; gap:12px; justify-content:flex-end; margin-top:20px; }
        .btn { padding:10px 24px; border-radius:8px; cursor:pointer; border:none; font-size:0.9rem; text-decoration:none; }
        .btn-primary { background:#059669; color:white; }
        .btn-secondary { background:#e2e8f0; color:#475569; }
    </style>
</head>
<body>
<div class="container">
    <h2>修改试卷</h2>
    <% if (hasSubmit) { %>
        <div class="warning">该试卷已有学生提交，仅可修改基本信息，不可修改试题组成。</div>
    <% } %>
    <form method="post" action="lwmUpdatePaper">
        <input type="hidden" name="lwmpaperid" value="<%= paper.getLwmpaperid() %>">

        <div class="form-group">
            <label>试卷名称</label>
            <input type="text" name="lwmpapername" required value="<%= paper.getLwmpapername() %>">
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
                <label>试卷总分</label>
                <input type="number" name="lwmexamsore" required value="<%= paper.getLwmexamsore() %>">
            </div>
        </div>

        <div class="btn-row">
            <a href="lwmQueryPaper" class="btn btn-secondary">取消</a>
            <button type="submit" class="btn btn-primary">保存修改</button>
        </div>
    </form>
</div>
</body>
</html>
