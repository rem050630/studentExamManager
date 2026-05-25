# Exam Duration Timer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enforce exam duration — countdown timer on student exam page, auto-submit on expiry, server-side timeout validation, and unanswered question warnings.

**Architecture:** Three files changed. `lwmTakeExam` creates exam record on first access and passes start time to JSP. JSP renders countdown using start time + paper duration, with JS handling auto-submit and unanswered-question check. `lwmSubmitExam` validates deadline on server side as defense-in-depth.

**Tech Stack:** Java 8 Servlet, JSP, vanilla JavaScript, MySQL via JDBC (MysqlConn)

---

### Task 1: Create exam record on first access and pass start time to JSP

**Files:**
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmTakeExam.java`

- [ ] **Step 1: Add record start time query and creation logic**

Replace the draft-loading block (lines 77-103 in lwmTakeExam.java). The new logic:
- Query includes `lwmstarttime` column
- If no draft record exists, INSERT a new one with `lwmstarttime=now`
- Pass `recordStartTime` to request as a `java.sql.Timestamp` attribute

```java
// Load existing draft record (status=0) for this student+paper, or create one
java.util.Map<Integer, String> draftAnswers = new java.util.HashMap<>();
int draftRecordId = 0;
java.sql.Timestamp recordStartTime = null;
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    java.sql.Connection conn = java.sql.DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8",
        "root", "123456");
    
    // Query existing draft record with start time
    java.sql.PreparedStatement ps = conn.prepareStatement(
        "SELECT lwmrecordid, lwmstarttime FROM lwmexamrecord WHERE lwmpaperid=? AND lwmstudentid=? AND lwmsubmitstatus=0");
    ps.setInt(1, paperId);
    ps.setInt(2, student.getLwmstudentid());
    java.sql.ResultSet rs = ps.executeQuery();
    if (rs.next()) {
        draftRecordId = rs.getInt("lwmrecordid");
        recordStartTime = rs.getTimestamp("lwmstarttime");
        rs.close(); ps.close();
        // Load existing answers
        java.sql.PreparedStatement aps = conn.prepareStatement(
            "SELECT lwmquestionid, lwmstudentanswer FROM lwmstudentanswer WHERE lwmrecordid=?");
        aps.setInt(1, draftRecordId);
        java.sql.ResultSet ars = aps.executeQuery();
        while (ars.next()) {
            draftAnswers.put(ars.getInt("lwmquestionid"), ars.getString("lwmstudentanswer"));
        }
        ars.close(); aps.close();
    } else {
        rs.close(); ps.close();
        // No draft — create exam record with current time as start time
        recordStartTime = new java.sql.Timestamp(System.currentTimeMillis());
        java.sql.PreparedStatement ips = conn.prepareStatement(
            "INSERT INTO lwmexamrecord(lwmpaperid,lwmstudentid,lwmstarttime,lwmendtime,lwmsubmitstatus) VALUES(?,?,?,?,0)",
            java.sql.Statement.RETURN_GENERATED_KEYS);
        ips.setInt(1, paperId);
        ips.setInt(2, student.getLwmstudentid());
        ips.setTimestamp(3, recordStartTime);
        ips.setTimestamp(4, recordStartTime);
        ips.executeUpdate();
        java.sql.ResultSet keys = ips.getGeneratedKeys();
        if (keys.next()) {
            draftRecordId = keys.getInt(1);
        }
        keys.close(); ips.close();
    }
    conn.close();
} catch (Exception e) { e.printStackTrace(); }
```

- [ ] **Step 2: Set recordStartTime as request attribute**

Add after the existing `request.setAttribute("draftRecordId", draftRecordId);` line:

```java
request.setAttribute("recordStartTime", recordStartTime);
```

- [ ] **Step 3: Add import**

Add import at top of file:
```java
import java.sql.Statement;
```

- [ ] **Step 4: Commit**

```bash
git add src/main/java/com/example/lwmexam/action/lwmexam/lwmTakeExam.java
git commit -m "feat: create exam record on first access, pass start time to JSP"
```

---

### Task 2: Add countdown timer and unanswered question check to JSP

**Files:**
- Modify: `src/main/webapp/lwmstudent_take_exam.jsp`

- [ ] **Step 1: Add timer CSS styles**

Replace the existing `.timer` style rule (line 47) with expanded timer styles:

```css
.timer { float:right; background:rgba(255,255,255,0.15); padding:6px 16px; border-radius:20px; font-size:0.9rem; }
.timer-warning { background:rgba(220,38,38,0.8) !important; animation: pulse 1s infinite; }
@keyframes pulse { 0%,100% { opacity:1; } 50% { opacity:0.6; } }
```

- [ ] **Step 2: Calculate remaining seconds in JSP**

Add after line 13 (`boolean hasDraft = ...;`):

```java
// Calculate remaining time for countdown
java.sql.Timestamp recordStartTime = (java.sql.Timestamp) request.getAttribute("recordStartTime");
long remainingSeconds = 0;
if (recordStartTime != null && paper.getLwmexamtime() > 0) {
    long deadline = recordStartTime.getTime() + paper.getLwmexamtime() * 60 * 1000L;
    remainingSeconds = (deadline - System.currentTimeMillis()) / 1000;
    if (remainingSeconds < 0) remainingSeconds = 0;
}
```

- [ ] **Step 3: Add countdown display in header**

Replace the header content (lines 52-55) to include the timer:

```html
<div class="header">
    <h2><%= paper.getLwmpapername() %>
        <span class="timer" id="countdown">--:--:--</span>
    </h2>
    <p>总分：<%= paper.getLwmexamsore() %> 分 | 时长：<%= paper.getLwmexamtime() %> 分钟</p>
</div>
```

- [ ] **Step 4: Replace submit button and add save draft button**

Replace the button row (lines 99-102):

```html
<div class="btn-row">
    <button type="button" class="btn" onclick="saveDraft()" style="background:#fff;border:1px solid #e2e8f0;color:#475569;">保存草稿</button>
    <button type="button" class="btn" onclick="saveDraft()" style="background:#fff;border:1px solid #e2e8f0;color:#475569;">返回</button>
    <button type="button" id="submitBtn" class="btn btn-submit" onclick="submitExam()">交卷</button>
</div>
```

- [ ] **Step 5: Replace JavaScript section**

Replace the existing `<script>` block (lines 105-111) with full timer + submit logic:

```javascript
var remainingSeconds = <%= remainingSeconds %>;
var autoSubmitted = false;

function pad(n) { return n < 10 ? '0' + n : '' + n; }

function updateTimer() {
    if (remainingSeconds <= 0) {
        document.getElementById('countdown').textContent = '00:00:00';
        document.getElementById('countdown').classList.add('timer-warning');
        if (!autoSubmitted) {
            autoSubmitted = true;
            // Add hidden field to signal auto-submit to server
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

// Start timer on page load
updateTimer();
```

- [ ] **Step 6: Commit**

```bash
git add src/main/webapp/lwmstudent_take_exam.jsp
git commit -m "feat: add exam countdown timer and unanswered question warning"
```

---

### Task 3: Add server-side timeout validation to submit

**Files:**
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmSubmitExam.java`

- [ ] **Step 1: Add paper query and timeout check**

After the existing `paperId` parsing (line 28) and before the draft record query, add paper loading and timeout validation:

```java
// Load paper to get exam duration for timeout check
com.example.lwmexam.dao.lwmexam.lwmpaperDAO pDao = new com.example.lwmexam.dao.lwmexam.lwmpaperDAO();
com.example.lwmexam.entity.lwmexam.lwmExamPaper paper = pDao.lwmQueryPaperById(paperId);
boolean isAutoSubmit = "true".equals(request.getParameter("autoSubmit"));

// Load existing draft record to get start time
int recordId = 0;
java.sql.Timestamp recordStartTime = null;
try {
    ResultSet rs = db.doQuery(
        "SELECT lwmrecordid, lwmstarttime FROM lwmexamrecord WHERE lwmpaperid=? AND lwmstudentid=? AND lwmsubmitstatus=0",
        new Object[]{paperId, student.getLwmstudentid()});
    if (rs.next()) {
        recordId = rs.getInt("lwmrecordid");
        recordStartTime = rs.getTimestamp("lwmstarttime");
    }
} catch (Exception e) { e.printStackTrace(); }
db.close();

// Timeout check: reject manual submission if student's time has expired
// Allow 3-second grace period for auto-submit (network latency after JS timer hits 0)
if (recordStartTime != null && paper != null && paper.getLwmexamtime() > 0) {
    long deadline = recordStartTime.getTime() + paper.getLwmexamtime() * 60 * 1000L;
    long tolerance = isAutoSubmit ? 5000 : 0; // 5s grace for auto-submit
    if (System.currentTimeMillis() > deadline + tolerance) {
        out.println("<script>alert('考试时间已到，无法提交');history.back();</script>");
        return;
    }
}
```

- [ ] **Step 2: Update draft record handling to reuse already-fetched data**

Delete the existing draft record query block (original lines 31-39) since `recordId` and `recordStartTime` are already fetched above.

The block starting at original line 41 (`if (recordId > 0) {`) needs `db = new MysqlConn();` added before it since `db.close()` was called after the timeout check. Replace original lines 41-51:

```java
if (recordId > 0) {
    // Reuse draft: update status to 1, delete old answers
    db = new MysqlConn();
    String now = new Timestamp(System.currentTimeMillis()).toString();
    db.doUpdate(
        "UPDATE lwmexamrecord SET lwmsubmitstatus=1, lwmendtime=? WHERE lwmrecordid=?",
        new Object[]{now, recordId});
    db.close();
    db = new MysqlConn();
    db.doUpdate("DELETE FROM lwmstudentanswer WHERE lwmrecordid=?", new Object[]{recordId});
    db.close();
```

- [ ] **Step 3: Different success message for auto-submit**

Replace the final success alert (original line 95) to distinguish auto vs manual submit:

```java
if (isAutoSubmit) {
    out.println("<script>alert('考试时间到，系统已自动交卷');location.href='lwmstudent_main.jsp';</script>");
} else {
    out.println("<script>alert('交卷成功！等待教师批阅。');location.href='lwmstudent_main.jsp';</script>");
}
```

- [ ] **Step 4: Add saveAnswers helper method**

Add a private method at the end of the class (before the closing `}`):

```java
private void saveAnswers(HttpServletRequest request, int recordId, int studentId, int paperId) {
    MysqlConn db2 = new MysqlConn();
    try {
        java.util.Enumeration<String> names = request.getParameterNames();
        while (names.hasMoreElements()) {
            String name = names.nextElement();
            if (name.startsWith("q_")) {
                int questionId = Integer.parseInt(name.substring(2));
                String[] values = request.getParameterValues(name);
                String answer = values != null ? String.join(",", values) : "";
                db2.doUpdate(
                    "INSERT INTO lwmstudentanswer(lwmrecordid,lwmquestionid,lwmstudentanswer,lwmquestionscore,lwmstudentid,lwmpaperid) VALUES(?,?,?,0,?,?)",
                    new Object[]{recordId, questionId, answer, studentId, paperId});
            }
        }
    } catch (Exception e) { e.printStackTrace(); }
    db2.close();
}
```

- [ ] **Step 5: Refactor answer saving loop to use helper**

Replace the answer-saving loop (original lines 78-93) with:

```java
saveAnswers(request, recordId, student.getLwmstudentid(), paperId);
```

- [ ] **Step 6: Commit**

```bash
git add src/main/java/com/example/lwmexam/action/lwmexam/lwmSubmitExam.java
git commit -m "feat: add server-side exam timeout validation on submit"
```
