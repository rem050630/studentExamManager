# 试题质量与知识点分析支持单班级筛选 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 成绩分析页面的试题质量Tab和知识点分析Tab支持按班级筛选，与成绩概览Tab的班级筛选行为一致。

**Architecture:** 在两个后端API（`lwmQuestionQualityAction` / `lwmKnowledgeAnalysisAction`）中新增可选的 `classname` 参数，有值时通过 `JOIN lwmstudent` 过滤特定班级数据，空值时保持现有汇总行为。前端JSP在两个fetch调用中拼接已选班级参数。

**Tech Stack:** Java Servlet, JDBC, JSP, JavaScript fetch

## Global Constraints

- classname为可选参数，不传或为空时保持现有汇总行为
- 不修改 `lwmteacher_class_compare.jsp`（班级对比页）
- 不修改 `lwmKnowledgeAnalysisAction` 的 Mode 2（比较模式，已有classnames参数）

---

### Task 1: 后端 — lwmQuestionQualityAction 新增 classname 参数

**Files:**
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmQuestionQualityAction.java:26-127`

**Interfaces:**
- Consumes: HTTP GET parameter `classname` (optional String)
- Produces: same JSON format — filtered to single class when classname provided

- [ ] **Step 1: 读取 classname 参数**

在 `lwmQuestionQualityAction.java` 第27行之后（`int paperId = ...` 之后），添加读取classname参数：

```java
int paperId = Integer.parseInt(paperIdStr);

// 新增：读取可选的 classname 参数
String classname = request.getParameter("classname");
boolean filterByClass = classname != null && !classname.trim().isEmpty();
```

- [ ] **Step 2: 修改答案查询SQL — 有条件地JOIN lwmstudent**

将第77-83行的答案查询替换为：

```java
rs = db.doQuery(
    "SELECT sa.lwmquestionid, sa.lwmstudentid, sa.lwmstudentanswer, sa.lwmquestionscore, " +
    "q.lwmquestiontype, q.lwmcorrectanswer " +
    "FROM lwmstudentanswer sa " +
    "JOIN lwmexamquestion q ON sa.lwmquestionid = q.lwmquestionid " +
    (filterByClass ? "JOIN lwmstudent s ON sa.lwmstudentid = s.lwmstudentid AND s.lwmclassname = ? " : "") +
    "WHERE sa.lwmpaperid = ?",
    filterByClass ? new Object[]{classname.trim(), paperId} : new Object[]{paperId});
```

- [ ] **Step 3: 修改成绩查询SQL — 有条件地JOIN lwmstudent**

将第114-117行的成绩查询替换为：

```java
rs = db.doQuery(
    "SELECT sc.lwmstudentid, sc.lwmtotalscore " +
    "FROM lwmexamscore sc " +
    (filterByClass ? "JOIN lwmstudent s ON sc.lwmstudentid = s.lwmstudentid AND s.lwmclassname = ? " : "") +
    "WHERE sc.lwmpaperid = ? " +
    "ORDER BY sc.lwmtotalscore DESC",
    filterByClass ? new Object[]{classname.trim(), paperId} : new Object[]{paperId});
```

- [ ] **Step 4: 编译验证**

```bash
cd D:/Java/IdeaProjects/lwmexam && mvn compile -q 2>&1
```
Expected: BUILD SUCCESS

- [ ] **Step 5: Commit**

```bash
git add src/main/java/com/example/lwmexam/action/lwmexam/lwmQuestionQualityAction.java
git commit -m "feat: add optional classname filter to question quality analysis API"
```

---

### Task 2: 后端 — lwmKnowledgeAnalysisAction Mode 1 新增 classname 参数

**Files:**
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmKnowledgeAnalysisAction.java:175-204`

**Interfaces:**
- Consumes: HTTP GET parameter `classname` (optional String, used only in Mode 1 when classnames is absent)
- Produces: same Mode 1 JSON format — filtered to single class when classname provided

- [ ] **Step 1: 在 Mode 1 分支读取 classname 参数**

在 Mode 1 分支开头（第175行 `} else {` 之后，第177行 `List<Map<String, Object>> result` 之前）添加：

```java
} else {
    // Mode 1: Overall KP analysis
    String classname = request.getParameter("classname");
    boolean filterByClass = classname != null && !classname.trim().isEmpty();

    List<Map<String, Object>> result = new ArrayList<>();
```

- [ ] **Step 2: 修改 Mode 1 聚合查询SQL — 有条件地JOIN lwmstudent**

将第179-191行的查询替换为：

```java
String sql = "SELECT kp.lwmkpid, kp.lwmkpname, " +
    "COUNT(DISTINCT sa.lwmquestionid) AS qcnt, " +
    "AVG(CASE WHEN sa.lwmquestionscore > 0 THEN 1 ELSE 0 END) AS score_rate, " +
    "COUNT(*) AS total_answers " +
    "FROM lwmknowledgepoint kp " +
    "JOIN lwmquestionknowledge qk ON kp.lwmkpid = qk.lwmkpid " +
    "JOIN lwmpaperquestion pq ON qk.lwmquestionid = pq.lwmquestionid " +
    "JOIN lwmstudentanswer sa ON sa.lwmquestionid = qk.lwmquestionid AND sa.lwmpaperid = pq.lwmpaperid " +
    (filterByClass ? "JOIN lwmstudent s ON sa.lwmstudentid = s.lwmstudentid AND s.lwmclassname = ? " : "") +
    "WHERE pq.lwmpaperid = ? " +
    "GROUP BY kp.lwmkpid, kp.lwmkpname " +
    "ORDER BY score_rate ASC";
rs = db.doQuery(sql,
    filterByClass ? new Object[]{classname.trim(), paperId} : new Object[]{paperId});
```

- [ ] **Step 3: 编译验证**

```bash
cd D:/Java/IdeaProjects/lwmexam && mvn compile -q 2>&1
```
Expected: BUILD SUCCESS

- [ ] **Step 4: Commit**

```bash
git add src/main/java/com/example/lwmexam/action/lwmexam/lwmKnowledgeAnalysisAction.java
git commit -m "feat: add optional classname filter to knowledge analysis Mode 1 API"
```

---

### Task 3: 前端 — lwmteacher_score_analysis.jsp 传递 classname 参数

**Files:**
- Modify: `src/main/webapp/lwmteacher_score_analysis.jsp:343-430`

**Interfaces:**
- Consumes: `selectedClass` (JSP variable, already available at line 10)
- Produces: `classname` query parameter appended to fetch URLs when non-empty

- [ ] **Step 1: 提取 classname 为 JS 变量**

在 `<script>` 标签开头（第270行之后），所有函数定义之前，添加一个全局JS变量：

```javascript
<script>
// 从JSP获取当前筛选的班级
var selectedClass = '<%= selectedClass != null ? selectedClass : "" %>';
```

- [ ] **Step 2: 修改 loadQuestionQuality() — 追加 classname 参数**

将第349行的 fetch 调用替换为：

```javascript
function loadQuestionQuality() {
    if (qualityLoaded) return;
    qualityLoaded = true;
    var paperId = '<%= selectedPaperId != null ? selectedPaperId : "" %>';
    if (!paperId) { document.getElementById('qualityLoading').style.display = 'none'; document.getElementById('qualityEmpty').style.display = 'block'; return; }

    var url = 'lwmQuestionQuality?paperid=' + encodeURIComponent(paperId);
    if (selectedClass) url += '&classname=' + encodeURIComponent(selectedClass);

    fetch(url)
        .then(function(r) { return r.json(); })
        .then(function(data) {
```

- [ ] **Step 3: 修改 loadKnowledgeAnalysis() — 追加 classname 参数**

将第389行的 fetch 调用替换为：

```javascript
function loadKnowledgeAnalysis() {
    if (kpLoaded) return;
    kpLoaded = true;
    var paperId = '<%= selectedPaperId != null ? selectedPaperId : "" %>';
    if (!paperId) { document.getElementById('kpLoading').style.display = 'none'; document.getElementById('kpEmpty').style.display = 'block'; return; }

    var url = 'lwmKnowledgeAnalysis?paperid=' + encodeURIComponent(paperId);
    if (selectedClass) url += '&classname=' + encodeURIComponent(selectedClass);

    fetch(url)
        .then(function(r) { return r.json(); })
        .then(function(data) {
```

- [ ] **Step 4: 验证JSP语法**

```bash
cd D:/Java/IdeaProjects/lwmexam && mvn compile -q 2>&1
```
Expected: BUILD SUCCESS (JSP编译在Tomcat运行时完成，mvn compile确保无Java语法错误)

- [ ] **Step 5: Commit**

```bash
git add src/main/webapp/lwmteacher_score_analysis.jsp
git commit -m "feat: pass classname filter to question quality and knowledge analysis tabs"
```

---

### Verification Checklist

完成所有3个Task后，手动验证以下场景：

- [ ] 选择试卷 + 选择具体班级 → 切到试题质量Tab → 数据仅反映该班级
- [ ] 选择试卷 + 选择具体班级 → 切到知识点分析Tab → 数据仅反映该班级
- [ ] 选择试卷 + 选择"全部班级" → 两个Tab显示全部汇总数据（行为不变）
- [ ] 切换班级后重新点击Tab → 数据更新为新班级的数据（注意：当前实现有一次性加载标记 `qualityLoaded`/`kpLoaded`，切换班级后需刷新页面重新查询）
- [ ] Tab1（成绩概览）班级筛选行为不受影响
- [ ] Tab4（班级对比）不受影响
