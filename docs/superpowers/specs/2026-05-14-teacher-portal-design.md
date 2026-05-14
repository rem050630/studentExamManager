# 教师端功能设计

**日期**: 2026-05-14  
**项目**: lwmexam 考试管理系统  
**范围**: 教师端全部功能（排课查看、题库管理、试卷管理、考试查看、评分）

---

## 1. 整体架构

沿用现有三层模式：`JSP → @WebServlet → DAO → MysqlConn(JDBC)`

### 新增文件清单

| 模块 | Servlet | DAO | JSP |
|------|---------|-----|-----|
| 排课查看 | `lwmQueryTeacherCourses` | 复用 `lwmCourseArrangeDAO` | `lwmteacher_courses.jsp` |
| 题库管理 | `lwmAddQuestion`、`lwmQueryQuestion`、`lwmUpdateQuestion`、`lwmDeleteQuestion` | `lwmquestionDAO` | `lwmteacher_question_list.jsp`、`lwmteacher_question_add.jsp`、`lwmteacher_question_edit.jsp` |
| 试卷管理 | `lwmCreatePaper`、`lwmQueryPaper`、`lwmUpdatePaper`、`lwmDeletePaper` | `lwmpaperDAO` | `lwmteacher_paper_list.jsp`、`lwmteacher_paper_create.jsp`、`lwmteacher_paper_preview.jsp` |
| 考试查看 | `lwmQueryExamRecords` | 直接查 DB | `lwmteacher_exam_records.jsp` |
| 评分 | `lwmGradeExam`、`lwmSubmitScore` | `lwmscoreDAO` | `lwmteacher_grading.jsp`、`lwmteacher_score_detail.jsp` |

### 新增实体类

`lwmExamQuestion`、`lwmExamPaper`、`lwmExamRecord`、`lwmStudentAnswer`、`lwmExamScore`

### 数据库改动

`lwmexampaper` 表新增 `lwmclassname varchar(50)` 字段，用于按班级分配试卷。

---

## 2. 排课查看

- Servlet: `lwmQueryTeacherCourses`
- 从 session 获取 `teacher.lwmteacherid`，查询 `lwmstudentcourseteacher` JOIN `lwmexamsubject`
- 展示：班级、科目、学期
- 只显示当前登录教师自己的排课
- JSP: `lwmteacher_courses.jsp`，含按科目/班级筛选的搜索框

---

## 3. 题库管理

- 数据表: `lwmexamquestion`（已有）
- DAO: `lwmquestionDAO`（新建，含 CRUD + 随机抽取方法）
- Servlets:
  - `lwmQueryQuestion` — 列表，按科目+题型+关键字筛选
  - `lwmAddQuestion` — 添加，题型选择后动态显示/隐藏选项 A-D
  - `lwmUpdateQuestion` — 编辑
  - `lwmDeleteQuestion` — 删除（弹窗确认）
- 科目限制：教师只能操作自己排课科目的题目
- 题型: 单选题、多选题、判断题、简答题
- 正确答案格式: 单选 `A`，多选 `A,B,C`，判断 `对/错`，简答为文本

---

## 4. 试卷管理

- 数据表: `lwmexampaper`（新增 `lwmclassname` 字段）、`lwmpaperquestion`
- 创建流程:
  1. 选择科目（来自教师自己的排课）→ 选择班级 → 设置考试时间/时长
  2. 选择组卷方式:
     - 手动: 浏览题库勾选试题 → 预览 → 确认保存
     - 自动: 设定各题型数量+分值 → `ORDER BY RAND() LIMIT N` 随机抽取 → 预览 → 确认保存
  3. 预览页确认后写入 `lwmexampaper` 和 `lwmpaperquestion`
- 编辑限制: 已有学生提交的试卷不可修改试题组成
- DAO: `lwmpaperDAO`（新建）、`lwmquestionDAO`（复用随机抽取方法）

---

## 5. 查看学生考试情况

- Servlet: `lwmQueryExamRecords`
- 查询 `lwmexamrecord` JOIN `lwmstudent`，按试卷展示学生列表
- 列: 学号、姓名、班级、开始时间、提交时间、状态（已提交/未提交）
- 只展示该教师自己创建的试卷的记录
- 已提交的行可点击进入评分页
- 支持按班级和提交状态筛选

---

## 6. 评分

- 涉及表: `lwmstudentanswer`、`lwmexamquestion`、`lwmexamscore`
- Servlet:
  - `lwmGradeExam` — 加载学生答卷，自动比对客观题得分，展示完整评分界面
  - `lwmSubmitScore` — 保存评分结果
- 自动评分规则:
  - 单选题: 精确匹配
  - 多选题: 排序后完全相等比较
  - 判断题: 精确匹配
  - 简答题: 不自动评分，教师手工给分
- 客观题分数可手动调整，简答题由教师填写
- 总分写入 `lwmexamscore`，各题得分回写 `lwmstudentanswer.lwmquestionscore`

---

## 7. 教师端导航

`lwmteacher_main.jsp` 补充功能导航:

- 我的排课 → `lwmQueryTeacherCourses`
- 题库管理 → `lwmQueryQuestion`
- 试卷管理 → `lwmQueryPaper`
- 考试情况 → `lwmQueryExamRecords`

## 8. 测试要点

- 自动评分多选答案排序比对正确性
- 自动组卷随机抽取不重复
- 教师只能操作自己排课科目/班级的范围限制
- 已提交试卷不可修改试题组成的约束
- 评分提交后成绩正确写入成绩表和答题表
