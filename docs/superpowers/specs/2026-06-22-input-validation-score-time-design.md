# Input Validation: Score Range, Exam Time, and Question Score

**Date**: 2026-06-22
**Status**: Approved

## Problem

Three input validation gaps exist:

1. **Grading scores**: The score input for grading allows negative values. The JSP has `min="0"` on the input and JS validates upper bounds, but JS doesn't check for negatives. Server-side (`lwmSubmitScore`) silently clamps overscored values but doesn't reject negatives.

2. **Exam time**: Paper creation/update allows `lwmexamtime` to be 0 or negative (no `min` attribute, no server-side check). A value of 0 makes no sense for an exam.

3. **Per-question scores**: Paper creation/update parses per-type scores (`danxscore`, `duoxscore`, `pdscore`, `jdscore`) without server-side validation for negative values. The JSP has `min="0"` but the server doesn't check.

## Requirement

- Grading: score must be 0 to the question type's max score (from paper config). Invalid scores must be rejected with an alert.
- Exam time: must be > 0 minutes. Rejected with alert if <= 0.
- Per-question scores: must be >= 0. Rejected with alert if negative.

## Design

### Files Changed

| File | Change |
|---|---|
| `src/main/webapp/lwmteacher_grading.jsp` | JS: add negative score check |
| `src/main/java/.../action/lwmexam/lwmSubmitScore.java` | Replace silent clamping with rejection for invalid scores |
| `src/main/webapp/lwmteacher_paper_create.jsp` | Add `min="1"` on exam time input |
| `src/main/webapp/lwmteacher_paper_edit.jsp` | Add `min="1"` on exam time input |
| `src/main/java/.../action/lwmexam/lwmCreatePaper.java` | Reject `examTime <= 0`; reject negative per-type scores |
| `src/main/java/.../action/lwmexam/lwmUpdatePaper.java` | Reject `examTime <= 0`; reject negative per-type scores |

### A. Grading Score Validation

**JSP** (`lwmteacher_grading.jsp`): In `validateScores()`, add before the existing max check:
```javascript
if (score < 0) {
    alert('第' + (i + 1) + '题得分不能为负数');
    return false;
}
```

**Servlet** (`lwmSubmitScore.java`): Replace current silent clamping:
```java
// Before: if (maxScore > 0 && score > maxScore) score = maxScore;
// After:
if (score < 0 || (maxScore > 0 && score > maxScore)) {
    out.println("<script>alert('分数无效，应在0到" + maxScore + "分之间');history.go(-1);</script>");
    return;
}
```

### B. Exam Time Validation

**JSP**: Change `lwmexamtime` input from `<input type="number" ... required>` to `<input type="number" ... min="1" required>` in both create and edit pages.

**Servlet** (`lwmCreatePaper.java`, `lwmUpdatePaper.java`): After parsing `examTime`, add:
```java
if (examTime <= 0) {
    out.println("<script>alert('考试时间必须大于0分钟');history.go(-1);</script>");
    return;
}
```

### C. Per-Question Score Validation

**Servlet** (`lwmCreatePaper.java`, `lwmUpdatePaper.java`): After parsing the four score values, add:
```java
if (danxScore < 0 || duoxScore < 0 || pdScore < 0 || jdScore < 0) {
    out.println("<script>alert('试题分值不能为负数');history.go(-1);</script>");
    return;
}
```

The JSP already has `min="0"` on all score inputs, so no JSP change needed for this item.

### Alert Messages Summary

| Scenario | Message |
|---|---|
| Score negative in browser | `第X题得分不能为负数` |
| Score invalid on server | `分数无效，应在0到Y分之间` |
| Exam time <= 0 | `考试时间必须大于0分钟` |
| Per-question score negative | `试题分值不能为负数` |
