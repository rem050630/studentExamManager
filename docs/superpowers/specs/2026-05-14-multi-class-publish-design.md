# 试卷多班级发布 - 设计方案

**日期:** 2026-05-14  
**方案:** 逗号分隔存储（方案 A）

## 概述

将试卷的班级分配从"创建时单一选择"改为"创建后多班级发布"。
`lwmexampaper.lwmclassname` 字段存储逗号分隔的班级名（如 `"计算机2101,计算机2102"`），支持一张试卷发布到多个班级。

## 影响范围

| 文件 | 变更类型 | 说明 |
|------|----------|------|
| `lwmteacher_paper_create.jsp` | 修改 | 移除"分配班级"下拉框 |
| `lwmCreatePaper.java` | 修改 | `lwmclassname` 入库设为空字符串 |
| `lwmteacher_paper_list.jsp` | 修改 | 新增发布按钮/状态，班级列显示逗号分隔列表 |
| `lwmteacher_paper_publish.jsp` | **新增** | 发布班级选择页面（多选 checkbox） |
| `lwmPublishPaper.java` | **新增** | 发布/修改发布 Servlet |
| `lwmstudent_main.jsp` | 修改 | SQL 改用 `FIND_IN_SET` |
| `lwmQueryPaper.java` | 修改 | 班级筛选改用 `LIKE` |
| `lwmUpdatePaper.java` | 修改 | 移除 `lwmclassname` 更新逻辑 |
| `lwmpaperDAO.java` | 修改 | `lwmUpdatePaper` SQL 移除 lwmclassname 字段 |
| `lwmteacher_paper_edit.jsp` | 修改 | 移除班级编辑区域（已有 hasSubmit 保护） |

## 详细设计

### 1. 创建试卷

- JSP 页面删除班级下拉框及相关 label
- Servlet 中 `lwmclassname` 参数设为空字符串 `""`
- DAO INSERT 不变，传入空字符串

### 2. 发布页面（新增）

- **入口:** 试卷管理列表操作列，根据 `lwmclassname` 是否为空显示：
  - 空 → "发布"按钮
  - 非空 → 已发布班级名 + "修改发布"按钮
- **班级数据源:** `SELECT DISTINCT lwmclassname FROM lwmstudentcourseteacher WHERE lwmteacherid = ?`
- **UI:** 多选 checkbox 列表 + 试卷名称显示
- **提交:** POST 到 `lwmPublishPaper`，拼接选中班级为逗号分隔字符串，UPDATE `lwmclassname`
- **回显:** 已发布的班级在 checkbox 中回显为选中状态

### 3. 学生端查询

```sql
-- 原:
WHERE p.lwmclassname = ?

-- 改为:
WHERE FIND_IN_SET(?, p.lwmclassname)
```

### 4. 试卷管理筛选

班级筛选从精确匹配改为模糊匹配：
```sql
-- 原:
AND p.lwmclassname = ?

-- 改为:
AND p.lwmclassname LIKE CONCAT('%', ?, '%')
```

### 5. 编辑页面

- 已有 `hasSubmit` 逻辑保护，有提交记录时班级已为只读
- 无提交记录时可修改：保持原样或移除，发布时统一管理

### 6. 更新试卷 (lwmUpdatePaper)

- DAO 的 `lwmUpdatePaper` SQL 移除 `lwmclassname=?` 字段
- Servlet 中不再从 request 读取和设置 `lwmclassname`

## 数据库

无需 schema 变更。`lwmclassname` 字段保持 VARCHAR，内容从单个班级名变为逗号分隔列表。
