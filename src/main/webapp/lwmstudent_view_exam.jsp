<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmStudentAnswer" %>
<%@ page import="java.util.Arrays" %>
<%!
    private String[] splitAnswer(String ans) {
        if (ans == null) return new String[0];
        String trimmed = ans.trim();
        if (trimmed.contains(",") || trimmed.contains("，")) {
            return trimmed.replace("，", ",").split(",");
        }
        return trimmed.split("");
    }

    private boolean isMultiSelectCorrect(String studentAns, String correctAns) {
        if (studentAns == null || correctAns == null) return false;
        String[] stuArr = splitAnswer(studentAns);
        String[] corArr = splitAnswer(correctAns);
        Arrays.sort(stuArr);
        Arrays.sort(corArr);
        return Arrays.equals(stuArr, corArr);
    }
%>
<%
    List<lwmStudentAnswer> answers = (List<lwmStudentAnswer>) request.getAttribute("answers");
    Integer recordIdObj = (Integer) request.getAttribute("recordId");
    int recordId = recordIdObj != null ? recordIdObj : 0;
    String paperName = (String) request.getAttribute("paperName");
    int status = request.getAttribute("status") != null ? (int) request.getAttribute("status") : 0;
    Integer totalScore = (Integer) request.getAttribute("totalScore");
    boolean graded = (status == 2);
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>查看试卷</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; padding:24px; }
        .container { max-width:900px; margin:0 auto; }
        .header { display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; }
        .header h2 { color:#1e293b; font-size:1.5rem; }
        .summary { background:white; border-radius:12px; padding:20px 24px; margin-bottom:20px; box-shadow:0 1px 3px rgba(0,0,0,0.08); display:flex; gap:32px; align-items:center; }
        .summary .item { }
        .summary .label { color:#64748b; font-size:0.85rem; }
        .summary .value { color:#1e293b; font-size:1.1rem; font-weight:600; }
        .card { background:white; border-radius:12px; padding:24px; margin-bottom:16px; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        .card .q-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:12px; }
        .card .q-type { font-weight:600; color:#1e293b; font-size:1rem; }
        .card .q-score { color:#64748b; font-size:0.85rem; }
        .card .q-content { margin-bottom:12px; color:#334155; }
        .card .options { margin:8px 0; padding-left:16px; color:#475569; font-size:0.9rem; }
        .card .answer-row { margin:8px 0; font-size:0.9rem; }
        .card .answer-row strong { color:#475569; }
        .correct { color:#16a34a; }
        .wrong { color:#ef4444; }
        .correct-bg { border-left:4px solid #16a34a; }
        .wrong-bg { border-left:4px solid #ef4444; }
        .partial-bg { border-left:4px solid #f59e0b; }
        .result-badge { padding:2px 10px; border-radius:10px; font-size:0.8rem; font-weight:500; }
        .result-correct { background:#dcfce7; color:#16a34a; }
        .result-wrong { background:#fef2f2; color:#ef4444; }
        .result-partial { background:#fef3c7; color:#d97706; }
        .btn { padding:10px 24px; border-radius:8px; cursor:pointer; border:none; font-size:0.9rem; text-decoration:none; display:inline-block; }
        .btn-secondary { background:#e2e8f0; color:#475569; }
        .btn-primary { background:#059669; color:white; }
        .btn-row { display:flex; justify-content:center; margin-top:20px; }
        .answer-input { width:100%; padding:8px 12px; border:1px solid #e2e8f0; border-radius:6px; font-size:0.9rem; }
        .editable-hint { background:#eff6ff; color:#3b82f6; padding:10px 16px; border-radius:8px; margin-bottom:20px; font-size:0.85rem; }
        .section-title { font-size:1.1rem; font-weight:700; color:#1e293b; padding:16px 0 8px 0; margin-top:8px; border-bottom:2px solid #e2e8f0; margin-bottom:12px; }
        .empty { text-align:center; padding:40px; color:#94a3b8; }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <a href="lwmstudent_main.jsp" target="_parent" class="btn btn-secondary" style="padding:8px 18px;font-size:0.85rem;">返回</a>
        <h2>查看试卷</h2>
    </div>

    <div class="summary">
        <div class="item">
            <div class="label">试卷名称</div>
            <div class="value"><%= paperName != null ? paperName : "--" %></div>
        </div>
        <div class="item">
            <div class="label">题目数量</div>
            <div class="value"><%= answers != null ? answers.size() : 0 %> 道</div>
        </div>
        <% if (graded && totalScore != null) { %>
            <div class="item">
                <div class="label">总成绩</div>
                <div class="value" style="color:#16a34a;"><%= totalScore %> 分</div>
            </div>
        <% } else if (!graded) { %>
            <div class="item">
                <div class="label">状态</div>
                <div class="value" style="color:#3b82f6;">待批阅</div>
            </div>
        <% } %>
    </div>

    <% if (!graded) { %>
        <div class="editable-hint">试卷已提交，等待教师批阅。</div>
    <% } %>

    <% if (answers != null && !answers.isEmpty()) {
        String currentType = "";
        int num = 0;
        java.util.Map<String, String> sectionTitles = new java.util.HashMap<>();
        sectionTitles.put("单选题", "一、单选题");
        sectionTitles.put("多选题", "二、多选题");
        sectionTitles.put("判断题", "三、判断题");
        sectionTitles.put("简答题", "四、简答题");
        for (lwmStudentAnswer a : answers) {
            String type = a.getLwmquestiontype();
            String studentAns = a.getLwmstudentanswer();
            String correctAns = a.getLwmcorrectanswer();
            int qScore = a.getLwmquestionscore();
            int maxScore = a.getLwmpaperscore();

            String borderClass = "";
            boolean isCorrect = false;
            if (graded) {
                if ("多选题".equals(type)) {
                    isCorrect = isMultiSelectCorrect(studentAns, correctAns);
                } else {
                    isCorrect = studentAns != null && correctAns != null && studentAns.trim().equalsIgnoreCase(correctAns.trim());
                }
                boolean fullScore = qScore >= maxScore;
                boolean partialScore = qScore > 0 && qScore < maxScore;
                borderClass = fullScore ? "correct-bg" : (partialScore ? "partial-bg" : "wrong-bg");
            }
            if (!type.equals(currentType)) {
                currentType = type;
                num = 1;
                String title = sectionTitles.getOrDefault(type, type); %>
                <div class="section-title"><%= title %></div>
            <% } %>
        <div class="card <%= borderClass %>">
            <div class="q-header">
                <span class="q-type"><%= num++ %>. <%= type %></span>
                <span class="q-score">分值 <%= maxScore %> 分</span>
            </div>
            <div class="q-content"><strong>题目：</strong><%= a.getLwmquestioncontent() %></div>

            <% if ("单选题".equals(a.getLwmquestiontype()) || "多选题".equals(a.getLwmquestiontype())) { %>
                <div class="options">
                    <% if (a.getLwmoptiona() != null && !a.getLwmoptiona().isEmpty()) { %><div>A. <%= a.getLwmoptiona() %></div><% } %>
                    <% if (a.getLwmoptionb() != null && !a.getLwmoptionb().isEmpty()) { %><div>B. <%= a.getLwmoptionb() %></div><% } %>
                    <% if (a.getLwmoptionc() != null && !a.getLwmoptionc().isEmpty()) { %><div>C. <%= a.getLwmoptionc() %></div><% } %>
                    <% if (a.getLwmoptiond() != null && !a.getLwmoptiond().isEmpty()) { %><div>D. <%= a.getLwmoptiond() %></div><% } %>
                </div>
            <% } %>

            <div class="answer-row">
                <strong>你的答案：</strong>
                <% if (graded) {
                    boolean fullScore = qScore >= maxScore;
                    boolean partialScore = qScore > 0 && qScore < maxScore;
                    String badgeClass = fullScore ? "result-correct" : (partialScore ? "result-partial" : "result-wrong");
                    String badgeText = fullScore ? "正确" : (partialScore ? "部分正确" : "错误");
                %>
                    <span class="<%= isCorrect ? "correct" : "wrong" %>"><%= studentAns != null && !studentAns.isEmpty() ? studentAns : "(未作答)" %></span>
                    <span class="result-badge <%= badgeClass %>"><%= badgeText %></span>
                <% } else { %>
                    <span><%= studentAns != null && !studentAns.isEmpty() ? studentAns : "(未作答)" %></span>
                    <span class="result-badge" style="background:#eff6ff;color:#3b82f6;">待批阅</span>
                <% } %>
            </div>

            <% if (graded) { %>
                <div class="answer-row">
                    <strong>正确答案：</strong><span class="correct"><%= correctAns != null ? correctAns : "--" %></span>
                </div>
                <div class="answer-row">
                    <strong>得分：</strong><%= qScore %> / <%= maxScore %> 分
                </div>
            <% } %>
        </div>
    <% }
    } else { %>
        <div class="card"><p class="empty">暂无答题数据</p></div>
    <% } %>

</div>
</body>
</html>
