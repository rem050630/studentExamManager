<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmExamPaper" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmExamQuestion" %>
<%@ page import="java.util.List" %>
<%
    lwmExamPaper paper = (lwmExamPaper) request.getAttribute("paper");
    List<lwmExamQuestion> questions = (List<lwmExamQuestion>) request.getAttribute("questions");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>浏览试卷 - <%= paper.getLwmpapername() %></title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; padding:24px; }
        .container { max-width:800px; margin:0 auto; background:white; padding:32px; border-radius:12px; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        h2 { color:#1e293b; margin-bottom:20px; }
        .info-bar { display:flex; gap:24px; flex-wrap:wrap; padding:16px; background:#f8fafc; border-radius:8px; margin-bottom:24px; font-size:0.9rem; color:#475569; }
        .info-bar span { font-weight:600; color:#1e293b; }
        .q-block { border:1px solid #e2e8f0; border-radius:8px; padding:16px; margin-bottom:12px; }
        .q-header { display:flex; align-items:center; gap:10px; margin-bottom:8px; }
        .q-num { font-weight:600; color:#1e293b; }
        .q-type { padding:2px 8px; border-radius:4px; font-size:0.75rem; background:#dbeafe; color:#2563eb; font-weight:500; }
        .q-content { font-size:0.95rem; color:#1e293b; margin-bottom:8px; line-height:1.6; }
        .q-options { margin-left:16px; font-size:0.85rem; color:#475569; }
        .q-options div { padding:2px 0; }
        .q-answer { margin-top:8px; padding:8px 12px; background:#ecfdf5; border-radius:6px; font-size:0.85rem; color:#059669; font-weight:500; }
        .section-title { font-size:1.1rem; font-weight:700; color:#1e293b; padding:12px 0 8px 0; margin-top:8px; border-bottom:2px solid #e2e8f0; margin-bottom:12px; }
        .btn-row { margin-top:24px; }
        .btn { padding:10px 24px; border-radius:8px; cursor:pointer; border:none; font-size:0.9rem; text-decoration:none; }
        .btn-secondary { background:#e2e8f0; color:#475569; }
    </style>
</head>
<body>
<div class="container">
    <h2><%= paper.getLwmpapername() %></h2>
    <div class="info-bar">
        <div>科目：<span><%= paper.getLwmsubjectname() != null ? paper.getLwmsubjectname() : "" %></span></div>
        <div>考试时长：<span><%= paper.getLwmexamtime() %> 分钟</span></div>
        <div>总分：<span><%= paper.getLwmexamsore() %> 分</span></div>
        <div>开始时间：<span><%= paper.getLwmstarttime() %></span></div>
        <div>结束时间：<span><%= paper.getLwmendtime() %></span></div>
    </div>
    <div style="display:flex;gap:12px;margin-bottom:16px;font-size:0.85rem;color:#64748b;">
        <span>单选题：<%= paper.getLwmdanxnum() %> 题 x <%= paper.getLwmdanxscore() %> 分</span>
        <span>多选题：<%= paper.getLwmduoxnum() %> 题 x <%= paper.getLwmduoxscore() %> 分</span>
        <span>判断题：<%= paper.getLwmpdnum() %> 题 x <%= paper.getLwmpdscore() %> 分</span>
        <span>简答题：<%= paper.getLwmjdnum() %> 题 x <%= paper.getLwmjdscore() %> 分</span>
    </div>
    <% if (questions != null && !questions.isEmpty()) {
        String currentType = "";
        int num = 0;
        java.util.Map<String, String> sectionTitles = new java.util.HashMap<>();
        sectionTitles.put("单选题", "一、单选题");
        sectionTitles.put("多选题", "二、多选题");
        sectionTitles.put("判断题", "三、判断题");
        sectionTitles.put("简答题", "四、简答题");
        for (lwmExamQuestion q : questions) {
            String type = q.getLwmquestiontype();
            if (!type.equals(currentType)) {
                currentType = type;
                num = 1;
                String title = sectionTitles.getOrDefault(type, type); %>
                <div class="section-title"><%= title %></div>
            <% } %>
            <div class="q-block">
                <div class="q-header">
                    <span class="q-num"><%= num++ %>.</span>
                    <span class="q-type"><%= type %></span>
                </div>
                <div class="q-content"><%= q.getLwmquestioncontent() %></div>
                <% if (q.getLwmoptiona() != null && !q.getLwmoptiona().isEmpty()) { %>
                    <div class="q-options">
                        <div>A. <%= q.getLwmoptiona() %></div>
                        <div>B. <%= q.getLwmoptionb() %></div>
                        <% if (q.getLwmoptionc() != null && !q.getLwmoptionc().isEmpty()) { %><div>C. <%= q.getLwmoptionc() %></div><% } %>
                        <% if (q.getLwmoptiond() != null && !q.getLwmoptiond().isEmpty()) { %><div>D. <%= q.getLwmoptiond() %></div><% } %>
                    </div>
                <% } %>
                <div class="q-answer">正确答案：<%= q.getLwmcorrectanswer() %></div>
            </div>
        <% }
    } %>
    <div class="btn-row">
        <a href="lwmQueryPaper" class="btn btn-secondary">返回列表</a>
    </div>
</div>
</body>
</html>
