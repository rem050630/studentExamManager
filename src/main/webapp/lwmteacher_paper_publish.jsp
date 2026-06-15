<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmExamPaper" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%
    lwmExamPaper paper = (lwmExamPaper) request.getAttribute("paper");
    List<String> teacherClasses = (List<String>) request.getAttribute("teacherClasses");
    Set<String> publishedClasses = (Set<String>) request.getAttribute("publishedClasses");
    Set<String> submittedClasses = (Set<String>) request.getAttribute("submittedClasses");
    if (submittedClasses == null) submittedClasses = new java.util.HashSet<String>();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>发布试卷</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; padding:24px; }
        .container { max-width:600px; margin:0 auto; background:white; padding:32px; border-radius:12px; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        h2 { margin-bottom:8px; color:#1e293b; }
        .subtitle { color:#64748b; font-size:0.9rem; margin-bottom:24px; }
        .class-list { display:flex; flex-wrap:wrap; gap:12px; margin-bottom:24px; }
        .class-item { display:flex; align-items:center; gap:8px; padding:12px 16px; border:2px solid #e2e8f0; border-radius:8px; cursor:pointer; font-size:0.9rem; transition:all 0.2s; }
        .class-item:hover { border-color:#059669; background:#f0fdf4; }
        .class-item.selected { border-color:#059669; background:#ecfdf5; color:#059669; font-weight:600; }
        .class-item:has(input:disabled) { border-color:#f59e0b; background:#fffbeb; cursor:not-allowed; }
        .class-item input[type="checkbox"] { display:none; }
        .btn-row { display:flex; gap:12px; justify-content:flex-end; margin-top:20px; }
        .btn { padding:10px 24px; border-radius:8px; cursor:pointer; border:none; font-size:0.9rem; text-decoration:none; }
        .btn-primary { background:#059669; color:white; }
        .btn-secondary { background:#e2e8f0; color:#475569; }
    </style>
</head>
<body>
<div class="container">
    <h2>发布试卷</h2>
    <p class="subtitle">试卷：<strong><%= paper.getLwmpapername() %></strong></p>
    <p style="color:#475569;font-weight:500;margin-bottom:12px;">选择要发布到的班级（可多选）：</p>

        <% if (!submittedClasses.isEmpty()) { %>
            <div style="background:#fef3c7;color:#d97706;padding:10px 16px;border-radius:8px;margin-bottom:12px;font-size:0.85rem;">
                <i class="fas fa-exclamation-triangle"></i> 以下班级已有学生完成考试，<strong>无法取消发布</strong>
            </div>
        <% } %>

    <form method="post" action="lwmPublishPaper" id="publishForm">
        <input type="hidden" name="paperId" value="<%= paper.getLwmpaperid() %>">
        <div class="class-list">
            <% if (teacherClasses != null && !teacherClasses.isEmpty()) {
                for (String cls : teacherClasses) {
                    boolean checked = publishedClasses != null && publishedClasses.contains(cls);
                    boolean submitted = submittedClasses.contains(cls); %>
                    <label class="class-item <%= checked ? "selected" : "" %>" style="<%= submitted ? "opacity:0.7;" : "" %>">
                        <input type="checkbox" name="classes" value="<%= cls %>" <%= checked ? "checked" : "" %> <%= submitted ? "disabled" : "" %> onchange="this.parentElement.classList.toggle('selected', this.checked)">
                        <%= cls %> <%= submitted ? "<span style='color:#d97706;font-size:0.75rem;'>(已有提交)</span>" : "" %>
                    </label>
            <% } } else { %>
                <p style="color:#94a3b8;">暂无分配的班级，请先在课程安排中添加班级</p>
            <% } %>
        </div>
        <div class="btn-row">
            <a href="lwmQueryPaper" class="btn btn-secondary">取消</a>
            <button type="submit" class="btn btn-primary">确认发布</button>
        </div>
    </form>
</div>
</body>
</html>
