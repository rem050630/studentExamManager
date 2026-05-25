# Exam Duration Timer Design

## Overview

教师已可在试卷中设置 `lwmexamtime`（考试时长，分钟），但目前该字段仅作为展示信息，没有实际约束力。本次改动实现：
1. 学生端考试页面显示倒计时，从学生实际开始时间计算剩余时间
2. 倒计时归零自动强制交卷
3. 服务端提交时校验是否超时
4. 主动交卷时检查未答题并提醒

## Data Model

无需新增字段。现有字段已够用：
- `lwmexampaper.lwmexamtime`（int，分钟）— 考试时长
- `lwmexamrecord.lwmstarttime`（datetime）— 学生实际开始考试的时间

剩余时间计算：`deadline = record.lwmstarttime + paper.lwmexamtime * 60` 秒

## Backend: lwmTakeExam.java

改动：首次进入考试时，若不存在草稿记录，创建考试记录并将 `lwmstarttime` 设为当前时间。

当前逻辑只读取已有草稿，不产生新记录。这样学生首次打开页面时没有 `lwmstarttime` 可用于计时。需在发现无草稿记录时立即 INSERT 一条 `submitstatus=0` 的记录，`lwmstarttime=lwmendtime=now`。

然后将 `recordStartTime`（java.sql.Timestamp）传递到 JSP 作为 `request` attribute。

## Backend: lwmSubmitExam.java

提交开始处增加超时校验：

```java
long deadline = record.getLwmstarttime().getTime() + paper.getLwmexamtime() * 60 * 1000L;
if (System.currentTimeMillis() > deadline) {
    out.print("<script>alert('考试时间已到，无法提交');history.back();</script>");
    return;
}
```

自动提交时前端在倒计时归零那一刻发起请求，此时 `当前时间 ≈ deadline`，仍在允许范围内。

## Frontend: lwmstudent_take_exam.jsp

### 倒计时显示

在试卷头部添加倒计时区域，由 JSP 用 `recordStartTime` 和 `paper.lwmexamtime` 计算初始剩余秒数传给 JS：

```java
long deadline = recordStartTime.getTime() + paper.getLwmexamtime() * 60 * 1000L;
long remaining = (deadline - System.currentTimeMillis()) / 1000;
```

显示格式 `HH:MM:SS`，剩余不足 5 分钟时变红警告。每秒递减，归零自动提交。

### 未答题提醒

点击"提交试卷"按钮时：
- 遍历所有题目，检查是否有未作答的题
- 单选题：未选任何 radio
- 多选题：未选任何 checkbox
- 判断题：未选任何 radio
- 简答题：textarea 为空
- 如果有未答题，弹出 confirm："还有 X 道题未作答，确定要提交吗？"
- 自动提交（倒计时归零）时不弹此提醒

## Files Changed

| File | Change |
|---|---|
| `src/main/java/.../action/.../lwmTakeExam.java` | 首次进入考试时创建记录，设置 lwmstarttime，传递到 JSP |
| `src/main/webapp/lwmstudent_take_exam.jsp` | 添加倒计时CSS/JS，添加未答题检查逻辑 |
| `src/main/java/.../action/.../lwmSubmitExam.java` | 添加服务端超时校验 |

## Edge Cases

- **页面刷新**：重新从服务端计算剩余时间，计时器不重置
- **超时后手动提交**：服务端校验拒绝
- **首次进入 vs 已存草稿**：首次进入时 `lwmTakeExam` 创建记录；后续进入复用已有记录的 `lwmstarttime`
- **全部未答**：提醒 "还有 N 道题未作答"，确认后仍可提交（允许交白卷）
