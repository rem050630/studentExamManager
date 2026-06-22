# Restrict Paper Publishing by Teacher Course Arrangements — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Filter publishable classes by the paper's subject so a teacher can only publish a paper to classes where they actually teach that subject.

**Architecture:** Modify `lwmPublishPaper` — add `lwmsubjectid` to the GET class query and validate each POST-selected class against `lwmstudentcourseteacher`. Single servlet change, no JSP changes.

**Tech Stack:** Java Servlet, JDBC (raw `DriverManager.getConnection`), MySQL

## Global Constraints

- Follow existing code patterns in `lwmPublishPaper` (raw JDBC, not DAO; `PrintWriter` for script alerts)
- No JSP changes
- Filter only by subject (not semester)
- GET and POST both validate

---

### Task 1: Add subject filter to GET class query

**Files:**
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmPublishPaper.java:58-60`

**Interfaces:**
- Produces: `teacherClasses` list now only contains classes where `lwmteacherid = ? AND lwmsubjectid = ?`

- [ ] **Step 1: Update the SQL query and add lwmsubjectid parameter**

In `lwmPublishPaper.doGet()`, change the PreparedStatement setup (lines 58-60) from:

```java
PreparedStatement pstmt = conn.prepareStatement(
    "SELECT DISTINCT lwmclassname FROM lwmstudentcourseteacher WHERE lwmteacherid = ? ORDER BY lwmclassname");
pstmt.setInt(1, teacher.getLwmteacherid());
```

To:

```java
PreparedStatement pstmt = conn.prepareStatement(
    "SELECT DISTINCT lwmclassname FROM lwmstudentcourseteacher WHERE lwmteacherid = ? AND lwmsubjectid = ? ORDER BY lwmclassname");
pstmt.setInt(1, teacher.getLwmteacherid());
pstmt.setInt(2, paper.getLwmsubjectid());
```

- [ ] **Step 2: Verify compilation**

Run: `cd D:/Java/IdeaProjects/lwmexam && ./mvnw compile -q`

Expected: no output (success)

- [ ] **Step 3: Commit**

```bash
git add src/main/java/com/example/lwmexam/action/lwmexam/lwmPublishPaper.java
git commit -m "feat: filter publish classes by paper subject in GET"
```

---

### Task 2: Add backend validation for POST-selected classes

**Files:**
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmPublishPaper.java:108-191`

**Interfaces:**
- Consumes: `teacher.getLwmteacherid()` (from session), `paperId` (from form), `selectedClasses` (from form)
- Uses: paper's `lwmsubjectid` loaded from `lwmexampaper` table

- [ ] **Step 1: Add validation logic in doPost before the save**

In `lwmPublishPaper.doPost()`, after line 113 (`String classname = ...`), insert validation that loads the paper's subject, checks each selected class, and splits into valid/invalid sets. Replace the entire existing `classname` assignment and subsequent block with the new logic.

Replace lines 109-113:
```java
        String[] selectedClasses = request.getParameterValues("classes");
        String classname = "";
        if (selectedClasses != null && selectedClasses.length > 0) {
            classname = String.join(",", selectedClasses);
        }
```

With:
```java
        String[] selectedClasses = request.getParameterValues("classes");

        // Load paper's subject for validation
        int paperSubjectId = 0;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection connSubj = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8",
                "root", "123456");
            PreparedStatement pstmtSubj = connSubj.prepareStatement(
                "SELECT lwmsubjectid FROM lwmexampaper WHERE lwmpaperid = ?");
            pstmtSubj.setInt(1, paperId);
            ResultSet rsSubj = pstmtSubj.executeQuery();
            if (rsSubj.next()) paperSubjectId = rsSubj.getInt("lwmsubjectid");
            rsSubj.close(); pstmtSubj.close(); connSubj.close();
        } catch (Exception e) { e.printStackTrace(); }

        // Validate each selected class against teacher's course arrangements
        List<String> validClasses = new ArrayList<>();
        List<String> skippedClasses = new ArrayList<>();
        if (selectedClasses != null && selectedClasses.length > 0) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection connVal = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8",
                    "root", "123456");
                PreparedStatement pstmtVal = connVal.prepareStatement(
                    "SELECT COUNT(*) FROM lwmstudentcourseteacher WHERE lwmteacherid = ? AND lwmsubjectid = ? AND lwmclassname = ?");
                for (String cls : selectedClasses) {
                    pstmtVal.setInt(1, teacher.getLwmteacherid());
                    pstmtVal.setInt(2, paperSubjectId);
                    pstmtVal.setString(3, cls.trim());
                    ResultSet rsVal = pstmtVal.executeQuery();
                    if (rsVal.next() && rsVal.getInt(1) > 0) {
                        validClasses.add(cls.trim());
                    } else {
                        skippedClasses.add(cls.trim());
                    }
                    rsVal.close();
                }
                pstmtVal.close(); connVal.close();
            } catch (Exception e) { e.printStackTrace(); }
        }
        String classname = "";
        if (!validClasses.isEmpty()) {
            classname = String.join(",", validClasses);
        }
```

- [ ] **Step 2: Update the success response to mention skipped classes**

Replace the existing success alert (line 184):
```java
                out.println("<script>alert('发布成功');location.href='lwmQueryPaper';</script>");
```

With:
```java
                if (!skippedClasses.isEmpty()) {
                    out.println("<script>alert('发布成功。以下班级非本课程授课班级，已自动跳过：" + String.join("、", skippedClasses) + "');location.href='lwmQueryPaper';</script>");
                } else if (validClasses.isEmpty()) {
                    out.println("<script>alert('所选班级均非本课程授课班级，发布失败');history.go(-1);</script>");
                } else {
                    out.println("<script>alert('发布成功');location.href='lwmQueryPaper';</script>");
                }
```

- [ ] **Step 3: Verify compilation**

Run: `cd D:/Java/IdeaProjects/lwmexam && ./mvnw compile -q`

Expected: no output (success)

- [ ] **Step 4: Commit**

```bash
git add src/main/java/com/example/lwmexam/action/lwmexam/lwmPublishPaper.java
git commit -m "feat: validate publish classes against teacher course arrangements in POST"
```
