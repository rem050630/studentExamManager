# Prevent Unpublishing Classes With Submitted Exams — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Block teachers from unchecking a class on the paper publish page if any student in that class has already submitted the exam, and show a warning.

**Architecture:** Backend `doGet` queries submitted classes and passes them to JSP for UI disabling. Backend `doPost` validates removed classes against `lwmexamrecord` before updating — rejects with alert if any submitted records exist.

**Tech Stack:** Java Servlet + JSP + MySQL

---

### Task 1: Backend — add submission check to lwmPublishPaper.java

**Files:**
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmPublishPaper.java`

- [ ] **Step 1: Add submitted classes query in doGet**

After loading `teacherClasses` (after the while loop that reads classes from lwmstudentcourseteacher), add a query to find which published classes already have submitted records:

```java
        // Check which published classes have submitted exams (cannot be unpublished)
        Set<String> submittedClasses = new HashSet<>();
        if (!publishedClasses.isEmpty()) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn2 = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8",
                    "root", "123456");
                for (String cls : publishedClasses) {
                    PreparedStatement pstmt2 = conn2.prepareStatement(
                        "SELECT COUNT(*) FROM lwmexamrecord r " +
                        "JOIN lwmstudent s ON r.lwmstudentid = s.lwmstudentid " +
                        "WHERE r.lwmpaperid = ? AND s.lwmclassname = ? AND r.lwmsubmitstatus IN (1, 2)");
                    pstmt2.setInt(1, paperId);
                    pstmt2.setString(2, cls.trim());
                    ResultSet rs2 = pstmt2.executeQuery();
                    if (rs2.next() && rs2.getInt(1) > 0) {
                        submittedClasses.add(cls);
                    }
                    rs2.close(); pstmt2.close();
                }
                conn2.close();
            } catch (Exception e) { e.printStackTrace(); }
        }
```

Then add the new attribute alongside the existing ones:

```java
        request.setAttribute("submittedClasses", submittedClasses);
```

Insert this line after `request.setAttribute("publishedClasses", publishedClasses);` on line 68.

- [ ] **Step 2: Add removed-class validation in doPost**

In `doPost()`, after parsing `selectedClasses` and computing the new `classname` string (after line 87 `classname = String.join(",", selectedClasses);`), add validation before the UPDATE:

```java
        // Check if any class being removed has submitted exam records
        String currentClassname = "";
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection connCheck = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8",
                "root", "123456");
            PreparedStatement pstmtCheck = connCheck.prepareStatement(
                "SELECT lwmclassname FROM lwmexampaper WHERE lwmpaperid = ?");
            pstmtCheck.setInt(1, paperId);
            ResultSet rsCheck = pstmtCheck.executeQuery();
            if (rsCheck.next()) {
                String cn = rsCheck.getString("lwmclassname");
                if (cn != null) currentClassname = cn;
            }
            rsCheck.close(); pstmtCheck.close(); connCheck.close();
        } catch (Exception e) { e.printStackTrace(); }

        // Compute removed classes (were published before, not in new selection)
        Set<String> oldSet = new HashSet<>();
        if (currentClassname != null && !currentClassname.isEmpty()) {
            oldSet.addAll(Arrays.asList(currentClassname.split(",")));
        }
        Set<String> newSet = new HashSet<>();
        if (selectedClasses != null) {
            newSet.addAll(Arrays.asList(selectedClasses));
        }
        Set<String> removedSet = new HashSet<>(oldSet);
        removedSet.removeAll(newSet);

        // Check each removed class for submitted records
        if (!removedSet.isEmpty()) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection connSub = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8",
                    "root", "123456");
                for (String cls : removedSet) {
                    PreparedStatement pstmtSub = connSub.prepareStatement(
                        "SELECT COUNT(*) FROM lwmexamrecord r " +
                        "JOIN lwmstudent s ON r.lwmstudentid = s.lwmstudentid " +
                        "WHERE r.lwmpaperid = ? AND s.lwmclassname = ? AND r.lwmsubmitstatus IN (1, 2)");
                    pstmtSub.setInt(1, paperId);
                    pstmtSub.setString(2, cls.trim());
                    ResultSet rsSub = pstmtSub.executeQuery();
                    if (rsSub.next() && rsSub.getInt(1) > 0) {
                        rsSub.close(); pstmtSub.close(); connSub.close();
                        out.println("<script>alert('班级 " + cls.trim() + " 已有学生完成考试，无法取消发布');history.go(-1);</script>");
                        return;
                    }
                    rsSub.close(); pstmtSub.close();
                }
                connSub.close();
            } catch (Exception e) { e.printStackTrace(); }
        }
```

This block goes BETWEEN the `classname = String.join(...)` line and the `try { Class.forName...` block that does the UPDATE. The existing UPDATE code remains unchanged.

- [ ] **Step 3: Commit**

```bash
git add src/main/java/com/example/lwmexam/action/lwmexam/lwmPublishPaper.java
git commit -m "feat: prevent unpublishing classes with submitted exam records"
```

---

### Task 2: Frontend — disable submitted class checkboxes in JSP

**Files:**
- Modify: `src/main/webapp/lwmteacher_paper_publish.jsp`

- [ ] **Step 1: Read submittedClasses attribute in scriptlet**

Add after line 8 (`Set<String> publishedClasses = ...`):

```jsp
    Set<String> submittedClasses = (Set<String>) request.getAttribute("submittedClasses");
    if (submittedClasses == null) submittedClasses = new java.util.HashSet<String>();
```

- [ ] **Step 2: Add warning message before the class list**

Add after `<p style="color:#475569;font-weight:500;margin-bottom:12px;">选择要发布到的班级（可多选）：</p>` on line 36:

```jsp
        <% if (!submittedClasses.isEmpty()) { %>
            <div style="background:#fef3c7;color:#d97706;padding:10px 16px;border-radius:8px;margin-bottom:12px;font-size:0.85rem;">
                <i class="fas fa-exclamation-triangle"></i> 以下班级已有学生完成考试，<strong>无法取消发布</strong>
            </div>
        <% } %>
```

- [ ] **Step 3: Disable checkboxes for submitted classes and add indicator**

Change the checkbox rendering block (lines 42-48) from:

```jsp
                for (String cls : teacherClasses) {
                    boolean checked = publishedClasses != null && publishedClasses.contains(cls); %>
                    <label class="class-item <%= checked ? "selected" : "" %>">
                        <input type="checkbox" name="classes" value="<%= cls %>" <%= checked ? "checked" : "" %> onchange="this.parentElement.classList.toggle('selected', this.checked)">
                        <%= cls %>
                    </label>
```

To:

```jsp
                for (String cls : teacherClasses) {
                    boolean checked = publishedClasses != null && publishedClasses.contains(cls);
                    boolean submitted = submittedClasses.contains(cls); %>
                    <label class="class-item <%= checked ? "selected" : "" %>" style="<%= submitted ? "opacity:0.7;" : "" %>">
                        <input type="checkbox" name="classes" value="<%= cls %>" <%= checked ? "checked" : "" %> <%= submitted ? "disabled" : "" %> onchange="this.parentElement.classList.toggle('selected', this.checked)">
                        <%= cls %> <%= submitted ? "<span style='color:#d97706;font-size:0.75rem;'>(已有提交)</span>" : "" %>
                    </label>
```

- [ ] **Step 4: Update CSS to show disabled state**

Add this CSS rule inside the `<style>` block (after the existing `.class-item.selected` rule):

```css
        .class-item:has(input:disabled) { border-color:#f59e0b; background:#fffbeb; cursor:not-allowed; }
```

- [ ] **Step 5: Commit**

```bash
git add src/main/webapp/lwmteacher_paper_publish.jsp
git commit -m "feat: disable submitted class checkboxes with warning in paper publish page"
```
