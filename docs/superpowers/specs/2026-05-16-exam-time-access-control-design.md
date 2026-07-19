# Exam Time Access Control

## Summary

Enforce the start/end time fields on exam papers so students can only take exams within the teacher-configured time window. Papers are visible to students before and after the window but cannot be entered.

## Time Window Rules

| Phase | Visibility | Can Enter? | Message |
|-------|-----------|------------|---------|
| Before start | Visible | No | "考试还未开始" |
| During window | Visible | Yes | -- |
| After end | Visible | No | "考试已结束" |

Once a student enters an exam during the valid window, they can continue answering and submit even after the end time passes.

## Changes

### 1. lwmTakeExam.java — Entry gate

Add time validation when student tries to enter an exam:
- Parse `lwmstarttime` and `lwmendtime` from the paper
- Compare current time against both bounds
- `now < startTime`: block with "考试还未开始"
- `now > endTime`: block with "考试已结束"
- `startTime <= now <= endTime`: allow as normal

### 2. lwmstudent_main.jsp — Available exams list

Modify the "可参加的考试" section:
- SQL query already fetches `lwmstarttime` and `lwmendtime`
- Add time status calculation per paper (before / during / after)
- Show status badge alongside each paper
- Disable "开始考试" button when outside time window, show appropriate prompt

### 3. No changes needed

- `lwmSubmitExam.java` — no time check (students who entered within window can submit)
- `lwmUpdateStudentAnswer.java` — no time check (same reason)
- Teacher-side create/edit — already supports time fields

## Test Plan

- Create a paper with start time in the future → student sees it but cannot enter
- Create a paper with current start time → student can enter and take exam
- Set end time to past → student cannot enter
- Student in middle of exam after end time passes → can still submit
- Teacher edits paper end time to extend → student can now enter
