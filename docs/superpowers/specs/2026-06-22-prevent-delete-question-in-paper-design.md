# Prevent Deletion of Questions Used in Exam Papers

**Date**: 2026-06-22
**Status**: Approved

## Problem

In the teacher's question bank management (`lwmDeleteQuestion`), deleting a question currently has no safety check. Due to `ON DELETE CASCADE` foreign keys on `lwmpaperquestion`, deleting a question silently removes it from all papers that reference it — including published papers and papers students have already submitted. This corrupts exam data.

By contrast, paper deletion (`lwmDeletePaper`) already has a safety check via `hasSubmitRecord()`.

## Requirement

If a question is referenced by any paper (exists in `lwmpaperquestion`), it must NOT be deletable. The system must show an alert listing the specific papers that reference the question.

## Design

### Files Changed

| File | Change |
|---|---|
| `src/main/java/com/example/lwmexam/dao/lwmexam/lwmpaperDAO.java` | New method `getPapersByQuestionId(int)` |
| `src/main/java/com/example/lwmexam/action/lwmexam/lwmDeleteQuestion.java` | Pre-delete check calling the DAO method |

No JSP changes needed — the existing delete button and `confirm()` dialog remain as the first line of defense.

### DAO: New Method

```java
// lwmpaperDAO.java
public List<lwmExamPaper> getPapersByQuestionId(int questionId) {
    String sql = "SELECT p.* FROM lwmexampaper p "
               + "INNER JOIN lwmpaperquestion pq ON p.lwmpaperid = pq.lwmpaperid "
               + "WHERE pq.lwmquestionid = ?";
    // Returns all papers that reference this question
}
```

### Action: Pre-Delete Check

In `lwmDeleteQuestion.doGet()`, before calling `dao.lwmDeleteQuestion(id)`:

1. Call `paperDAO.getPapersByQuestionId(id)`
2. If the list is not empty:
   - Build a message listing paper names: `"该试题已被以下试卷引用，无法删除：\n- 试卷A\n- 试卷B"`
   - Append guidance: `"\n请先从对应试卷中移除该试题后再删除。"`
   - Respond with `alert()` + `history.back()` (matching existing response pattern)
3. If the list is empty: proceed with deletion as before

### Alert Format

```
该试题已被以下试卷引用，无法删除：
- 2024期末数学考试
- 2024期中数学测验

请先从对应试卷中移除该试题后再删除。
```

### Edge Cases

- **Paper was deleted**: The FK on `lwmpaperquestion` is ON DELETE CASCADE on `lwmpaperid`, so deleting a paper removes its junction rows. No stale references possible.
- **Concurrency**: Between check and delete, someone could add the question to a paper. The window is small and this is a low-concurrency educational system — not worth transaction overhead.

## Existing Pattern Reference

`lwmDeletePaper.doGet()` already follows this pattern: check `hasSubmitRecord()` before deleting, respond with `alert()` if blocked.
