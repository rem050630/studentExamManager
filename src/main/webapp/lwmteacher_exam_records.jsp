<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    List<Map<String, Object>> records = (List<Map<String, Object>>) request.getAttribute("records");
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
                        <td><span class="badge <%= status == 1 ? "badge-submitted" : "badge-pending" %>"><%= status == 1 ? "已提交" : "未提交" %></span></td>
                        <td>
                            <% if (status == 1) { %>
                                <a href="lwmGradeExam?recordId=<%= r.get("lwmrecordid") %>" class="btn btn-primary">评分</a>
                            <% } else { %>
                                <span class="btn btn-disabled">待提交</span>
                            <% } %>
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
