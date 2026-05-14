<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmExamPaper" %>
<%
    List<lwmExamPaper> papers = (List<lwmExamPaper>) request.getAttribute("papers");
    List<String> classList = (List<String>) request.getAttribute("classList");
    List<String> paperList = (List<String>) request.getAttribute("paperList");
    List<String[]> subjectList = (List<String[]>) request.getAttribute("subjectList");
    String selectedClass = (String) request.getAttribute("selectedClass");
    String selectedPaper = (String) request.getAttribute("selectedPaper");
    String selectedSubjectId = (String) request.getAttribute("selectedSubjectId");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>试卷管理</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; padding:24px; }
        .container { max-width:1200px; margin:0 auto; }
        .header { display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; }
        .header h2 { color:#1e293b; font-size:1.5rem; }
        .btn { padding:8px 20px; border-radius:8px; cursor:pointer; text-decoration:none; font-size:0.9rem; border:none; display:inline-block; }
        .btn-primary { background:#059669; color:white; }
        .btn-edit { background:#3b82f6; color:white; padding:6px 14px; border-radius:6px; text-decoration:none; font-size:0.8rem; margin-right:6px; }
        .btn-danger { background:#ef4444; color:white; padding:6px 14px; border-radius:6px; text-decoration:none; font-size:0.8rem; }
        table { width:100%; background:white; border-radius:12px; overflow:hidden; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        th { background:#f8fafc; padding:12px 14px; text-align:left; font-weight:600; color:#475569; font-size:0.85rem; }
        td { padding:10px 14px; border-bottom:1px solid #f1f5f9; color:#334155; font-size:0.85rem; }
        tr:hover { background:#f8fafc; }
        .empty { text-align:center; padding:40px; color:#94a3b8; }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <h2>试卷管理</h2>
        <a href="lwmteacher_paper_create.jsp" class="btn btn-primary">+ 创建试卷</a>
    </div>
    <div style="background:white;padding:16px 20px;border-radius:12px;margin-bottom:20px;box-shadow:0 1px 3px rgba(0,0,0,0.08);">
        <form method="get" action="lwmQueryPaper" style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
            <label style="font-weight:500;color:#475569;font-size:0.9rem;">班级：</label>
            <select name="classname" style="padding:8px 12px;border:1px solid #e2e8f0;border-radius:8px;font-size:0.9rem;">
                <option value="">-- 全部班级 --</option>
                <% if (classList != null) {
                    for (String cls : classList) { %>
                        <option value="<%= cls %>" <%= cls.equals(selectedClass) ? "selected" : "" %>><%= cls %></option>
                <% } } %>
            </select>
            <label style="font-weight:500;color:#475569;font-size:0.9rem;">试卷：</label>
            <select name="papername" style="padding:8px 12px;border:1px solid #e2e8f0;border-radius:8px;font-size:0.9rem;">
                <option value="">-- 全部试卷 --</option>
                <% if (paperList != null) {
                    for (String pn : paperList) { %>
                        <option value="<%= pn %>" <%= pn.equals(selectedPaper) ? "selected" : "" %>><%= pn %></option>
                <% } } %>
            </select>
            <label style="font-weight:500;color:#475569;font-size:0.9rem;">科目：</label>
            <select name="subjectid" style="padding:8px 12px;border:1px solid #e2e8f0;border-radius:8px;font-size:0.9rem;">
                <option value="">-- 全部科目 --</option>
                <% if (subjectList != null) {
                    for (String[] sub : subjectList) { %>
                        <option value="<%= sub[0] %>" <%= sub[0].equals(selectedSubjectId) ? "selected" : "" %>><%= sub[1] %></option>
                <% } } %>
            </select>
            <button type="submit" style="padding:8px 20px;background:#3b82f6;color:white;border:none;border-radius:8px;cursor:pointer;font-size:0.9rem;">查询</button>
            <% if ((selectedClass != null && !selectedClass.isEmpty()) || (selectedPaper != null && !selectedPaper.isEmpty()) || (selectedSubjectId != null && !selectedSubjectId.isEmpty())) { %>
                <a href="lwmQueryPaper" style="color:#64748b;font-size:0.85rem;">显示全部</a>
            <% } %>
        </form>
    </div>
    <table>
        <thead>
            <tr><th>序号</th><th>试卷名称</th><th>科目</th><th>班级</th><th>时长</th><th>总分</th><th>操作</th></tr>
        </thead>
        <tbody>
            <% if (papers != null && !papers.isEmpty()) {
                int i = 1;
                for (lwmExamPaper p : papers) { %>
                    <tr>
                        <td><%= i++ %></td>
                        <td><%= p.getLwmpapername() %></td>
                        <td><%= p.getLwmsubjectname() != null ? p.getLwmsubjectname() : "" %></td>
                        <td><%= (p.getLwmclassname() != null && !p.getLwmclassname().isEmpty()) ? p.getLwmclassname() : "<span style='color:#94a3b8;'>未发布</span>" %></td>
                        <td><%= p.getLwmexamtime() %>分钟</td>
                        <td><%= p.getLwmexamsore() %></td>
                        <td>
                            <% String cls = p.getLwmclassname();
                               boolean published = cls != null && !cls.isEmpty(); %>
                            <a href="lwmPublishPaper?id=<%= p.getLwmpaperid() %>" class="btn-edit" style="background:<%= published ? "#f59e0b" : "#059669" %>;"><%= published ? "修改发布" : "发布" %></a>
                            <a href="lwmUpdatePaper?id=<%= p.getLwmpaperid() %>" class="btn-edit">编辑</a>
                            <a href="lwmDeletePaper?id=<%= p.getLwmpaperid() %>" class="btn-danger" onclick="return confirm('确定删除该试卷？')">删除</a>
                        </td>
                    </tr>
                <% }
            } else { %>
                <tr><td colspan="7" class="empty">暂无试卷</td></tr>
            <% } %>
        </tbody>
    </table>
</div>
</body>
</html>
