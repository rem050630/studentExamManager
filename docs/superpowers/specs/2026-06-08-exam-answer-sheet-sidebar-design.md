# Exam Answer Sheet Sidebar Design

## Overview

给考试页面 `lwmstudent_take_exam.jsp` 添加答题卡侧边栏，帮助学生快速查看作答进度并跳转到任意题目。

## Layout

Container 从单栏 `max-width: 900px` 改为弹性双栏布局：

```
┌──────────────────────────────────────────────────────┐
│  Container (max-width: 1080px, display:flex, gap:20) │
│  ┌──────────────────┐  ┌────────────────────────┐    │
│  │  Sidebar (210px) │  │  Main (flex:1)         │    │
│  │  sticky top:24   │  │  Header / Questions    │    │
│  └──────────────────┘  └────────────────────────┘    │
└──────────────────────────────────────────────────────┘
```

- 侧边栏在左侧，宽度 210px
- `position: sticky; top: 24px` 随页面滚动吸附
- 侧边栏自身 `max-height: calc(100vh - 48px); overflow-y: auto`
- 主内容区 `flex: 1` 保持现有卡片布局不变

## Sidebar Internal Structure

风格和页面现有卡片一致：白色背景、圆角 12px、浅阴影。

```
┌─────────────────────┐
│  答题卡          [−] │  ← 标题行（amber 渐变）
│                     │
│  单选题             │  ← 题型标签（小号灰色）
│  [1][2][3][4][5]   │  ← 题号按钮网格
│                     │
│  多选题             │
│  [1][2]             │
│                     │
│  判断题             │
│  [1][2][3]          │
│                     │
│  简答题             │
│  [1][2]             │
└─────────────────────┘
```

### 标题行
- amber 渐变背景 `linear-gradient(135deg, #f59e0b, #d97706)`，白色文字
- 左侧文字 "答题卡"，右侧折叠按钮 `−`（展开）/ `+`（收起）

### 题型标签
- 字体 `0.75rem`，颜色 `#94a3b8`（slate-400）
- 上下各 4px 间距

### 题号按钮
- 尺寸 `28×28px`，圆角 `8px`
- 默认：灰底 `#e2e8f0`，灰色文字 `#64748b`
- 已答：绿底 `#22c55e`，白色文字
- 字体 `0.8rem`，`display: inline-flex` 居中
- 网格排列，每行约 4 个，gap: 6px
- 鼠标悬停时轻微放大或加深

### 折叠状态
- 侧边栏缩窄至约 40px
- 只显示竖排 "答题卡" 文字标签（`writing-mode: vertical-rl`）
- 顶部 `+` 展开按钮
- 宽度过渡 `transition: width 0.3s ease`

## Interaction

### 点击题号 → 滚动到题目
- 每题卡片挂 id：`question_<lwmquestionid>`（使用数据库主键，全局唯一）
- 题号按钮用 `data-qid="<lwmquestionid>"` 标记对应题目
- `onclick` 通过 `data-qid` 找到卡片，调用 `scrollIntoView({ behavior: 'smooth', block: 'center' })`

### 作答后实时变色
- 委托监听：在题目卡片层级监听所有 `input`、`textarea` 的 `change` / `input` 事件
- 判断逻辑：
  - 单选/判断：检查是否有 radio 被选中
  - 多选：检查是否有 checkbox 被选中
  - 简答：检查 textarea 是否非空
- 满足条件则对应按钮加 class `.answered`，否则移除

### 初始状态
- 页面加载时根据 `draftAnswers`（已保存草稿）设置按钮初始颜色
- JS 初始化函数遍历所有题目，用和 JSP `isOptionSelected` 同逻辑判断

## Data Flow

```
page load → JSP loops questions → generates sidebar buttons (data-qid) + question card ids (question_<id>)
         → JS init reads draftAnswers → sets initial button colors
         → JS binds change/input listeners → real-time color update via data-qid mapping
         → click button → document.getElementById('question_' + qid).scrollIntoView(...)
```

无后端改动，纯前端实现。

## Files Changed

| File | Change |
|---|---|
| `src/main/webapp/lwmstudent_take_exam.jsp` | 添加侧边栏 HTML（JSP 生成）、CSS、JS |

单文件改动，不涉及后端。

## Edge Cases

- **题目很多（>50题）**：侧边栏 `overflow-y: auto` 独立滚动
- **折叠状态作答**：按钮颜色仍会更新，展开后可见最新状态
- **页面刷新**：从 draftAnswers 恢复颜色状态
- **自动提交（倒计时归零）**：侧边栏不做额外处理，跟随表单提交
- **题目类型可为空**：试卷可能只有部分题型，空题型不在侧边栏中显示
