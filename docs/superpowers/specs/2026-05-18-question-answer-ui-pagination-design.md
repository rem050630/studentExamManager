# 试题答案选择UI优化 + 教师端分页

## Part A: 答案选择方式改进

**文件**: `lwmteacher_question_add.jsp`

将手动输入正确答案改为直接选择：
- 单选题：ABCD 选项前各加 radio，选一个
- 多选题：ABCD 选项前各加 checkbox，可多选
- 判断题：显示"对"/"错"两个 radio
- 简答题：保持文本输入框

所有控件 name 为 `lwmcorrectanswer`，输出格式不变（单选 "A"，多选 "A,B,C"，判断 "对"/"错"）。

JavaScript `toggleOptions()` 需要同步切换选项区和答案区。

**后端无改动**：`lwmAddQuestion.java` 和 `lwmUpdateQuestion.java` 从 `request.getParameter("lwmcorrectanswer")` 取值，格式不变。

## Part B: 教师端分页

**文件**: `lwmQueryQuestion.java`, `lwmQueryPaper.java`, `lwmteacher_question_list.jsp`, `lwmteacher_paper_list.jsp`

复用管理员端的分页组件：
- 后端引入 `Fpage`，每页 6 条，COUNT + LIMIT 分页
- 前端引入 `lwmfoot.jsp`，筛选参数编码到 `tj` 翻页时保持
- `lwmQueryPaper` 的筛选参数较多，classname/papername/subjectid 编码为 `tj` 字符串
