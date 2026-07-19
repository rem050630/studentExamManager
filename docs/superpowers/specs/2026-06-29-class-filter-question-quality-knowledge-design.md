# 试题质量与知识点分析支持单班级筛选

**Date**: 2026-06-29
**Status**: Approved

## Problem

教师端成绩分析页面（`lwmteacher_score_analysis.jsp`）有4个Tab。Tab1（成绩概览）已经支持按班级筛选，但Tab2（试题质量）和Tab3（知识点分析）调用后端API时始终不传 `classname` 参数，导致始终展示整张试卷全部班级的汇总数据，无法单独分析某个班级的试题质量和知识点掌握情况。

## Requirement

试题质量（`/lwmQuestionQuality`）和知识点分析（`/lwmKnowledgeAnalysis`）支持可选的 `classname` 参数：

- 传入 `classname` 时：只统计该班级学生的答案数据
- 不传 `classname` 时：保持现有行为，统计全部班级汇总数据
- 前端成绩分析页面自动沿用筛选栏已选的班级，传递给两个API

## Design

### Files Changed

| File | Change |
|---|---|
| `lwmQuestionQualityAction.java` | 新增 `classname` 参数；有值时在答案查询和成绩查询中JOIN lwmstudent过滤 |
| `lwmKnowledgeAnalysisAction.java` | Mode 1（总体分析）新增 `classname` 参数；有值时JOIN lwmstudent过滤 |
| `lwmteacher_score_analysis.jsp` | `loadQuestionQuality()`和`loadKnowledgeAnalysis()`的fetch URL追加 `&classname=xxx` |

### A. lwmQuestionQualityAction — 新增 classname 参数

**接收参数**：当前只有 `paperid`，新增 `classname`（可选）

**改动1：答案查询（当前第77-83行）**

```sql
-- 当前（无班级过滤）
SELECT sa.lwmquestionid, sa.lwmstudentid, sa.lwmstudentanswer, sa.lwmquestionscore,
       q.lwmquestiontype, q.lwmcorrectanswer
FROM lwmstudentanswer sa
JOIN lwmexamquestion q ON sa.lwmquestionid = q.lwmquestionid
WHERE sa.lwmpaperid = ?

-- 有classname时追加JOIN
SELECT sa.lwmquestionid, sa.lwmstudentid, sa.lwmstudentanswer, sa.lwmquestionscore,
       q.lwmquestiontype, q.lwmcorrectanswer
FROM lwmstudentanswer sa
JOIN lwmexamquestion q ON sa.lwmquestionid = q.lwmquestionid
JOIN lwmstudent s ON sa.lwmstudentid = s.lwmstudentid AND s.lwmclassname = ?
WHERE sa.lwmpaperid = ?
```

**改动2：成绩查询（当前第114-117行）**

```sql
-- 当前（无班级过滤）
SELECT lwmstudentid, lwmtotalscore FROM lwmexamscore WHERE lwmpaperid = ? ORDER BY lwmtotalscore DESC

-- 有classname时追加JOIN
SELECT sc.lwmstudentid, sc.lwmtotalscore
FROM lwmexamscore sc
JOIN lwmstudent s ON sc.lwmstudentid = s.lwmstudentid AND s.lwmclassname = ?
WHERE sc.lwmpaperid = ?
ORDER BY sc.lwmtotalscore DESC
```

**实现逻辑**：
1. 读取 `classname` 参数
2. 判断是否非空且非空字符串
3. 有值：在两条SQL中加入 `JOIN lwmstudent` 并传入classname参数
4. 空值：保持原SQL不变

### B. lwmKnowledgeAnalysisAction — Mode 1 新增 classname 参数

**接收参数**：当前有 `paperid` 和 `classnames`（比较模式），新增 `classname`（单班级筛选，可选）

**改动：Mode 1 SQL（当前第179-191行）**

```sql
-- 当前（无班级过滤）
SELECT kp.lwmkpid, kp.lwmkpname, ...
FROM lwmknowledgepoint kp
JOIN lwmquestionknowledge qk ON kp.lwmkpid = qk.lwmkpid
JOIN lwmpaperquestion pq ON qk.lwmquestionid = pq.lwmquestionid
JOIN lwmstudentanswer sa ON sa.lwmquestionid = qk.lwmquestionid AND sa.lwmpaperid = pq.lwmpaperid
WHERE pq.lwmpaperid = ?
GROUP BY kp.lwmkpid, kp.lwmkpname

-- 有classname时追加JOIN
... all same JOINs ...
JOIN lwmstudent s ON sa.lwmstudentid = s.lwmstudentid AND s.lwmclassname = ?
WHERE pq.lwmpaperid = ?
GROUP BY kp.lwmkpid, kp.lwmkpname
```

**实现逻辑**：同A，在Mode 1分支中判断classname，有值时拼接额外的JOIN子句和参数。

### C. lwmteacher_score_analysis.jsp — 前端传参

**改动1：loadQuestionQuality() （当前第349行）**
```javascript
// 当前
fetch('lwmQuestionQuality?paperid=' + encodeURIComponent(paperId))

// 改后
var classname = '<%= selectedClass != null ? selectedClass : "" %>';
var url = 'lwmQuestionQuality?paperid=' + encodeURIComponent(paperId);
if (classname) url += '&classname=' + encodeURIComponent(classname);
fetch(url)
```

**改动2：loadKnowledgeAnalysis() （当前第389行）**
```javascript
// 当前
fetch('lwmKnowledgeAnalysis?paperid=' + encodeURIComponent(paperId))

// 改后
var classname = '<%= selectedClass != null ? selectedClass : "" %>';
var url = 'lwmKnowledgeAnalysis?paperid=' + encodeURIComponent(paperId);
if (classname) url += '&classname=' + encodeURIComponent(classname);
fetch(url)
```

### Edge Cases

- **classname为空串**：不传参，保持现有汇总行为
- **classname指向无学生数据**：SQL返回空结果集，前端展示空状态
- **区分度计算（试题质量）**：区分度基于高/低分组（各27%），班级筛选后学生总数减少，top/bottom组阈值自动按筛选后的学生数重新计算
- **知识点分析Mode 2（比较模式）**：已有`classnames`参数，不受影响
