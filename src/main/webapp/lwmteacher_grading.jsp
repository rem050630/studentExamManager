<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmStudentAnswer" %>
<%
    List<lwmStudentAnswer> answers = (List<lwmStudentAnswer>) request.getAttribute("answers");
    Integer recordIdObj = (Integer) request.getAttribute("recordId");
    int recordId = recordIdObj != null ? recordIdObj : 0;
    int studentId = answers != null && !answers.isEmpty() ? answers.get(0).getLwmstudentid() : 0;
    int paperId = answers != null && !answers.isEmpty() ? answers.get(0).getLwmpaperid() : 0;
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>评分</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; padding:24px; }
        .container { max-width:900px; margin:0 auto; }
        .header { display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; }
        .header h2 { color:#1e293b; font-size:1.5rem; }
        .card { background:white; border-radius:12px; padding:24px; margin-bottom:16px; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        .card h3 { color:#1e293b; margin-bottom:12px; font-size:1rem; }
        .card .meta { color:#64748b; font-size:0.85rem; margin-bottom:8px; }
        .card .options { margin:8px 0; padding-left:16px; color:#475569; font-size:0.9rem; }
        .card .answer { margin:8px 0; }
        .score-input { width:80px; padding:6px 10px; border:1px solid #e2e8f0; border-radius:6px; text-align:center; }
        .correct { color:#16a34a; }
        .wrong { color:#ef4444; }
        .btn { padding:10px 24px; border-radius:8px; cursor:pointer; border:none; font-size:0.9rem; }
        .btn-primary { background:#059669; color:white; }
        .btn-row { display:flex; justify-content:flex-end; margin-top:20px; }
    </style>
</head>
<body>
<div class="container">
    <div class="header"><h2>试卷评分</h2></div>
    <form method="post" action="lwmSubmitScore">
        <input type="hidden" name="recordId" value="<%= recordId %>">
        <input type="hidden" name="studentId" value="<%= studentId %>">
        <input type="hidden" name="paperId" value="<%= paperId %>">
        <% if (answers != null && !answers.isEmpty()) {
            for (lwmStudentAnswer a : answers) { %>
                <div class="card">
                    <h3><%= a.getLwmquestiontype() %> — 分值 <%= a.getLwmpaperscore() %> 分</h3>
                    <p style="margin-bottom:8px;"><strong>题目：</strong><%= a.getLwmquestioncontent() %></p>
                    <% if ("单选题".equals(a.getLwmquestiontype()) || "多选题".equals(a.getLwmquestiontype())) { %>
                        <div class="options">
                            <% if (a.getLwmoptiona() != null && !a.getLwmoptiona().isEmpty()) { %><div>A. <%= a.getLwmoptiona() %></div><% } %>
                            <% if (a.getLwmoptionb() != null && !a.getLwmoptionb().isEmpty()) { %><div>B. <%= a.getLwmoptionb() %></div><% } %>
                            <% if (a.getLwmoptionc() != null && !a.getLwmoptionc().isEmpty()) { %><div>C. <%= a.getLwmoptionc() %></div><% } %>
                            <% if (a.getLwmoptiond() != null && !a.getLwmoptiond().isEmpty()) { %><div>D. <%= a.getLwmoptiond() %></div><% } %>
                        </div>
                    <% } %>
                    <div class="answer"><strong>学生答案：</strong><%= a.getLwmstudentanswer() != null ? a.getLwmstudentanswer() : "(未作答)" %></div>
                    <div class="answer"><strong>正确答案：</strong><span class="correct"><%= a.getLwmcorrectanswer() %></span></div>
                    <div class="answer">
                        <strong>得分：</strong>
                        <input type="number" class="score-input" name="score_<%= a.getLwmanswerid() %>" value="<%= a.getLwmquestionscore() %>" min="0" max="<%= a.getLwmpaperscore() %>">
                        / <%= a.getLwmpaperscore() %>
                    </div>
                </div>
            <% }
        } else { %>
            <div class="card"><p style="color:#94a3b8;">暂无答题数据</p></div>
        <% } %>
        <div class="btn-row" style="align-items:center;gap:16px;">
            <span style="font-size:1rem;font-weight:600;color:#1e293b;">总分：<span id="totalScore" style="color:#059669;font-size:1.2rem;">0</span> 分</span>
            <button type="submit" class="btn btn-primary">提交评分</button>
        </div>
    </form>
</div>
<script>
(function() {
    var inputs = document.querySelectorAll('.score-input');
    var totalEl = document.getElementById('totalScore');
    function updateTotal() {
        var sum = 0;
        for (var i = 0; i < inputs.length; i++) {
            var v = parseInt(inputs[i].value) || 0;
            sum += v;
        }
        totalEl.textContent = sum;
    }
    for (var i = 0; i < inputs.length; i++) {
        inputs[i].addEventListener('input', updateTotal);
    }
    updateTotal();
})();
</script>
</body>
</html>
