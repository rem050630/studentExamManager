# Question Answer UI + Teacher-side Pagination Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace manual answer text input with radio/checkbox selection on the question add/edit page, and add pagination to teacher-side question bank and exam paper lists.

**Architecture:** Frontend change for answer UI (JSP + JS toggle logic + minor backend adaptation for multi-select checkbox array). Pagination reuses existing `Fpage` service and `lwmfoot.jsp` component from admin side.

**Tech Stack:** Java Servlet, JSP with scriptlets, Fpage pagination utility, MySQL

---

### Task 1: Rework answer selection UI in question add/edit page

**Files:**
- Modify: `src/main/webapp/lwmteacher_question_add.jsp`

- [ ] **Step 1: Replace options area and correct answer section (lines 73-82) with new dynamic UI**

Find lines 73-82:
```jsp
        <div id="optionsArea" class="options-area ...">
            <div class="form-group"><label>选项A</label><input type="text" name="lwmoptiona" ...></div>
            ...
        </div>
        <div class="form-group">
            <label>正确答案...</label>
            <input type="text" name="lwmcorrectanswer" required ...>
        </div>
```

Replace with:
```jsp
        <%
            String editAnswer = isEdit ? question.getLwmcorrectanswer() : "";
            String qtype = isEdit ? question.getLwmquestiontype() : "";
            boolean isMulti = "多选题".equals(qtype);
            boolean isA = editAnswer.contains("A"), isB = editAnswer.contains("B");
            boolean isC = editAnswer.contains("C"), isD = editAnswer.contains("D");
        %>
        <div id="optionsArea" class="options-area <%= isEdit && ("单选题".equals(qtype) || isMulti) ? "show" : "" %>">
            <div class="form-group" style="display:flex;align-items:center;gap:10px;">
                <input type="<%= isMulti ? "checkbox" : "radio" %>" name="lwmcorrectanswer" value="A" <%= isA ? "checked" : "" %> class="answer-select" style="width:18px;height:18px;">
                <label style="flex:1;">选项A</label>
                <input type="text" name="lwmoptiona" style="flex:2;" value="<%= isEdit ? question.getLwmoptiona() : "" %>">
            </div>
            <div class="form-group" style="display:flex;align-items:center;gap:10px;">
                <input type="<%= isMulti ? "checkbox" : "radio" %>" name="lwmcorrectanswer" value="B" <%= isB ? "checked" : "" %> class="answer-select" style="width:18px;height:18px;">
                <label style="flex:1;">选项B</label>
                <input type="text" name="lwmoptionb" style="flex:2;" value="<%= isEdit ? question.getLwmoptionb() : "" %>">
            </div>
            <div class="form-group" style="display:flex;align-items:center;gap:10px;">
                <input type="<%= isMulti ? "checkbox" : "radio" %>" name="lwmcorrectanswer" value="C" <%= isC ? "checked" : "" %> class="answer-select" style="width:18px;height:18px;">
                <label style="flex:1;">选项C</label>
                <input type="text" name="lwmoptionc" style="flex:2;" value="<%= isEdit ? question.getLwmoptionc() : "" %>">
            </div>
            <div class="form-group" style="display:flex;align-items:center;gap:10px;">
                <input type="<%= isMulti ? "checkbox" : "radio" %>" name="lwmcorrectanswer" value="D" <%= isD ? "checked" : "" %> class="answer-select" style="width:18px;height:18px;">
                <label style="flex:1;">选项D</label>
                <input type="text" name="lwmoptiond" style="flex:2;" value="<%= isEdit ? question.getLwmoptiond() : "" %>">
            </div>
        </div>

        <div id="judgeAnswer" class="form-group" style="display:<%= "判断题".equals(qtype) ? "block" : "none" %>;">
            <label>正确答案</label>
            <div style="display:flex;gap:24px;padding-top:6px;">
                <label><input type="radio" name="lwmcorrectanswer" value="对" <%= "对".equals(editAnswer) ? "checked" : "" %>> 对</label>
                <label><input type="radio" name="lwmcorrectanswer" value="错" <%= "错".equals(editAnswer) ? "checked" : "" %>> 错</label>
            </div>
        </div>

        <div id="textAnswer" class="form-group" style="display:<%= "简答题".equals(qtype) ? "block" : "none" %>;">
            <label>正确答案</label>
            <input type="text" name="lwmcorrectanswer" value="<%= isEdit ? editAnswer : "" %>">
        </div>
```

- [ ] **Step 2: Replace toggleOptions() JavaScript function (lines 90-98)**

Replace:
```javascript
    function toggleOptions() {
        var type = document.getElementById('questiontype').value;
        var area = document.getElementById('optionsArea');
        if (type === '单选题' || type === '多选题') {
            area.classList.add('show');
        } else {
            area.classList.remove('show');
        }
    }
```

With:
```javascript
    function toggleOptions() {
        var type = document.getElementById('questiontype').value;
        var optArea = document.getElementById('optionsArea');
        var judgeAnswer = document.getElementById('judgeAnswer');
        var textAnswer = document.getElementById('textAnswer');
        var selects = document.querySelectorAll('.answer-select');

        optArea.classList.remove('show');
        judgeAnswer.style.display = 'none';
        textAnswer.style.display = 'none';

        if (type === '单选题') {
            optArea.classList.add('show');
            judgeAnswer.style.display = 'block';
            selects.forEach(function(el) { el.type = 'radio'; });
        } else if (type === '多选题') {
            optArea.classList.add('show');
            judgeAnswer.style.display = 'block';
            selects.forEach(function(el) { el.type = 'checkbox'; });
        } else if (type === '判断题') {
            judgeAnswer.style.display = 'block';
        } else if (type === '简答题') {
            textAnswer.style.display = 'block';
        }
    }
```

---

### Task 2: Adapt backend to handle multi-select checkbox array for answer

**Files:**
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmAddQuestion.java:44`
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmUpdateQuestion.java:42`

- [ ] **Step 1: Update lwmAddQuestion.doPost — replace getParameter with getParameterValues**

Find line 44:
```java
        q.setLwmcorrectanswer(request.getParameter("lwmcorrectanswer"));
```

Replace with:
```java
        String[] answers = request.getParameterValues("lwmcorrectanswer");
        String answer = "";
        if (answers != null && answers.length > 0) {
            answer = String.join(",", answers);
        }
        q.setLwmcorrectanswer(answer);
```

- [ ] **Step 2: Update lwmUpdateQuestion.doPost — same change on line 42**

Find line 42:
```java
        q.setLwmcorrectanswer(request.getParameter("lwmcorrectanswer"));
```

Replace with:
```java
        String[] answers = request.getParameterValues("lwmcorrectanswer");
        String answer = "";
        if (answers != null && answers.length > 0) {
            answer = String.join(",", answers);
        }
        q.setLwmcorrectanswer(answer);
```

---

### Task 3: Add pagination to question bank query (backend)

**Files:**
- Modify: `src/main/java/com/example/lwmexam/dao/lwmexam/lwmquestionDAO.java`
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmQueryQuestion.java`

- [ ] **Step 1: Add count and paged query methods to lwmquestionDAO**

Add these two public methods to `lwmquestionDAO.java` (before the closing `}`):

```java
    // Count questions matching filters (for pagination)
    public int lwmCountByFilters(String subjectIds, String questiontype, String keyword) {
        int count = 0;
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM lwmexamquestion q WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (subjectIds != null && !subjectIds.isEmpty()) {
            sql.append("AND q.lwmsubjectid IN (").append(subjectIds).append(") ");
        }
        if (questiontype != null && !questiontype.isEmpty()) {
            sql.append("AND q.lwmquestiontype = ? ");
            params.add(questiontype);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND q.lwmquestioncontent LIKE ? ");
            params.add("%" + keyword.trim() + "%");
        }
        try {
            rs = db.doQuery(sql.toString(), params.toArray());
            if (rs.next()) count = rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        db.close();
        return count;
    }

    // Paged query with filters
    public List<lwmExamQuestion> lwmQueryBySubjectTypePaged(
            String subjectIds, String questiontype, String keyword, int start, int pageSize) {
        StringBuilder sql = new StringBuilder(
            "SELECT q.*, s.lwmsubjectname FROM lwmexamquestion q " +
            "LEFT JOIN lwmexamsubject s ON q.lwmsubjectid = s.lwmsubjectid WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (subjectIds != null && !subjectIds.isEmpty()) {
            sql.append("AND q.lwmsubjectid IN (").append(subjectIds).append(") ");
        }
        if (questiontype != null && !questiontype.isEmpty()) {
            sql.append("AND q.lwmquestiontype = ? ");
            params.add(questiontype);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND q.lwmquestioncontent LIKE ? ");
            params.add("%" + keyword.trim() + "%");
        }
        sql.append("ORDER BY q.lwmquestionid DESC LIMIT ?,?");
        params.add(start);
        params.add(pageSize);
        return lwmQuerySomeQuestion(sql.toString(), params.toArray());
    }
```

Add the import at top if not present: `import java.util.List;` and `import java.util.ArrayList;` (they already exist).

- [ ] **Step 2: Add pagination to lwmQueryQuestion.doGet**

Add imports at top:
```java
import com.example.lwmexam.service.lwmexam.Fpage;
```

Replace the query and forward section (lines 61-71):
```java
        lwmquestionDAO dao = new lwmquestionDAO();
        List<lwmExamQuestion> questions = dao.lwmQueryBySubjectType(
            filterSubjectIds.isEmpty() ? null : filterSubjectIds, questiontype, keyword);

        request.setAttribute("questions", questions);
        request.setAttribute("courses", courses);
        request.setAttribute("subjectList", subjectList);
        request.setAttribute("questiontype", questiontype);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedSubjectId", selectedSubjectId != null ? selectedSubjectId : "");
        request.getRequestDispatcher("lwmteacher_question_list.jsp").forward(request, response);
```

Replace with:
```java
        lwmquestionDAO dao = new lwmquestionDAO();

        // Pagination
        Fpage fp = new Fpage();
        fp.setPageSize(6);
        if (request.getParameter("page") != null) {
            fp.setPageNow(Integer.parseInt(request.getParameter("page")));
        }
        String filterSubj = filterSubjectIds.isEmpty() ? null : filterSubjectIds;
        int total = dao.lwmCountByFilters(filterSubj, questiontype, keyword);
        fp.setRowCount(total);
        fp.setPageCount(total % fp.getPageSize() == 0 ? total / fp.getPageSize() : total / fp.getPageSize() + 1);

        List<lwmExamQuestion> questions = dao.lwmQueryBySubjectTypePaged(
            filterSubj, questiontype, keyword, fp.getStart(), fp.getPageSize());

        // Build tj string preserving current filter params for pagination links
        StringBuilder tj = new StringBuilder();
        if (selectedSubjectId != null && !selectedSubjectId.isEmpty()) tj.append("subjectid=").append(selectedSubjectId);
        if (questiontype != null && !questiontype.isEmpty()) {
            if (tj.length() > 0) tj.append("&");
            tj.append("questiontype=").append(questiontype);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            if (tj.length() > 0) tj.append("&");
            tj.append("keyword=").append(java.net.URLEncoder.encode(keyword, "UTF-8"));
        }

        request.setAttribute("questions", questions);
        request.setAttribute("courses", courses);
        request.setAttribute("subjectList", subjectList);
        request.setAttribute("questiontype", questiontype);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedSubjectId", selectedSubjectId != null ? selectedSubjectId : "");
        request.setAttribute("fp", fp);
        request.setAttribute("pageUrl", "lwmQueryQuestion");
        request.setAttribute("tj", tj.toString());
        request.getRequestDispatcher("lwmteacher_question_list.jsp").forward(request, response);
```

Also need to add Fpage to the class:
- The `setRowCount` and `setPageCount` methods need to be called because Fpage.setFpage does both COUNT query AND sets rowCount/pageCount. But since we already have `lwmCountByFilters`, we can set them manually. But Fpage doesn't have public setters for rowCount and pageCount... let me check.

Looking at Fpage:
```java
private int pageCount = 0;
private int rowCount = 0;
```

These are private! There are no setRowCount/setPageCount methods. The only way to set them is via `setFpage(String sql, Object[] param)`, which runs a COUNT query internally.

So I have two options:
1. Add setRowCount/setPageCount methods to Fpage
2. Use `setFpage` with a raw COUNT SQL instead of `lwmCountByFilters`

Option 2 is simpler and follows the admin pattern:
```java
fp.setFpage("SELECT COUNT(*) FROM lwmexamquestion q WHERE 1=1 " + filterClause, params);
```

But building the WHERE clause twice is ugly. Let me just add setter methods to Fpage.

Actually, the cleanest approach: add setRowCount to Fpage (public), then the pageCount auto-calculates. Or just call setFpage with the raw SQL. Looking at the admin pattern again:

```java
fp.setFpage("select count(*) from lwmexamsubject where lwmsubjectname like '%" + tj + "%' " +
    "or lwmterm like '%" + tj + "%'", new Object[]{});
```

It builds a separate COUNT SQL. Let me do the same for teacher side - just use setFpage with a built COUNT SQL. This avoids changing Fpage.

But I also need the count for the teacher side with complex filters (IN clause, etc.). I'll need to build a raw SQL string for the COUNT query.

Hmm, this is getting complex. Let me think about the simplest approach...

Simplest: add setRowCount to Fpage. It's a one-line change. Then I can use lwmCountByFilters and set the count.

Let me add to Fpage:
```java
public void setRowCount(int rowCount) {
    this.rowCount = rowCount;
    if (rowCount % pageSize == 0)
        pageCount = rowCount / pageSize;
    else
        pageCount = rowCount / pageSize + 1;
    start = pageNow * pageSize;
}
```

Then in the servlet:
```java
int total = dao.lwmCountByFilters(filterSubj, questiontype, keyword);
fp.setRowCount(total);
```

This is clean and minimal. Let me go with this approach.

OK let me finalize the plan in a much more concise way. I realize writing the full plan with all exact code is taking too long. Let me write the plan file now with all the details.<｜end▁of▁thinking｜>The plan is long — let me write it in full now.

<｜｜DSML｜｜tool_calls>
<｜｜DSML｜｜invoke name="Write">
<｜｜DSML｜｜parameter name="content" string="true"># Question Answer UI + Teacher-side Pagination Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace manual answer text input with radio/checkbox selection on the question add/edit page, and add Fpage-based pagination to teacher-side question bank and exam paper lists.

**Architecture:** Frontend change for answer UI (JSP + JS toggle + minor backend multi-select adaptation). Pagination reuses Fpage + lwmfoot.jsp from admin side. Fpage gets a new `setRowCount(int)` setter to support pre-counted totals.

**Tech Stack:** Java Servlet, JSP scriptlets, Fpage, MySQL

---

### Task 1: Add setRowCount(int) to Fpage

**Files:**
- Modify: `src/main/java/com/example/lwmexam/service/lwmexam/Fpage.java`

- [ ] Add the setter method before the closing `}`:

```java
    public void setRowCount(int rowCount) {
        this.rowCount = rowCount;
        if (rowCount % pageSize == 0)
            pageCount = rowCount / pageSize;
        else
            pageCount = rowCount / pageSize + 1;
        start = pageNow * pageSize;
    }
```

---

### Task 2: Rework answer selection UI in lwmteacher_question_add.jsp

**Files:**
- Modify: `src/main/webapp/lwmteacher_question_add.jsp:73-98`

- [ ] **Step 1: Replace options area and correct answer section (lines 73-82)**

Replace (old lines 73-82):
```jsp
        <div id="optionsArea" class="options-area <%= isEdit && ("单选题".equals(question.getLwmquestiontype()) || "多选题".equals(question.getLwmquestiontype())) ? "show" : "" %>">
            <div class="form-group"><label>选项A</label><input type="text" name="lwmoptiona" value="<%= isEdit ? question.getLwmoptiona() : "" %>"></div>
            <div class="form-group"><label>选项B</label><input type="text" name="lwmoptionb" value="<%= isEdit ? question.getLwmoptionb() : "" %>"></div>
            <div class="form-group"><label>选项C</label><input type="text" name="lwmoptionc" value="<%= isEdit ? question.getLwmoptionc() : "" %>"></div>
            <div class="form-group"><label>选项D</label><input type="text" name="lwmoptiond" value="<%= isEdit ? question.getLwmoptiond() : "" %>"></div>
        </div>
        <div class="form-group">
            <label>正确答案<%= isEdit && "多选题".equals(question.getLwmquestiontype()) ? "（多选用逗号分隔，如 A,B,C）" : "" %></label>
            <input type="text" name="lwmcorrectanswer" required value="<%= isEdit ? question.getLwmcorrectanswer() : "" %>">
        </div>
```

With:
```jsp
        <%
            String editAnswer = isEdit ? question.getLwmcorrectanswer() : "";
            String qtype = isEdit ? question.getLwmquestiontype() : "";
            boolean isMultiEdit = "多选题".equals(qtype);
            boolean isA = editAnswer.contains("A"), isB = editAnswer.contains("B");
            boolean isC = editAnswer.contains("C"), isD = editAnswer.contains("D");
        %>
        <div id="optionsArea" class="options-area <%= isEdit && ("单选题".equals(qtype) || isMultiEdit) ? "show" : "" %>">
            <div class="form-group" style="display:flex;align-items:center;gap:10px;">
                <input type="<%= isMultiEdit ? "checkbox" : "radio" %>" name="lwmcorrectanswer" value="A" <%= isA ? "checked" : "" %> class="answer-select" style="width:18px;height:18px;">
                <label style="flex:1;">选项A</label>
                <input type="text" name="lwmoptiona" style="flex:2;" value="<%= isEdit ? question.getLwmoptiona() : "" %>">
            </div>
            <div class="form-group" style="display:flex;align-items:center;gap:10px;">
                <input type="<%= isMultiEdit ? "checkbox" : "radio" %>" name="lwmcorrectanswer" value="B" <%= isB ? "checked" : "" %> class="answer-select" style="width:18px;height:18px;">
                <label style="flex:1;">选项B</label>
                <input type="text" name="lwmoptionb" style="flex:2;" value="<%= isEdit ? question.getLwmoptionb() : "" %>">
            </div>
            <div class="form-group" style="display:flex;align-items:center;gap:10px;">
                <input type="<%= isMultiEdit ? "checkbox" : "radio" %>" name="lwmcorrectanswer" value="C" <%= isC ? "checked" : "" %> class="answer-select" style="width:18px;height:18px;">
                <label style="flex:1;">选项C</label>
                <input type="text" name="lwmoptionc" style="flex:2;" value="<%= isEdit ? question.getLwmoptionc() : "" %>">
            </div>
            <div class="form-group" style="display:flex;align-items:center;gap:10px;">
                <input type="<%= isMultiEdit ? "checkbox" : "radio" %>" name="lwmcorrectanswer" value="D" <%= isD ? "checked" : "" %> class="answer-select" style="width:18px;height:18px;">
                <label style="flex:1;">选项D</label>
                <input type="text" name="lwmoptiond" style="flex:2;" value="<%= isEdit ? question.getLwmoptiond() : "" %>">
            </div>
        </div>

        <div id="judgeAnswer" class="form-group" style="display:<%= "判断题".equals(qtype) ? "block" : "none" %>;">
            <label>正确答案</label>
            <div style="display:flex;gap:24px;padding-top:6px;">
                <label><input type="radio" name="lwmcorrectanswer" value="对" <%= "对".equals(editAnswer) ? "checked" : "" %>> 对</label>
                <label><input type="radio" name="lwmcorrectanswer" value="错" <%= "错".equals(editAnswer) ? "checked" : "" %>> 错</label>
            </div>
        </div>

        <div id="textAnswer" class="form-group" style="display:<%= "简答题".equals(qtype) ? "block" : "none" %>;">
            <label>正确答案</label>
            <input type="text" name="lwmcorrectanswer" value="<%= isEdit ? editAnswer : "" %>">
        </div>
```

- [ ] **Step 2: Replace toggleOptions() JS (lines 90-98)**

Replace:
```javascript
    function toggleOptions() {
        var type = document.getElementById('questiontype').value;
        var area = document.getElementById('optionsArea');
        if (type === '单选题' || type === '多选题') {
            area.classList.add('show');
        } else {
            area.classList.remove('show');
        }
    }
```

With:
```javascript
    function toggleOptions() {
        var type = document.getElementById('questiontype').value;
        var optArea = document.getElementById('optionsArea');
        var judgeAnswer = document.getElementById('judgeAnswer');
        var textAnswer = document.getElementById('textAnswer');
        var selects = document.querySelectorAll('.answer-select');

        optArea.classList.remove('show');
        judgeAnswer.style.display = 'none';
        textAnswer.style.display = 'none';

        if (type === '单选题') {
            optArea.classList.add('show');
            judgeAnswer.style.display = 'block';
            selects.forEach(function(el) { el.type = 'radio'; });
        } else if (type === '多选题') {
            optArea.classList.add('show');
            judgeAnswer.style.display = 'block';
            selects.forEach(function(el) { el.type = 'checkbox'; });
        } else if (type === '判断题') {
            judgeAnswer.style.display = 'block';
        } else if (type === '简答题') {
            textAnswer.style.display = 'block';
        }
    }
```

---

### Task 3: Adapt backend for multi-select checkbox array

**Files:**
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmAddQuestion.java:44`
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmUpdateQuestion.java:42`

- [ ] **Step 1: In lwmAddQuestion.doPost, replace getParameter with getParameterValues**

Find:
```java
        q.setLwmcorrectanswer(request.getParameter("lwmcorrectanswer"));
```

Replace with:
```java
        String[] answers = request.getParameterValues("lwmcorrectanswer");
        String answer = "";
        if (answers != null && answers.length > 0) {
            answer = String.join(",", answers);
        }
        q.setLwmcorrectanswer(answer);
```

- [ ] **Step 2: In lwmUpdateQuestion.doPost, same change on line 42**

Find:
```java
        q.setLwmcorrectanswer(request.getParameter("lwmcorrectanswer"));
```

Replace with:
```java
        String[] answers = request.getParameterValues("lwmcorrectanswer");
        String answer = "";
        if (answers != null && answers.length > 0) {
            answer = String.join(",", answers);
        }
        q.setLwmcorrectanswer(answer);
```

---

### Task 4: Add count + paged query methods to lwmquestionDAO

**Files:**
- Modify: `src/main/java/com/example/lwmexam/dao/lwmexam/lwmquestionDAO.java`

- [ ] Add these two methods before the closing `}`. Import `java.util.ArrayList` and `java.util.List` if not already present (they already are).

```java
    public int lwmCountByFilters(String subjectIds, String questiontype, String keyword) {
        int count = 0;
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM lwmexamquestion q WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (subjectIds != null && !subjectIds.isEmpty()) {
            sql.append("AND q.lwmsubjectid IN (").append(subjectIds).append(") ");
        }
        if (questiontype != null && !questiontype.isEmpty()) {
            sql.append("AND q.lwmquestiontype = ? ");
            params.add(questiontype);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND q.lwmquestioncontent LIKE ? ");
            params.add("%" + keyword.trim() + "%");
        }
        try {
            rs = db.doQuery(sql.toString(), params.toArray());
            if (rs.next()) count = rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        db.close();
        return count;
    }

    public List<lwmExamQuestion> lwmQueryBySubjectTypePaged(
            String subjectIds, String questiontype, String keyword, int start, int pageSize) {
        StringBuilder sql = new StringBuilder(
            "SELECT q.*, s.lwmsubjectname FROM lwmexamquestion q " +
            "LEFT JOIN lwmexamsubject s ON q.lwmsubjectid = s.lwmsubjectid WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (subjectIds != null && !subjectIds.isEmpty()) {
            sql.append("AND q.lwmsubjectid IN (").append(subjectIds).append(") ");
        }
        if (questiontype != null && !questiontype.isEmpty()) {
            sql.append("AND q.lwmquestiontype = ? ");
            params.add(questiontype);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND q.lwmquestioncontent LIKE ? ");
            params.add("%" + keyword.trim() + "%");
        }
        sql.append("ORDER BY q.lwmquestionid DESC LIMIT ?,?");
        params.add(start);
        params.add(pageSize);
        return lwmQuerySomeQuestion(sql.toString(), params.toArray());
    }
```

---

### Task 5: Add pagination to lwmQueryQuestion servlet

**Files:**
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmQueryQuestion.java`

- [ ] Add import: `import com.example.lwmexam.service.lwmexam.Fpage;` and `import java.net.URLEncoder;`

- [ ] Replace the query+forward section (lines 61-72):

Replace:
```java
        lwmquestionDAO dao = new lwmquestionDAO();
        List<lwmExamQuestion> questions = dao.lwmQueryBySubjectType(
            filterSubjectIds.isEmpty() ? null : filterSubjectIds, questiontype, keyword);

        request.setAttribute("questions", questions);
        request.setAttribute("courses", courses);
        request.setAttribute("subjectList", subjectList);
        request.setAttribute("questiontype", questiontype);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedSubjectId", selectedSubjectId != null ? selectedSubjectId : "");
        request.getRequestDispatcher("lwmteacher_question_list.jsp").forward(request, response);
```

With:
```java
        lwmquestionDAO dao = new lwmquestionDAO();

        // Pagination
        Fpage fp = new Fpage();
        fp.setPageSize(6);
        if (request.getParameter("page") != null) {
            fp.setPageNow(Integer.parseInt(request.getParameter("page")));
        }
        String filterSubj = (filterSubjectIds != null && !filterSubjectIds.isEmpty()) ? filterSubjectIds : null;
        int total = dao.lwmCountByFilters(filterSubj, questiontype, keyword);
        fp.setRowCount(total);

        List<lwmExamQuestion> questions = dao.lwmQueryBySubjectTypePaged(
            filterSubj, questiontype, keyword, fp.getStart(), fp.getPageSize());

        // Build tj string for pagination links
        StringBuilder tj = new StringBuilder();
        if (selectedSubjectId != null && !selectedSubjectId.isEmpty())
            tj.append("subjectid=").append(selectedSubjectId);
        if (questiontype != null && !questiontype.isEmpty()) {
            if (tj.length() > 0) tj.append("&");
            tj.append("questiontype=").append(questiontype);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            if (tj.length() > 0) tj.append("&");
            tj.append("keyword=").append(URLEncoder.encode(keyword, "UTF-8"));
        }

        request.setAttribute("questions", questions);
        request.setAttribute("courses", courses);
        request.setAttribute("subjectList", subjectList);
        request.setAttribute("questiontype", questiontype);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedSubjectId", selectedSubjectId != null ? selectedSubjectId : "");
        request.setAttribute("fp", fp);
        request.setAttribute("pageUrl", "lwmQueryQuestion");
        request.setAttribute("tj", tj.toString());
        request.getRequestDispatcher("lwmteacher_question_list.jsp").forward(request, response);
```

---

### Task 6: Add pagination footer to question list JSP

**Files:**
- Modify: `src/main/webapp/lwmteacher_question_list.jsp`

- [ ] Add JSTL taglib at top (line 1, after page directive):

```jsp
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
```

- [ ] Add `<jsp:include page="lwmfoot.jsp"></jsp:include>` after the `</table>` closing tag (after line 87):

```jsp
    </table>
    <jsp:include page="lwmfoot.jsp"></jsp:include>
</div>
```

Also wrap the table and pagination in a card-style div to match lwmfoot styling (optional but recommended). At minimum, just include lwmfoot.jsp after the table.

---

### Task 7: Add count + paged query methods to lwmpaperDAO

**Files:**
- Modify: `src/main/java/com/example/lwmexam/dao/lwmexam/lwmpaperDAO.java`

- [ ] Add these two methods before the closing `}`:

```java
    public int lwmCountByTeacherFilters(int teacherId, String classname, String papername, Integer subjectId) {
        int count = 0;
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM lwmexampaper p WHERE p.lwmteacherid = ?");
        List<Object> params = new ArrayList<>();
        params.add(teacherId);
        if (classname != null && !classname.isEmpty()) {
            sql.append(" AND p.lwmclassname LIKE CONCAT('%', ?, '%')");
            params.add(classname);
        }
        if (papername != null && !papername.isEmpty()) {
            sql.append(" AND p.lwmpapername LIKE ?");
            params.add("%" + papername + "%");
        }
        if (subjectId != null) {
            sql.append(" AND p.lwmsubjectid = ?");
            params.add(subjectId);
        }
        try {
            rs = db.doQuery(sql.toString(), params.toArray());
            if (rs.next()) count = rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        db.close();
        return count;
    }

    public List<lwmExamPaper> lwmQueryByTeacherFiltersPaged(
            int teacherId, String classname, String papername, Integer subjectId, int start, int pageSize) {
        StringBuilder sql = new StringBuilder(
            "SELECT p.*, s.lwmsubjectname FROM lwmexampaper p " +
            "LEFT JOIN lwmexamsubject s ON p.lwmsubjectid = s.lwmsubjectid " +
            "WHERE p.lwmteacherid = ?");
        List<Object> params = new ArrayList<>();
        params.add(teacherId);
        if (classname != null && !classname.isEmpty()) {
            sql.append(" AND p.lwmclassname LIKE CONCAT('%', ?, '%')");
            params.add(classname);
        }
        if (papername != null && !papername.isEmpty()) {
            sql.append(" AND p.lwmpapername LIKE ?");
            params.add("%" + papername + "%");
        }
        if (subjectId != null) {
            sql.append(" AND p.lwmsubjectid = ?");
            params.add(subjectId);
        }
        sql.append(" ORDER BY p.lwmpaperid DESC LIMIT ?,?");
        params.add(start);
        params.add(pageSize);
        return lwmQuerySomePaper(sql.toString(), params.toArray());
    }
```

---

### Task 8: Add pagination to lwmQueryPaper servlet

**Files:**
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmQueryPaper.java`

- [ ] Add import: `import com.example.lwmexam.service.lwmexam.Fpage;` and `import java.net.URLEncoder;`

- [ ] Replace the query and forward section (lines 75-87):

Replace:
```java
        lwmpaperDAO dao = new lwmpaperDAO();
        List<lwmExamPaper> papers = dao.lwmQueryByTeacherWithFilters(
            teacher.getLwmteacherid(), selectedClass, selectedPaper, selectedSubjectId);

        request.setAttribute("papers", papers);
        request.setAttribute("classList", classList);
        request.setAttribute("paperList", paperList);
        request.setAttribute("subjectList", subjectList);
        request.setAttribute("selectedClass", selectedClass != null ? selectedClass : "");
        request.setAttribute("selectedPaper", selectedPaper != null ? selectedPaper : "");
        request.setAttribute("selectedSubjectId", selectedSubjectId != null ? String.valueOf(selectedSubjectId) : "");
        request.getRequestDispatcher("lwmteacher_paper_list.jsp").forward(request, response);
```

With:
```java
        lwmpaperDAO dao = new lwmpaperDAO();

        // Pagination
        Fpage fp = new Fpage();
        fp.setPageSize(6);
        if (request.getParameter("page") != null) {
            fp.setPageNow(Integer.parseInt(request.getParameter("page")));
        }
        String sc = (selectedClass != null && !selectedClass.isEmpty()) ? selectedClass : null;
        String sp = (selectedPaper != null && !selectedPaper.isEmpty()) ? selectedPaper : null;
        int total = dao.lwmCountByTeacherFilters(teacher.getLwmteacherid(), sc, sp, selectedSubjectId);
        fp.setRowCount(total);

        List<lwmExamPaper> papers = dao.lwmQueryByTeacherFiltersPaged(
            teacher.getLwmteacherid(), sc, sp, selectedSubjectId, fp.getStart(), fp.getPageSize());

        // Build tj string for pagination links
        StringBuilder tj = new StringBuilder();
        if (sc != null) tj.append("classname=").append(URLEncoder.encode(sc, "UTF-8"));
        if (sp != null) {
            if (tj.length() > 0) tj.append("&");
            tj.append("papername=").append(URLEncoder.encode(sp, "UTF-8"));
        }
        if (selectedSubjectId != null) {
            if (tj.length() > 0) tj.append("&");
            tj.append("subjectid=").append(selectedSubjectId);
        }

        request.setAttribute("papers", papers);
        request.setAttribute("classList", classList);
        request.setAttribute("paperList", paperList);
        request.setAttribute("subjectList", subjectList);
        request.setAttribute("selectedClass", selectedClass != null ? selectedClass : "");
        request.setAttribute("selectedPaper", selectedPaper != null ? selectedPaper : "");
        request.setAttribute("selectedSubjectId", selectedSubjectId != null ? String.valueOf(selectedSubjectId) : "");
        request.setAttribute("fp", fp);
        request.setAttribute("pageUrl", "lwmQueryPaper");
        request.setAttribute("tj", tj.toString());
        request.getRequestDispatcher("lwmteacher_paper_list.jsp").forward(request, response);
```

---

### Task 9: Add pagination footer to paper list JSP

**Files:**
- Modify: `src/main/webapp/lwmteacher_paper_list.jsp`

- [ ] Add JSTL taglib at top (line 1):

```jsp
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
```

- [ ] Add `<jsp:include page="lwmfoot.jsp"></jsp:include>` after `</table>` (before `</div>` on line 96):

```jsp
    </table>
    <jsp:include page="lwmfoot.jsp"></jsp:include>
</div>
```

---

### Task 10: Build and verify

- [ ] **Step 1: Compile**
Run: `cd D:/Java/IdeaProjects/lwmexam && mvn compile -q`
Expected: BUILD SUCCESS

- [ ] **Step 2: Start server and smoke test**
- Open question add page, verify radio for single choice, checkbox for multi choice, 对/错 for judgment, text for short answer
- Verify question list and paper list show pagination footer with correct page count
