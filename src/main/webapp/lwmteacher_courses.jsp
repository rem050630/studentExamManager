<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmstudentcourseteacher" %>
<%
    List<lwmstudentcourseteacher> courses = (List<lwmstudentcourseteacher>) request.getAttribute("courses");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>我的排课</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; padding:24px; }
        .container { max-width:1100px; margin:0 auto; }
        .header { display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; }
        .header h2 { color:#1e293b; font-size:1.5rem; }
        .search-box input { padding:8px 16px; border:1px solid #e2e8f0; border-radius:8px; width:260px; font-size:0.9rem; }
        .search-box button { padding:8px 20px; background:#059669; color:white; border:none; border-radius:8px; cursor:pointer; margin-left:8px; }
        table { width:100%; background:white; border-radius:12px; overflow:hidden; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        th { background:#f8fafc; padding:14px 18px; text-align:left; font-weight:600; color:#475569; font-size:0.85rem; border-bottom:1px solid #e2e8f0; }
        td { padding:14px 18px; border-bottom:1px solid #f1f5f9; color:#334155; font-size:0.9rem; }
        tr:hover { background:#f8fafc; }
        .empty { text-align:center; padding:40px; color:#94a3b8; }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <h2>我的排课</h2>
        <form class="search-box" method="get" action="lwmQueryTeacherCourses">
            <input type="text" name="keyword" placeholder="搜索班级或科目..." value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>">
            <button type="submit">搜索</button>
        </form>
    </div>
    <table>
        <thead>
            <tr><th>序号</th><th>班级</th><th>科目</th><th>学期</th><th>操作</th></tr>
        </thead>
        <tbody>
            <% if (courses != null && !courses.isEmpty()) {
                int i = 1;
                for (lwmstudentcourseteacher c : courses) { %>
                    <tr>
                        <td><%= i++ %></td>
                        <td><%= c.getLwmclassname() %></td>
                        <td><%= c.getLwmsubjectname() %></td>
                        <td><%= c.getLwmsemester() %></td>
                        <td><a href="lwmViewClassStudents?classname=<%= java.net.URLEncoder.encode(c.getLwmclassname(), "UTF-8") %>" style="color:#3b82f6; text-decoration:none;">查看详情</a></td>
                    </tr>
                <% }
            } else { %>
                <tr><td colspan="5" class="empty">暂无排课记录</td></tr>
            <% } %>
        </tbody>
    </table>
</div>
</body>
</html>
