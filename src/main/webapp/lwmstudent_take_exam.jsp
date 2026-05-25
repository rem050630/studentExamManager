<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmExamPaper" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmExamQuestion" %>
<%
    lwmExamPaper paper = (lwmExamPaper) request.getAttribute("paper");
    List<lwmExamQuestion> questions = (List<lwmExamQuestion>) request.getAttribute("questions");
    Map<Integer, String> draftAnswers = (Map<Integer, String>) request.getAttribute("draftAnswers");
    int draftRecordId = request.getAttribute("draftRecordId") != null ? (int) request.getAttribute("draftRecordId") : 0;

    // Helper: check if an option value is selected in draft answer
    boolean hasDraft = draftAnswers != null && !draftAnswers.isEmpty();

    // Calculate remaining time for countdown
    java.sql.Timestamp recordStartTime = (java.sql.Timestamp) request.getAttribute("recordStartTime");
    long remainingSeconds = 0;
    if (recordStartTime != null && paper.getLwmexamtime() > 0) {
        long deadline = recordStartTime.getTime() + paper.getLwmexamtime() * 60 * 1000L;
        remainingSeconds = (deadline - System.currentTimeMillis()) / 1000;
        if (remainingSeconds < 0) remainingSeconds = 0;
    }
%>
<%!
    private boolean isOptionSelected(Map<Integer, String> draft, int qid, String option) {
        if (draft == null) return false;
        String saved = draft.get(qid);
        if (saved == null || saved.isEmpty()) return false;
        for (String v : saved.split(",")) {
            if (v.trim().equalsIgnoreCase(option.trim())) return true;
        }
        return false;
    }
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
        .timer-warning { background:rgba(220,38,38,0.8) !important; animation: pulse 1s infinite; }
        @keyframes pulse { 0%,100% { opacity:1; } 50% { opacity:0.6; } }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <h2><%= paper.getLwmpapername() %>
            <span class="timer" id="countdown">--:--:--</span>
        </h2>
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
                        <label><input type="radio" name="q_<%= q.getLwmquestionid() %>" value="A" <%= isOptionSelected(draftAnswers, q.getLwmquestionid(), "A") ? "checked" : "" %>> A. <%= q.getLwmoptiona() %></label>
                        <label><input type="radio" name="q_<%= q.getLwmquestionid() %>" value="B" <%= isOptionSelected(draftAnswers, q.getLwmquestionid(), "B") ? "checked" : "" %>> B. <%= q.getLwmoptionb() %></label>
                        <% if (q.getLwmoptionc() != null && !q.getLwmoptionc().isEmpty()) { %><label><input type="radio" name="q_<%= q.getLwmquestionid() %>" value="C" <%= isOptionSelected(draftAnswers, q.getLwmquestionid(), "C") ? "checked" : "" %>> C. <%= q.getLwmoptionc() %></label><% } %>
                        <% if (q.getLwmoptiond() != null && !q.getLwmoptiond().isEmpty()) { %><label><input type="radio" name="q_<%= q.getLwmquestionid() %>" value="D" <%= isOptionSelected(draftAnswers, q.getLwmquestionid(), "D") ? "checked" : "" %>> D. <%= q.getLwmoptiond() %></label><% } %>
                    </div>
                <% } else if ("多选题".equals(type)) { %>
                    <div class="options">
                        <label><input type="checkbox" name="q_<%= q.getLwmquestionid() %>" value="A" <%= isOptionSelected(draftAnswers, q.getLwmquestionid(), "A") ? "checked" : "" %>> A. <%= q.getLwmoptiona() %></label>
                        <label><input type="checkbox" name="q_<%= q.getLwmquestionid() %>" value="B" <%= isOptionSelected(draftAnswers, q.getLwmquestionid(), "B") ? "checked" : "" %>> B. <%= q.getLwmoptionb() %></label>
                        <% if (q.getLwmoptionc() != null && !q.getLwmoptionc().isEmpty()) { %><label><input type="checkbox" name="q_<%= q.getLwmquestionid() %>" value="C" <%= isOptionSelected(draftAnswers, q.getLwmquestionid(), "C") ? "checked" : "" %>> C. <%= q.getLwmoptionc() %></label><% } %>
                        <% if (q.getLwmoptiond() != null && !q.getLwmoptiond().isEmpty()) { %><label><input type="checkbox" name="q_<%= q.getLwmquestionid() %>" value="D" <%= isOptionSelected(draftAnswers, q.getLwmquestionid(), "D") ? "checked" : "" %>> D. <%= q.getLwmoptiond() %></label><% } %>
                    </div>
                <% } else if ("判断题".equals(type)) { %>
                    <div class="options">
                        <label><input type="radio" name="q_<%= q.getLwmquestionid() %>" value="对" <%= isOptionSelected(draftAnswers, q.getLwmquestionid(), "对") ? "checked" : "" %>> 对</label>
                        <label><input type="radio" name="q_<%= q.getLwmquestionid() %>" value="错" <%= isOptionSelected(draftAnswers, q.getLwmquestionid(), "错") ? "checked" : "" %>> 错</label>
                    </div>
                <% } else if ("简答题".equals(type)) { %>
                    <textarea name="q_<%= q.getLwmquestionid() %>" placeholder="请输入你的答案..."><%= (draftAnswers != null && draftAnswers.get(q.getLwmquestionid()) != null) ? draftAnswers.get(q.getLwmquestionid()) : "" %></textarea>
                <% } %>
            </div>
        <% } } %>

        <div class="btn-row">
            <button type="button" class="btn" onclick="saveDraft()" style="background:#fff;border:1px solid #e2e8f0;color:#475569;">保存草稿</button>
            <button type="button" class="btn" onclick="history.back()" style="background:#fff;border:1px solid #e2e8f0;color:#475569;">返回</button>
            <button type="button" id="submitBtn" class="btn btn-submit" onclick="submitExam()">交卷</button>
        </div>
    </form>
</div>
<script>
var remainingSeconds = <%= remainingSeconds %>;
var autoSubmitted = false;

function pad(n) { return n < 10 ? '0' + n : '' + n; }

function updateTimer() {
    if (remainingSeconds <= 0) {
        document.getElementById('countdown').textContent = '00:00:00';
        document.getElementById('countdown').classList.add('timer-warning');
        if (!autoSubmitted) {
            autoSubmitted = true;
            var input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'autoSubmit';
            input.value = 'true';
            document.getElementById('examForm').appendChild(input);
            document.getElementById('examForm').submit();
        }
        return;
    }
    var h = Math.floor(remainingSeconds / 3600);
    var m = Math.floor((remainingSeconds % 3600) / 60);
    var s = remainingSeconds % 60;
    document.getElementById('countdown').textContent = pad(h) + ':' + pad(m) + ':' + pad(s);
    if (remainingSeconds <= 300) {
        document.getElementById('countdown').classList.add('timer-warning');
    }
    remainingSeconds--;
    setTimeout(updateTimer, 1000);
}

function countUnanswered() {
    var cards = document.querySelectorAll('.card');
    var unanswered = 0;
    for (var i = 0; i < cards.length; i++) {
        var card = cards[i];
        var radios = card.querySelectorAll('input[type="radio"]');
        var checkboxes = card.querySelectorAll('input[type="checkbox"]');
        var textarea = card.querySelector('textarea');
        var answered = false;
        if (radios.length > 0) {
            for (var j = 0; j < radios.length; j++) { if (radios[j].checked) { answered = true; break; } }
        } else if (checkboxes.length > 0) {
            for (var j = 0; j < checkboxes.length; j++) { if (checkboxes[j].checked) { answered = true; break; } }
        } else if (textarea) {
            if (textarea.value.trim() !== '') answered = true;
        }
        if (!answered) unanswered++;
    }
    return unanswered;
}

function submitExam() {
    var unanswered = countUnanswered();
    if (unanswered > 0) {
        if (!confirm('还有 ' + unanswered + ' 道题未作答，确定要提交吗？')) return;
    } else {
        if (!confirm('确定要提交试卷吗？提交后不可修改。')) return;
    }
    document.getElementById('examForm').submit();
}

function saveDraft() {
    var form = document.getElementById('examForm');
    form.action = 'lwmSaveExamDraft';
    form.submit();
}

updateTimer();
</script>
</body>
</html>
