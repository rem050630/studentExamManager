# Input Validation: Score Range, Exam Time, and Question Score — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add frontend and backend validation to reject negative grading scores, zero/negative exam time, and negative per-question scores in paper creation/editing.

**Architecture:** Three independent task groups — grading, paper creation, paper editing — each adding JS/HTML validation on the JSP and server-side rejection in the corresponding servlet.

**Tech Stack:** Java Servlet, JSP, JavaScript, JDBC

## Global Constraints

- Follow existing code patterns: servlets use `PrintWriter` with `<script>alert()</script>` for responses; JSPs use inline `<script>` blocks
- All server-side rejections use `out.println("<script>alert('...');history.go(-1);</script>"); return;`
- JSP input changes: add `min` attribute to number inputs only

---

### Task 1: Grading score validation — reject negative and over-max scores

**Files:**
- Modify: `src/main/webapp/lwmteacher_grading.jsp` (`validateScores()` function)
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmSubmitScore.java` (score parsing loop)

**Interfaces:**
- Produces: `validateScores()` now also rejects negatives; `lwmSubmitScore.doPost()` rejects score < 0 or > max instead of silently clamping

- [ ] **Step 1: Add negative check to JS `validateScores()`**

In `lwmteacher_grading.jsp`, inside `validateScores()` (line 95-106), add the negative check before the existing max check:

Change:
```javascript
	    function validateScores() {
	        for (var i = 0; i < inputs.length; i++) {
	            var v = parseInt(inputs[i].value) || 0;
	            var max = parseInt(inputs[i].max) || 0;
	            if (v > max) {
	                alert('第' + (i + 1) + '题得分（' + v + '）超过了分值上限（' + max + '），请修改后再提交。');
	                inputs[i].focus();
	                return false;
	            }
	        }
	        return true;
	    }
```

To:
```javascript
	    function validateScores() {
	        for (var i = 0; i < inputs.length; i++) {
	            var v = parseInt(inputs[i].value) || 0;
	            var max = parseInt(inputs[i].max) || 0;
	            if (v < 0) {
	                alert('第' + (i + 1) + '题得分不能为负数');
	                inputs[i].focus();
	                return false;
	            }
	            if (v > max) {
	                alert('第' + (i + 1) + '题得分（' + v + '）超过了分值上限（' + max + '），请修改后再提交。');
	                inputs[i].focus();
	                return false;
	            }
	        }
	        return true;
	    }
```

- [ ] **Step 2: Replace silent clamping with rejection in `lwmSubmitScore.java`**

In `lwmSubmitScore.java`, lines 73-80, change the clamping logic to rejection:

From:
```java
                if (maxScore > 0 && score > maxScore) score = maxScore;
```

To:
```java
                if (score < 0 || (maxScore > 0 && score > maxScore)) {
                    out.println("<script>alert('分数无效，应在0到" + maxScore + "分之间');history.go(-1);</script>");
                    return;
                }
```

- [ ] **Step 3: Verify compilation**

Run: `cd D:/Java/IdeaProjects/lwmexam && ./mvnw compile -q`

Expected: no output (success)

- [ ] **Step 4: Commit**

```bash
git add src/main/webapp/lwmteacher_grading.jsp src/main/java/com/example/lwmexam/action/lwmexam/lwmSubmitScore.java
git commit -m "feat: reject negative and over-max scores in grading"
```

---

### Task 2: Paper creation — exam time and question score validation

**Files:**
- Modify: `src/main/webapp/lwmteacher_paper_create.jsp` (exam time input)
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmCreatePaper.java` (add validation blocks)

**Interfaces:**
- Produces: exam time input has `min="1"`; `lwmCreatePaper.doPost()` rejects `examTime <= 0` and negative per-type scores

- [ ] **Step 1: Add `min="1"` to exam time input in create JSP**

In `lwmteacher_paper_create.jsp`, line 77, change:
```html
            <input type="number" name="lwmexamtime" value="120" required>
```
To:
```html
            <input type="number" name="lwmexamtime" value="120" min="1" required>
```

- [ ] **Step 2: Add server-side validation in `lwmCreatePaper.java`**

In `lwmCreatePaper.java`, after the start/end time validation (after line 49), insert exam time validation:
```java
        if (examTime <= 0) {
            out.println("<script>alert('考试时间必须大于0分钟');history.go(-1);</script>");
            return;
        }
```

And after the score parsing block (after line 67 for manual mode, after line 76 for auto mode), insert score validation. Since both modes set the same score variables, add after the mode `if/else` block (after line 99, before the question categorization):

```java
        if (danxScore < 0 || duoxScore < 0 || pdScore < 0 || jdScore < 0) {
            out.println("<script>alert('试题分值不能为负数');history.go(-1);</script>");
            return;
        }
```

- [ ] **Step 3: Verify compilation**

Run: `cd D:/Java/IdeaProjects/lwmexam && ./mvnw compile -q`

Expected: no output (success)

- [ ] **Step 4: Commit**

```bash
git add src/main/webapp/lwmteacher_paper_create.jsp src/main/java/com/example/lwmexam/action/lwmexam/lwmCreatePaper.java
git commit -m "feat: validate exam time and question scores in paper creation"
```

---

### Task 3: Paper editing — exam time and question score validation

**Files:**
- Modify: `src/main/webapp/lwmteacher_paper_edit.jsp` (exam time input)
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmUpdatePaper.java` (add validation blocks)

**Interfaces:**
- Consumes: same validation pattern as Task 2
- Produces: exam time input has `min="1"`; `lwmUpdatePaper.doPost()` rejects `examTime <= 0` and negative per-type scores

- [ ] **Step 1: Add `min="1"` to exam time input in edit JSP**

In `lwmteacher_paper_edit.jsp`, line 100, change:
```html
                <input type="number" name="lwmexamtime" required value="<%= paper.getLwmexamtime() %>">
```
To:
```html
                <input type="number" name="lwmexamtime" required min="1" value="<%= paper.getLwmexamtime() %>">
```

- [ ] **Step 2: Add server-side validation in `lwmUpdatePaper.java`**

In `lwmUpdatePaper.doPost()`, after the start/end time validation (after line 75), insert exam time validation. Parse `examTime` early:

After line 65 (`boolean hasSubmit = ...`), add:
```java
        int examTime = 0;
        try {
            examTime = Integer.parseInt(request.getParameter("lwmexamtime"));
        } catch (NumberFormatException ignored) {}
        if (examTime <= 0) {
            out.println("<script>alert('考试时间必须大于0分钟');history.go(-1);</script>");
            return;
        }
```

And for score validation: in the `!hasSubmit` block, after the score parsing (lines 114-117), add:
```java
                if (danxScore < 0 || duoxScore < 0 || pdScore < 0 || jdScore < 0) {
                    out.println("<script>alert('试题分值不能为负数');history.go(-1);</script>");
                    return;
                }
```

- [ ] **Step 3: Verify compilation**

Run: `cd D:/Java/IdeaProjects/lwmexam && ./mvnw compile -q`

Expected: no output (success)

- [ ] **Step 4: Commit**

```bash
git add src/main/webapp/lwmteacher_paper_edit.jsp src/main/java/com/example/lwmexam/action/lwmexam/lwmUpdatePaper.java
git commit -m "feat: validate exam time and question scores in paper editing"
```
