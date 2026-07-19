# Prevent Unpublishing Classes With Submitted Exams

## Goal

In the paper publish page, prevent teachers from un-checking a class if any student in that class has already submitted the exam. Show a warning explaining why.

## Design

### Backend: `lwmPublishPaper.java`

**doGet changes:**
- After loading `teacherClasses`, query which published classes have submitted exam records
- Pass a new `submittedClasses` Set<String> to JSP

**doPost changes:**
- Before updating, compute removed classes = previous published - new selected
- For each removed class, query `lwmexamrecord` joined with `lwmstudent` — check if any student in that class has `lwmsubmitstatus IN (1, 2)` for this paper
- If found, reject with alert: "班级 XXX 已有学生完成考试，无法取消发布"
- Otherwise, proceed with update as normal

### Frontend: `lwmteacher_paper_publish.jsp`

- Read `submittedClasses` attribute
- For checkboxes whose class is in `submittedClasses`: set `disabled` and show a warning icon/label
- Add a warning note above the class list if any class has submitted records

### SQL for checking submitted records

```sql
SELECT COUNT(*) FROM lwmexamrecord r
JOIN lwmstudent s ON r.lwmstudentid = s.lwmstudentid
WHERE r.lwmpaperid = ? AND s.lwmclassname = ? AND r.lwmsubmitstatus IN (1, 2)
```

If count > 0, the class has submitted students.

## Files Changed

- `src/main/java/com/example/lwmexam/action/lwmexam/lwmPublishPaper.java`
- `src/main/webapp/lwmteacher_paper_publish.jsp`
