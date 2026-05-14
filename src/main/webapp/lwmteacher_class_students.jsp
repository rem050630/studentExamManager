<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmStudent" %>
<%
    List<lwmStudent> students = (List<lwmStudent>) request.getAttribute("students");
    String classname = (String) request.getAttribute("classname");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title><%= classname %> - 学生详情</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; padding:24px; }
        .container { max-width:1100px; margin:0 auto; }
        .header { display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; }
        .header h2 { color:#1e293b; font-size:1.5rem; }
        .search-box input { padding:8px 16px; border:1px solid #e2e8f0; border-radius:8px; width:260px; font-size:0.9rem; }
        .search-box button { padding:8px 20px; background:#059669; color:white; border:none; border-radius:8px; cursor:pointer; margin-left:8px; }
        table { width:100%; background:white; border-radius:12px; overflow:hidden; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        th { background:#f8fafc; padding:12px 14px; text-align:left; font-weight:600; color:#475569; font-size:0.85rem; }
        td { padding:10px 14px; border-bottom:1px solid #f1f5f9; color:#334155; font-size:0.85rem; }
        tr:hover { background:#f8fafc; }
        .empty { text-align:center; padding:40px; color:#94a3b8; }
        .badge { padding:4px 10px; border-radius:12px; font-size:0.8rem; background:#e2e8f0; color:#475569; }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <h2><%= classname %> — 学生详情</h2>
        <form class="search-box" method="get" action="lwmViewClassStudents">
            <input type="hidden" name="classname" value="<%= classname %>">
            <input type="text" name="keyword" placeholder="搜索学号或姓名..." value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>">
            <button type="submit">搜索</button>
        </form>
    </div>
    <table>
        <thead>
            <tr><th>序号</th><th>学号</th><th>姓名</th><th>性别</th><th>年级</th><th>专业</th><th>班级</th></tr>
        </thead>
        <tbody>
            <% if (students != null && !students.isEmpty()) {
                int i = 1;
                for (lwmStudent s : students) { %>
                    <tr>
                        <td><%= i++ %></td>
                        <td><%= s.getLwmstudentno() %></td>
                        <td><%= s.getLwmstudentname() %></td>
                        <td><span class="badge"><%= s.getLwmgender() %></span></td>
                        <td><%= s.getLwmgrade() %></td>
                        <td><%= s.getLwmmajor() %></td>
                        <td><%= s.getLwmclassname() %></td>
                    </tr>
                <% }
            } else { %>
                <tr><td colspan="7" class="empty">该班级暂无学生</td></tr>
            <% } %>
        </tbody>
    </table>
</div>
</body>
</html>
