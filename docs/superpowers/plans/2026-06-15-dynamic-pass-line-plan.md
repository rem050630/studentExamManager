# Dynamic Pass Line for Score Analysis — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace hardcoded 60-point pass threshold with 60% of each exam paper's total score, and update distribution brackets and grade labels to dynamic percentage-based thresholds.

**Architecture:** Backend loads paper total score, computes 5 thresholds (passLine, b2End, b3End, excelLine), builds bracketLabels array, concatenates values into SQL CASE expressions (safe: values are int arithmetic, not user input), and passes everything as request attributes. JSP reads attributes and uses them for grade labels and chart labels.

**Tech Stack:** Java Servlet + JSP + MySQL

---

### Task 1: Backend — compute dynamic thresholds and update SQL

**Files:**
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmScoreAnalysisAction.java`

- [ ] **Step 1: Load paper total score and compute thresholds**

Insert after `if (paperId != null) {` on line 225, before `db = new MysqlConn();`:

```java
        // Load paper total score for dynamic pass/excel thresholds
        int totalScore = 100;
        if (paperId != null) {
            MysqlConn pdb = new MysqlConn();
            try {
                ResultSet prs = pdb.doQuery(
                    "SELECT lwmexamsore FROM lwmexampaper WHERE lwmpaperid = ?",
                    new Object[]{paperId});
                if (prs.next()) totalScore = prs.getInt("lwmexamsore");
                prs.close();
            } catch (Exception e) { e.printStackTrace(); }
            pdb.close();
        }
        int passLine  = (int)(totalScore * 0.6);
        int b2End     = (int)(totalScore * 0.7);
        int b3End     = (int)(totalScore * 0.8);
        int excelLine = (int)(totalScore * 0.9);
        String[] bracketLabels = new String[]{
            "0-" + (passLine - 1),
            passLine + "-" + (b2End - 1),
            b2End + "-" + (b3End - 1),
            b3End + "-" + (excelLine - 1),
            excelLine + "-" + totalScore
        };
```

- [ ] **Step 2: Update compare-mode pass/excel rate SQL (currently lines 141-148)**

Replace the whole `rs = db.doQuery(...)` block with:

```java
                    rs = db.doQuery(
                        "SELECT " +
                        "SUM(CASE WHEN sc.lwmtotalscore >= " + passLine + " THEN 1 ELSE 0 END) AS pass_count, " +
                        "SUM(CASE WHEN sc.lwmtotalscore >= " + excelLine + " THEN 1 ELSE 0 END) AS excel_count " +
                        "FROM lwmexamscore sc " +
                        "JOIN lwmexamrecord r ON sc.lwmrecordid = r.lwmrecordid " +
                        "JOIN lwmstudent s ON sc.lwmstudentid = s.lwmstudentid " +
                        "WHERE sc.lwmpaperid = ? AND s.lwmclassname = ?",
                        new Object[]{paperId, cls});
```

- [ ] **Step 3: Update compare-mode distribution SQL (currently lines 163-174)**

Replace the `rs = db.doQuery(...)` and `dist[]` reading block with:

```java
                    rs = db.doQuery(
                        "SELECT " +
                        "SUM(CASE WHEN sc.lwmtotalscore < " + passLine + " THEN 1 ELSE 0 END) AS b0, " +
                        "SUM(CASE WHEN sc.lwmtotalscore >= " + passLine + " AND sc.lwmtotalscore < " + b2End + " THEN 1 ELSE 0 END) AS b1, " +
                        "SUM(CASE WHEN sc.lwmtotalscore >= " + b2End + " AND sc.lwmtotalscore < " + b3End + " THEN 1 ELSE 0 END) AS b2, " +
                        "SUM(CASE WHEN sc.lwmtotalscore >= " + b3End + " AND sc.lwmtotalscore < " + excelLine + " THEN 1 ELSE 0 END) AS b3, " +
                        "SUM(CASE WHEN sc.lwmtotalscore >= " + excelLine + " THEN 1 ELSE 0 END) AS b4 " +
                        "FROM lwmexamscore sc " +
                        "JOIN lwmexamrecord r ON sc.lwmrecordid = r.lwmrecordid " +
                        "JOIN lwmstudent s ON sc.lwmstudentid = s.lwmstudentid " +
                        "WHERE sc.lwmpaperid = ? AND s.lwmclassname = ?",
                        new Object[]{paperId, cls});
                    int[] dist = new int[5];
                    if (rs.next()) {
                        dist[0] = rs.getInt("b0");
                        dist[1] = rs.getInt("b1");
                        dist[2] = rs.getInt("b2");
                        dist[3] = rs.getInt("b3");
                        dist[4] = rs.getInt("b4");
                    }
```

- [ ] **Step 4: Update single-paper distribution SQL (currently lines 255-281)**

Replace the `StringBuilder distSql` and its result-reading block:

```java
                StringBuilder distSql = new StringBuilder(
                    "SELECT " +
                    "SUM(CASE WHEN sc.lwmtotalscore < " + passLine + " THEN 1 ELSE 0 END) AS b0, " +
                    "SUM(CASE WHEN sc.lwmtotalscore >= " + passLine + " AND sc.lwmtotalscore < " + b2End + " THEN 1 ELSE 0 END) AS b1, " +
                    "SUM(CASE WHEN sc.lwmtotalscore >= " + b2End + " AND sc.lwmtotalscore < " + b3End + " THEN 1 ELSE 0 END) AS b2, " +
                    "SUM(CASE WHEN sc.lwmtotalscore >= " + b3End + " AND sc.lwmtotalscore < " + excelLine + " THEN 1 ELSE 0 END) AS b3, " +
                    "SUM(CASE WHEN sc.lwmtotalscore >= " + excelLine + " THEN 1 ELSE 0 END) AS b4 " +
                    "FROM lwmexamscore sc " +
                    "JOIN lwmexamrecord r ON sc.lwmrecordid = r.lwmrecordid " +
                    "JOIN lwmstudent s ON sc.lwmstudentid = s.lwmstudentid " +
                    "WHERE sc.lwmpaperid = ?");
```

And the result reading:

```java
                if (rs.next()) {
                    distribution = new int[5];
                    distribution[0] = rs.getInt("b0");
                    distribution[1] = rs.getInt("b1");
                    distribution[2] = rs.getInt("b2");
                    distribution[3] = rs.getInt("b3");
                    distribution[4] = rs.getInt("b4");
                }
```

- [ ] **Step 5: Update single-paper pass rate SQL (currently lines 285-287)**

```java
                StringBuilder passSql = new StringBuilder(
                    "SELECT COUNT(*) AS total, SUM(CASE WHEN sc.lwmtotalscore >= " + passLine + " THEN 1 ELSE 0 END) AS pass_count " +
                    "FROM lwmexamscore sc " +
                    "JOIN lwmexamrecord r ON sc.lwmrecordid = r.lwmrecordid " +
                    "JOIN lwmstudent s ON sc.lwmstudentid = s.lwmstudentid " +
                    "WHERE sc.lwmpaperid = ?");
```

- [ ] **Step 6: Add request attributes before the forward (after line 344)**

Insert before `request.setAttribute("studentScores", studentScores);` or after it, before the forward:

```java
        request.setAttribute("passLine", passLine);
        request.setAttribute("b2End", b2End);
        request.setAttribute("b3End", b3End);
        request.setAttribute("excelLine", excelLine);
        request.setAttribute("totalScore", totalScore);
        request.setAttribute("bracketLabels", bracketLabels);
```

- [ ] **Step 7: Commit**

```bash
git add src/main/java/com/example/lwmexam/action/lwmexam/lwmScoreAnalysisAction.java
git commit -m "feat: replace hardcoded 60-point pass line with dynamic 60% threshold in score analysis"
```

---

### Task 2: Frontend — dynamic grade labels and chart in JSP

**Files:**
- Modify: `src/main/webapp/lwmteacher_score_analysis.jsp`

- [ ] **Step 1: Read new attributes in the Java block (after line 16)**

```jsp
    Integer passLineObj = (Integer) request.getAttribute("passLine");
    int passLine = passLineObj != null ? passLineObj : 60;
    Integer b2EndObj = (Integer) request.getAttribute("b2End");
    int b2End = b2EndObj != null ? b2EndObj : 70;
    Integer b3EndObj = (Integer) request.getAttribute("b3End");
    int b3End = b3EndObj != null ? b3EndObj : 80;
    Integer excelLineObj = (Integer) request.getAttribute("excelLine");
    int excelLine = excelLineObj != null ? excelLineObj : 90;
    String[] bracketLabels = (String[]) request.getAttribute("bracketLabels");
    if (bracketLabels == null) bracketLabels = new String[]{"0-59","60-69","70-79","80-89","90-100"};
```

- [ ] **Step 2: Update student grade labels (lines 191-192)**

```jsp
                                String grade = score >= excelLine ? "优秀" : (score >= b3End ? "良好" : (score >= b2End ? "中等" : (score >= passLine ? "及格" : "不及格")));
                                String badgeClass = score >= excelLine ? "badge-green" : (score >= b3End ? "badge-blue" : (score >= b2End ? "badge-yellow" : (score >= passLine ? "badge-yellow" : "badge-red")));
```

- [ ] **Step 3: Update distribution chart labels (around line 307-310 in the JS block)**

Replace the hardcoded `['0-59','60-69','70-79','80-89','90-100']` with dynamic labels from the Java array. The JSP needs to output the Java array as a JS array:

```jsp
            xAxis: { data: ['<%= bracketLabels[0] %>','<%= bracketLabels[1] %>','<%= bracketLabels[2] %>','<%= bracketLabels[3] %>','<%= bracketLabels[4] %>'], axisLabel: { fontSize: 11 } },
```

- [ ] **Step 4: Commit**

```bash
git add src/main/webapp/lwmteacher_score_analysis.jsp
git commit -m "feat: use dynamic pass/excel thresholds for grade labels and chart in score analysis JSP"
```
