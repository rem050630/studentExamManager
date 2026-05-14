<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmExamPaper" %>
<%
    List<lwmExamPaper> papers = (List<lwmExamPaper>) request.getAttribute("papers");
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
                        <td><%= p.getLwmclassname() %></td>
                        <td><%= p.getLwmexamtime() %>分钟</td>
                        <td><%= p.getLwmexamsore() %></td>
                        <td>
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
