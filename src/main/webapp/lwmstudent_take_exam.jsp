<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmExamPaper" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmExamQuestion" %>
<%
    lwmExamPaper paper = (lwmExamPaper) request.getAttribute("paper");
    List<lwmExamQuestion> questions = (List<lwmExamQuestion>) request.getAttribute("questions");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title><%= paper.getLwmpapername() %></title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; padding:24px; }
        .container { max-width:900px; margin:0 auto; }
        .header { background:linear-gradient(135deg,#f59e0b,#d97706); color:white; padding:24px; border-radius:16px; margin-bottom:20px; }
        .header h2 { margin-bottom:8px; }
        .header p { opacity:0.8; font-size:0.9rem; }
        .card { background:white; border-radius:12px; padding:20px; margin-bottom:14px; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        .card h3 { color:#1e293b; font-size:1rem; margin-bottom:10px; }
        .card .options { margin:8px 0; padding-left:16px; color:#475569; font-size:0.9rem; }
        .card .options label { display:block; margin:4px 0; cursor:pointer; }
        .card textarea { width:100%; padding:10px; border:1px solid #e2e8f0; border-radius:8px; min-height:80px; font-family:inherit; font-size:0.9rem; }
        .card input[type="radio"], .card input[type="checkbox"] { margin-right:8px; }
        .btn-row { display:flex; gap:12px; justify-content:flex-end; margin-top:20px; }
        .btn { padding:12px 32px; border-radius:10px; cursor:pointer; border:none; font-size:1rem; font-weight:600; }
        .btn-submit { background:linear-gradient(135deg,#f59e0b,#d97706); color:white; }
        .timer { float:right; background:rgba(255,255,255,0.15); padding:6px 16px; border-radius:20px; font-size:0.9rem; }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <h2><%= paper.getLwmpapername() %></h2>
        <p>总分：<%= paper.getLwmexamsore() %> 分 | 时长：<%= paper.getLwmexamtime() %> 分钟</p>
    </div>

    <form method="post" action="lwmSubmitExam" id="examForm">
        <input type="hidden" name="paperId" value="<%= paper.getLwmpaperid() %>">

        <% if (questions != null) {
            for (int i = 0; i < questions.size(); i++) {
                lwmExamQuestion q = questions.get(i);
                String type = q.getLwmquestiontype();
                int maxScore = 0;
                if ("单选题".equals(type)) maxScore = paper.getLwmdanxscore();
                else if ("多选题".equals(type)) maxScore = paper.getLwmduoxscore();
                else if ("判断题".equals(type)) maxScore = paper.getLwmpdscore();
                else if ("简答题".equals(type)) maxScore = paper.getLwmjdscore();
        %>
            <div class="card">
                <h3>第 <%= i+1 %> 题 — <%= type %>（<%= maxScore %> 分）</h3>
                <p style="margin-bottom:10px;font-size:0.95rem;"><%= q.getLwmquestioncontent() %></p>

                <% if ("单选题".equals(type)) { %>
                    <div class="options">
                        <label><input type="radio" name="q_<%= q.getLwmquestionid() %>" value="A"> A. <%= q.getLwmoptiona() %></label>
                        <label><input type="radio" name="q_<%= q.getLwmquestionid() %>" value="B"> B. <%= q.getLwmoptionb() %></label>
                        <% if (q.getLwmoptionc() != null && !q.getLwmoptionc().isEmpty()) { %><label><input type="radio" name="q_<%= q.getLwmquestionid() %>" value="C"> C. <%= q.getLwmoptionc() %></label><% } %>
                        <% if (q.getLwmoptiond() != null && !q.getLwmoptiond().isEmpty()) { %><label><input type="radio" name="q_<%= q.getLwmquestionid() %>" value="D"> D. <%= q.getLwmoptiond() %></label><% } %>
                    </div>
                <% } else if ("多选题".equals(type)) { %>
                    <div class="options">
                        <label><input type="checkbox" name="q_<%= q.getLwmquestionid() %>" value="A"> A. <%= q.getLwmoptiona() %></label>
                        <label><input type="checkbox" name="q_<%= q.getLwmquestionid() %>" value="B"> B. <%= q.getLwmoptionb() %></label>
                        <% if (q.getLwmoptionc() != null && !q.getLwmoptionc().isEmpty()) { %><label><input type="checkbox" name="q_<%= q.getLwmquestionid() %>" value="C"> C. <%= q.getLwmoptionc() %></label><% } %>
                        <% if (q.getLwmoptiond() != null && !q.getLwmoptiond().isEmpty()) { %><label><input type="checkbox" name="q_<%= q.getLwmquestionid() %>" value="D"> D. <%= q.getLwmoptiond() %></label><% } %>
                    </div>
                <% } else if ("判断题".equals(type)) { %>
                    <div class="options">
                        <label><input type="radio" name="q_<%= q.getLwmquestionid() %>" value="对"> 对</label>
                        <label><input type="radio" name="q_<%= q.getLwmquestionid() %>" value="错"> 错</label>
                    </div>
                <% } else if ("简答题".equals(type)) { %>
                    <textarea name="q_<%= q.getLwmquestionid() %>" placeholder="请输入你的答案..."></textarea>
                <% } %>
            </div>
        <% } } %>

        <div class="btn-row">
            <button type="button" class="btn" onclick="if(confirm('确定要提交试卷吗？提交后不可修改。')){document.getElementById('examForm').submit();}" style="background:#e2e8f0;">交卷</button>
        </div>
    </form>
</div>
</body>
</html>
