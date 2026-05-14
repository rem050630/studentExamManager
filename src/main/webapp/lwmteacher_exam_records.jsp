<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    List<Map<String, Object>> records = (List<Map<String, Object>>) request.getAttribute("records");
    List<String> classList = (List<String>) request.getAttribute("classList");
    List<String> paperList = (List<String>) request.getAttribute("paperList");
    String selectedClass = (String) request.getAttribute("selectedClass");
    String selectedPaper = (String) request.getAttribute("selectedPaper");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>考试情况</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; padding:24px; }
        .container { max-width:1200px; margin:0 auto; }
        .header { margin-bottom:24px; }
        .header h2 { color:#1e293b; font-size:1.5rem; }
        .btn { padding:6px 14px; border-radius:6px; text-decoration:none; font-size:0.85rem; display:inline-block; }
        .btn-primary { background:#3b82f6; color:white; }
        .btn-disabled { background:#cbd5e1; color:#64748b; }
        .badge { padding:4px 10px; border-radius:12px; font-size:0.8rem; font-weight:500; }
        .badge-submitted { background:#dcfce7; color:#16a34a; }
        .badge-reviewed { background:#dbeafe; color:#2563eb; }
        .badge-pending { background:#fef3c7; color:#d97706; }
        table { width:100%; background:white; border-radius:12px; overflow:hidden; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        th { background:#f8fafc; padding:12px 14px; text-align:left; font-weight:600; color:#475569; font-size:0.85rem; }
        td { padding:10px 14px; border-bottom:1px solid #f1f5f9; color:#334155; font-size:0.85rem; }
        tr:hover { background:#f8fafc; }
        .empty { text-align:center; padding:40px; color:#94a3b8; }
    </style>
</head>
<body>
<div class="container">
    <div class="header"><h2>学生考试情况</h2></div>
    <div style="background:white;padding:16px 20px;border-radius:12px;margin-bottom:20px;box-shadow:0 1px 3px rgba(0,0,0,0.08);">
        <form method="get" action="lwmQueryExamRecords" style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
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
            <button type="submit" style="padding:8px 20px;background:#3b82f6;color:white;border:none;border-radius:8px;cursor:pointer;font-size:0.9rem;">查询</button>
            <% if ((selectedClass != null && !selectedClass.isEmpty()) || (selectedPaper != null && !selectedPaper.isEmpty())) { %>
                <a href="lwmQueryExamRecords" style="color:#64748b;font-size:0.85rem;">显示全部</a>
            <% } %>
        </form>
    </div>
    <table>
        <thead>
            <tr><th>序号</th><th>试卷名称</th><th>学号</th><th>姓名</th><th>班级</th><th>开始时间</th><th>提交时间</th><th>状态</th><th>操作</th></tr>
        </thead>
        <tbody>
            <% if (records != null && !records.isEmpty()) {
                for (Map<String, Object> r : records) {
                    int status = (int) r.get("lwmsubmitstatus"); %>
                    <tr>
                        <td><%= r.get("index") %></td>
                        <td><%= r.get("lwmpapername") %></td>
                        <td><%= r.get("lwmstudentno") %></td>
                        <td><%= r.get("lwmstudentname") %></td>
                        <td><%= r.get("lwmclassname") %></td>
                        <td><%= r.get("lwmstarttime") %></td>
                        <td><%= r.get("lwmendtime") != null ? r.get("lwmendtime") : "--" %></td>
                        <td>
                            <% if (status == 2) { %>
                                <span class="badge badge-reviewed">已批阅</span>
                            <% } else if (status == 1) { %>
                                <span class="badge badge-submitted">已提交</span>
                            <% } else { %>
                                <span class="badge badge-pending">未提交</span>
                            <% } %>
                        </td>
                        <td>
                            <% if (status == 1) { %>
                                <a href="lwmGradeExam?recordId=<%= r.get("lwmrecordid") %>" class="btn btn-primary">评分</a>
                            <% } else if (status == 2) { %>
                                <a href="lwmGradeExam?recordId=<%= r.get("lwmrecordid") %>" class="btn btn-primary" style="background:#f59e0b;">修改成绩</a>
                            <% } else { %>
                                <span class="btn btn-disabled">待提交</span>
                            <% } %>
                            <a href="lwmDeleteExamRecord?recordId=<%= r.get("lwmrecordid") %>" class="btn btn-disabled" style="color:#ef4444;" onclick="return confirm('确定删除该考试记录？删除后数据无法恢复。')">删除</a>
                        </td>
                    </tr>
                <% }
            } else { %>
                <tr><td colspan="9" class="empty">暂无考试记录</td></tr>
            <% } %>
        </tbody>
    </table>
</div>
</body>
</html>
