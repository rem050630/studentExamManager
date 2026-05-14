<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmExamQuestion" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmstudentcourseteacher" %>
<%
    List<lwmExamQuestion> questions = (List<lwmExamQuestion>) request.getAttribute("questions");
    List<lwmstudentcourseteacher> courses = (List<lwmstudentcourseteacher>) request.getAttribute("courses");
    String questiontype = (String) request.getAttribute("questiontype");
    String keyword = (String) request.getAttribute("keyword");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>题库管理</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; padding:24px; }
        .container { max-width:1200px; margin:0 auto; }
        .header { display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; }
        .header h2 { color:#1e293b; font-size:1.5rem; }
        .btn { padding:8px 20px; border-radius:8px; cursor:pointer; text-decoration:none; font-size:0.9rem; border:none; display:inline-block; }
        .btn-primary { background:#059669; color:white; }
        .btn-edit { background:#3b82f6; color:white; padding:6px 14px; border-radius:6px; text-decoration:none; font-size:0.8rem; margin-right:6px; }
        .btn-delete { background:#ef4444; color:white; padding:6px 14px; border-radius:6px; text-decoration:none; font-size:0.8rem; }
        .filter-bar { display:flex; gap:12px; margin-bottom:20px; align-items:center; }
        .filter-bar select, .filter-bar input { padding:8px 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.9rem; }
        .filter-bar button { padding:8px 20px; background:#059669; color:white; border:none; border-radius:8px; cursor:pointer; }
        table { width:100%; background:white; border-radius:12px; overflow:hidden; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        th { background:#f8fafc; padding:12px 14px; text-align:left; font-weight:600; color:#475569; font-size:0.85rem; }
        td { padding:10px 14px; border-bottom:1px solid #f1f5f9; color:#334155; font-size:0.85rem; }
        tr:hover { background:#f8fafc; }
        .content { max-width:300px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
        .empty { text-align:center; padding:40px; color:#94a3b8; }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <h2>题库管理</h2>
        <a href="lwmteacher_question_add.jsp" class="btn btn-primary">+ 添加试题</a>
    </div>
    <form class="filter-bar" method="get" action="lwmQueryQuestion">
        <select name="questiontype">
            <option value="">全部题型</option>
            <option value="单选题" <%= "单选题".equals(questiontype) ? "selected" : "" %>>单选题</option>
            <option value="多选题" <%= "多选题".equals(questiontype) ? "selected" : "" %>>多选题</option>
            <option value="判断题" <%= "判断题".equals(questiontype) ? "selected" : "" %>>判断题</option>
            <option value="简答题" <%= "简答题".equals(questiontype) ? "selected" : "" %>>简答题</option>
        </select>
        <input type="text" name="keyword" placeholder="搜索题目内容..." value="<%= keyword != null ? keyword : "" %>">
        <button type="submit">筛选</button>
    </form>
    <table>
        <thead>
            <tr><th>序号</th><th>科目</th><th>题型</th><th>题目内容</th><th>正确答案</th><th>操作</th></tr>
        </thead>
        <tbody>
            <% if (questions != null && !questions.isEmpty()) {
                int i = 1;
                for (lwmExamQuestion q : questions) { %>
                    <tr>
                        <td><%= i++ %></td>
                        <td><%= q.getLwmsubjectname() != null ? q.getLwmsubjectname() : q.getLwmsubjectid() %></td>
                        <td><%= q.getLwmquestiontype() %></td>
                        <td class="content"><%= q.getLwmquestioncontent() %></td>
                        <td><%= q.getLwmcorrectanswer() %></td>
                        <td>
                            <a href="lwmUpdateQuestion?id=<%= q.getLwmquestionid() %>" class="btn-edit">编辑</a>
                            <a href="lwmDeleteQuestion?id=<%= q.getLwmquestionid() %>" class="btn-delete" onclick="return confirm('确定删除该试题？')">删除</a>
                        </td>
                    </tr>
                <% }
            } else { %>
                <tr><td colspan="6" class="empty">暂无试题</td></tr>
            <% } %>
        </tbody>
    </table>
</div>
</body>
</html>
