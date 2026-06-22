# Restrict Paper Publishing by Teacher Course Arrangements

**Date**: 2026-06-22
**Status**: Approved

## Problem

In the paper publishing page (`lwmPublishPaper`), the class list currently shows ALL classes a teacher is assigned to, regardless of subject. This means:

- Teacher teaches Math to Class 1 and Class 2, and English only to Class 1
- When publishing an English paper, Class 2 incorrectly appears as an option
- The teacher could accidentally publish an English paper to Class 2, where they don't teach English

## Requirement

When publishing a paper, the class list must be filtered by the paper's subject (`lwmsubjectid`). Only classes where the teacher actually teaches that specific subject (per `lwmstudentcourseteacher`) should be available for selection. Backend must also validate on POST.

## Design

### Files Changed

| File | Change |
|---|---|
| `src/main/java/com/example/lwmexam/action/lwmexam/lwmPublishPaper.java` | GET: add `lwmsubjectid` filter to class query; POST: validate selected classes against course arrangement |

No JSP changes needed — the class list rendering is unchanged, it just receives a pre-filtered list.

### GET: Class List Filtering

Current query (line 58-59):
```sql
SELECT DISTINCT lwmclassname FROM lwmstudentcourseteacher WHERE lwmteacherid = ?
```

New query:
```sql
SELECT DISTINCT lwmclassname FROM lwmstudentcourseteacher
WHERE lwmteacherid = ? AND lwmsubjectid = ?
```

The paper's `lwmsubjectid` is already loaded via `dao.lwmQueryPaperById(paperId)`. Pass it as the second parameter.

### POST: Backend Validation

Before saving, for each class in `selectedClasses`, verify the teacher-subject-class combination exists in `lwmstudentcourseteacher`:

```sql
SELECT COUNT(*) FROM lwmstudentcourseteacher
WHERE lwmteacherid = ? AND lwmsubjectid = ? AND lwmclassname = ?
```

Logic:
1. Load the paper's `lwmsubjectid` (already loaded for the GET logic check above)
2. Split `selectedClasses` into valid and invalid sets
3. Only save valid classes to `lwmclassname`
4. If any classes were filtered out, show a message listing them

### Success Message When Classes Are Filtered

```
发布成功。以下班级非本课程授课班级，已自动跳过：计算机2班
```

If no classes were filtered, the existing "发布成功" message remains unchanged.

### Edge Cases

- **All classes filtered out**: If the teacher selects only invalid classes (e.g., via a crafted POST), the paper's `lwmclassname` becomes empty, effectively unpublishing it. Show: "所选班级均非本课程授课班级，发布失败".
- **No classes selected**: Existing behavior preserved — paper gets empty `lwmclassname`.
