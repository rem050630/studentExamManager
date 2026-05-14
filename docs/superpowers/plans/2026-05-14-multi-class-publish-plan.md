# 试卷多班级发布 - 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将试卷班级分配从"创建时单选"改为"创建后多班级发布"，使用逗号分隔存储支持一张试卷发布到多个班级。

**Architecture:** 在现有 lwmexampaper.lwmclassname VARCHAR 字段中存储逗号分隔的班级名。创建试卷时不再选班级（存空字符串），新增发布页面支持多选 checkbox。学生端使用 FIND_IN_SET 查询。班级筛选使用 LIKE 模糊匹配。

**Tech Stack:** Java Servlet + JSP + MySQL (JDBC)

---

### Task 1: 创建试卷 — 移除班级选择

**Files:**
- Modify: `src/main/webapp/lwmteacher_paper_create.jsp:74-84`
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmCreatePaper.java:34,94`

- [ ] **Step 1: 删除 JSP 中"分配班级"下拉框**

在 `lwmteacher_paper_create.jsp` 中，删除包含"分配班级"下拉框的整个 `<div class="form-group">` 块（第 74-84 行）。

将：
```jsp
            <div class="form-group">
                <label>分配班级</label>
                <select name="lwmclassname" required>
                    <option value="">请选择</option>
                    <% java.util.Set<String> seenClasses = new java.util.HashSet<>();
                    for (lwmstudentcourseteacher c : courses) {
                        if (seenClasses.add(c.getLwmclassname())) { %>
                        <option value="<%= c.getLwmclassname() %>"><%= c.getLwmclassname() %></option>
                    <% } } %>
                </select>
            </div>
```

替换为空（即删除该 form-group）。

注意：这个 `<div class="form-group">` 在 `<div class="inline-group">` 内部，删除后科目下拉框将独占该行。将整个 `inline-group` 简化为单个 form-group：

将第 62-85 行的：
```jsp
        <div class="inline-group">
            <div class="form-group">
                <label>所属科目</label>
                <select name="lwmsubjectid" id="subjectSelect" required>
                    <option value="">请选择</option>
                    <% java.util.Set<Integer> seenSubjs = new java.util.HashSet<>();
                    for (lwmstudentcourseteacher c : courses) {
                        if (seenSubjs.add(c.getLwmsubjectid())) { %>
                        <option value="<%= c.getLwmsubjectid() %>"><%= c.getLwmsubjectname() %></option>
                    <% } } %>
                </select>
            </div>
            <div class="form-group">
                <label>分配班级</label>
                ...班级下拉框...
            </div>
        </div>
```

替换为：
```jsp
        <div class="form-group">
            <label>所属科目</label>
            <select name="lwmsubjectid" id="subjectSelect" required>
                <option value="">请选择</option>
                <% java.util.Set<Integer> seenSubjs = new java.util.HashSet<>();
                for (lwmstudentcourseteacher c : courses) {
                    if (seenSubjs.add(c.getLwmsubjectid())) { %>
                    <option value="<%= c.getLwmsubjectid() %>"><%= c.getLwmsubjectname() %></option>
                <% } } %>
            </select>
        </div>
```

- [ ] **Step 2: 修改 Servlet 中 lwmclassname 设为空字符串**

在 `lwmCreatePaper.java` 第 34 行，将：
```java
        String classname = request.getParameter("lwmclassname");
```
改为：
```java
        String classname = "";
```

第 94 行 `paper.setLwmclassname(classname);` 保持不变，现在传入空字符串。

- [ ] **Step 3: 验证编译**

```bash
cd D:/Java/IdeaProjects/lwmexam && mvn compile -q
```
Expected: BUILD SUCCESS

---

### Task 2: 新增发布 Servlet

**Files:**
- Create: `src/main/java/com/example/lwmexam/action/lwmexam/lwmPublishPaper.java`

- [ ] **Step 1: 创建 lwmPublishPaper.java**

```java
package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmpaperDAO;
import com.example.lwmexam.entity.lwmexam.lwmExamPaper;
import com.example.lwmexam.entity.lwmexam.lwmTeacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@WebServlet("/lwmPublishPaper")
public class lwmPublishPaper extends HttpServlet {

    // GET: Load the publish page with paper info and class checkboxes
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        if (teacher == null) { response.sendRedirect("login.jsp"); return; }

        int paperId = Integer.parseInt(request.getParameter("id"));
        lwmpaperDAO dao = new lwmpaperDAO();
        lwmExamPaper paper = dao.lwmQueryPaperById(paperId);
        if (paper == null || paper.getLwmteacherid() != teacher.getLwmteacherid()) {
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<script>alert('试卷不存在或无权操作');history.go(-1);</script>");
            return;
        }

        // Load teacher's assigned classes from lwmstudentcourseteacher
        List<String> teacherClasses = new ArrayList<>();
        // Parse already-published classes
        Set<String> publishedClasses = new HashSet<>();
        String currentClasses = paper.getLwmclassname();
        if (currentClasses != null && !currentClasses.isEmpty()) {
            publishedClasses.addAll(Arrays.asList(currentClasses.split(",")));
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8",
                "root", "123456");
            PreparedStatement pstmt = conn.prepareStatement(
                "SELECT DISTINCT lwmclassname FROM lwmstudentcourseteacher WHERE lwmteacherid = ? ORDER BY lwmclassname");
            pstmt.setInt(1, teacher.getLwmteacherid());
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) teacherClasses.add(rs.getString("lwmclassname"));
            rs.close(); pstmt.close(); conn.close();
        } catch (Exception e) { e.printStackTrace(); }

        request.setAttribute("paper", paper);
        request.setAttribute("teacherClasses", teacherClasses);
        request.setAttribute("publishedClasses", publishedClasses);
        request.getRequestDispatcher("lwmteacher_paper_publish.jsp").forward(request, response);
    }

    // POST: Save published classes
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        PrintWriter out = response.getWriter();
        if (teacher == null) { out.println("<script>alert('请先登录');location.href='login.jsp';</script>"); return; }

        int paperId = Integer.parseInt(request.getParameter("paperId"));
        String[] selectedClasses = request.getParameterValues("classes");
        String classname = "";
        if (selectedClasses != null && selectedClasses.length > 0) {
            classname = String.join(",", selectedClasses);
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8",
                "root", "123456");
            PreparedStatement pstmt = conn.prepareStatement(
                "UPDATE lwmexampaper SET lwmclassname = ? WHERE lwmpaperid = ? AND lwmteacherid = ?");
            pstmt.setString(1, classname);
            pstmt.setInt(2, paperId);
            pstmt.setInt(3, teacher.getLwmteacherid());
            int res = pstmt.executeUpdate();
            pstmt.close(); conn.close();
            if (res > 0) {
                out.println("<script>alert('发布成功');location.href='lwmQueryPaper';</script>");
            } else {
                out.println("<script>alert('发布失败');history.go(-1);</script>");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('发布失败');history.go(-1);</script>");
        }
    }
}
```

- [ ] **Step 2: 验证编译**

```bash
cd D:/Java/IdeaProjects/lwmexam && mvn compile -q
```
Expected: BUILD SUCCESS

---

### Task 3: 新增发布页面 JSP

**Files:**
- Create: `src/main/webapp/lwmteacher_paper_publish.jsp`

- [ ] **Step 1: 创建 lwmteacher_paper_publish.jsp**

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmExamPaper" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%
    lwmExamPaper paper = (lwmExamPaper) request.getAttribute("paper");
    List<String> teacherClasses = (List<String>) request.getAttribute("teacherClasses");
    Set<String> publishedClasses = (Set<String>) request.getAttribute("publishedClasses");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>发布试卷</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; padding:24px; }
        .container { max-width:600px; margin:0 auto; background:white; padding:32px; border-radius:12px; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        h2 { margin-bottom:8px; color:#1e293b; }
        .subtitle { color:#64748b; font-size:0.9rem; margin-bottom:24px; }
        .class-list { display:flex; flex-wrap:wrap; gap:12px; margin-bottom:24px; }
        .class-item { display:flex; align-items:center; gap:8px; padding:12px 16px; border:2px solid #e2e8f0; border-radius:8px; cursor:pointer; font-size:0.9rem; transition:all 0.2s; }
        .class-item:hover { border-color:#059669; background:#f0fdf4; }
        .class-item.selected { border-color:#059669; background:#ecfdf5; color:#059669; font-weight:600; }
        .class-item input[type="checkbox"] { display:none; }
        .btn-row { display:flex; gap:12px; justify-content:flex-end; margin-top:20px; }
        .btn { padding:10px 24px; border-radius:8px; cursor:pointer; border:none; font-size:0.9rem; text-decoration:none; }
        .btn-primary { background:#059669; color:white; }
        .btn-secondary { background:#e2e8f0; color:#475569; }
    </style>
</head>
<body>
<div class="container">
    <h2>发布试卷</h2>
    <p class="subtitle">试卷：<strong><%= paper.getLwmpapername() %></strong></p>
    <p style="color:#475569;font-weight:500;margin-bottom:12px;">选择要发布到的班级（可多选）：</p>

    <form method="post" action="lwmPublishPaper" id="publishForm">
        <input type="hidden" name="paperId" value="<%= paper.getLwmpaperid() %>">
        <div class="class-list">
            <% if (teacherClasses != null && !teacherClasses.isEmpty()) {
                for (String cls : teacherClasses) {
                    boolean checked = publishedClasses != null && publishedClasses.contains(cls); %>
                    <label class="class-item <%= checked ? "selected" : "" %>">
                        <input type="checkbox" name="classes" value="<%= cls %>" <%= checked ? "checked" : "" %> onchange="this.parentElement.classList.toggle('selected', this.checked)">
                        <%= cls %>
                    </label>
            <% } } else { %>
                <p style="color:#94a3b8;">暂无分配的班级，请先在课程安排中添加班级</p>
            <% } %>
        </div>
        <div class="btn-row">
            <a href="lwmQueryPaper" class="btn btn-secondary">取消</a>
            <button type="submit" class="btn btn-primary">确认发布</button>
        </div>
    </form>
</div>
</body>
</html>
```

---

### Task 4: 试卷管理列表 — 添加发布按钮和状态

**Files:**
- Modify: `src/main/webapp/lwmteacher_paper_list.jsp`

- [ ] **Step 1: 修改操作列，添加发布/修改发布按钮**

在 `lwmteacher_paper_list.jsp` 的操作列（第 88-91 行），在编辑和删除按钮之前添加发布按钮。

将：
```jsp
                        <td>
                            <a href="lwmUpdatePaper?id=<%= p.getLwmpaperid() %>" class="btn-edit">编辑</a>
                            <a href="lwmDeletePaper?id=<%= p.getLwmpaperid() %>" class="btn-danger" onclick="return confirm('确定删除该试卷？')">删除</a>
                        </td>
```

替换为：
```jsp
                        <td>
                            <% String cls = p.getLwmclassname();
                               boolean published = cls != null && !cls.isEmpty(); %>
                            <a href="lwmPublishPaper?id=<%= p.getLwmpaperid() %>" class="btn-edit" style="background:<%= published ? "#f59e0b" : "#059669" %>;"><%= published ? "修改发布" : "发布" %></a>
                            <a href="lwmUpdatePaper?id=<%= p.getLwmpaperid() %>" class="btn-edit">编辑</a>
                            <a href="lwmDeletePaper?id=<%= p.getLwmpaperid() %>" class="btn-danger" onclick="return confirm('确定删除该试卷？')">删除</a>
                        </td>
```

同时在"班级"列显示已发布班级（第 85 行），将：
```jsp
                        <td><%= p.getLwmclassname() %></td>
```
替换为：
```jsp
                        <td><%= (p.getLwmclassname() != null && !p.getLwmclassname().isEmpty()) ? p.getLwmclassname() : "<span style='color:#94a3b8;'>未发布</span>" %></td>
```

---

### Task 5: DAO — 移除 UPDATE 中的 lwmclassname

**Files:**
- Modify: `src/main/java/com/example/lwmexam/dao/lwmexam/lwmpaperDAO.java:136`

- [ ] **Step 1: 修改 lwmUpdatePaper SQL**

在 `lwmpaperDAO.java` 第 136 行，将：
```java
            "UPDATE lwmexampaper SET lwmpapername=?,lwmsubjectid=?,lwmexamtime=?,lwmexamsore=?,lwmstarttime=?,lwmendtime=?,lwmclassname=? WHERE lwmpaperid=?",
```
改为：
```java
            "UPDATE lwmexampaper SET lwmpapername=?,lwmsubjectid=?,lwmexamtime=?,lwmexamsore=?,lwmstarttime=?,lwmendtime=? WHERE lwmpaperid=?",
```

- [ ] **Step 2: 修改对应的参数数组**

将同一方法中（约第 137 行）的参数数组：
```java
            new Object[]{p.getLwmpapername(),p.getLwmsubjectid(),p.getLwmexamtime(),p.getLwmexamsore(),p.getLwmstarttime(),p.getLwmendtime(),p.getLwmclassname(),p.getLwmpaperid()});
```
改为：
```java
            new Object[]{p.getLwmpapername(),p.getLwmsubjectid(),p.getLwmexamtime(),p.getLwmexamsore(),p.getLwmstarttime(),p.getLwmendtime(),p.getLwmpaperid()});
```

- [ ] **Step 3: 验证编译**

```bash
cd D:/Java/IdeaProjects/lwmexam && mvn compile -q
```
Expected: BUILD SUCCESS

---

### Task 6: lwmUpdatePaper — 移除班级更新逻辑

**Files:**
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmUpdatePaper.java:106,121`

- [ ] **Step 1: 移除两处 lwmclassname 设置**

在 `lwmUpdatePaper.java` 中删除两处 `setLwmclassname` 调用：

删除第 106 行：
```java
                p.setLwmclassname(request.getParameter("lwmclassname"));
```

删除第 121 行：
```java
        paper.setLwmclassname(request.getParameter("lwmclassname"));
```

- [ ] **Step 2: 验证编译**

```bash
cd D:/Java/IdeaProjects/lwmexam && mvn compile -q
```
Expected: BUILD SUCCESS

---

### Task 7: 编辑页面 — 移除班级编辑区域

**Files:**
- Modify: `src/main/webapp/lwmteacher_paper_edit.jsp:81-91`

- [ ] **Step 1: 移除班级编辑区域**

在 `lwmteacher_paper_edit.jsp` 中，找到"分配班级"所在的 `<div class="form-group">` 块（约第 81-91 行），将其删除。

当前代码：
```jsp
            <div class="form-group">
                <label>分配班级</label>
                <% if (hasSubmit) { %>
                    <input type="text" value="<%= paper.getLwmclassname() %>" readonly style="background:#f8fafc;">
                    <input type="hidden" name="lwmclassname" value="<%= paper.getLwmclassname() %>">
                <% } else { %>
                    <select name="lwmclassname" required>
                        <% java.util.Set<String> seenClasses = new java.util.HashSet<>();
                        for (lwmstudentcourseteacher c : courses) {
                            if (seenClasses.add(c.getLwmclassname())) { %>
                                <option value="<%= c.getLwmclassname() %>" <%= paper.getLwmclassname().equals(c.getLwmclassname()) ? "selected" : "" %>><%= c.getLwmclassname() %></option>
                        <% } } %>
                    </select>
                <% } %>
            </div>
```

删除整个这个 `<div class="form-group">` 块。注意它位于 `inline-group` 内部——如果该 `inline-group` 只剩下一个子元素，将 `inline-group` 也移除，使"所属科目"成为一个独立的 `form-group`。

**注意：** 需要同时调整所属科目的 `inline-group` 包装。查看完整的 inline-group 结构（大约第 70-91 行）：

```jsp
        <div class="inline-group">
            <div class="form-group">
                <label>所属科目</label>
                ...科目下拉框...
            </div>
            <div class="form-group">
                <label>分配班级</label>
                ...班级下拉框（要删除）...
            </div>
        </div>
```

整体替换为：
```jsp
        <div class="form-group">
            <label>所属科目</label>
            ...科目下拉框（保持不变）...
        </div>
```

即移除 `inline-group` 包装和班级 form-group，科目成为独立 form-group。

- [ ] **Step 2: 验证编译**

```bash
cd D:/Java/IdeaProjects/lwmexam && mvn compile -q
```
Expected: BUILD SUCCESS

---

### Task 8: 学生端 — FIND_IN_SET 查询

**Files:**
- Modify: `src/main/webapp/lwmstudent_main.jsp:23`

- [ ] **Step 1: 修改学生端 SQL 查询**

在 `lwmstudent_main.jsp` 第 23 行，将：
```jsp
            "WHERE p.lwmclassname = ? " +
```
改为：
```jsp
            "WHERE FIND_IN_SET(?, p.lwmclassname) " +
```

---

### Task 9: 试卷管理筛选 — LIKE 模糊匹配

**Files:**
- Modify: `src/main/java/com/example/lwmexam/dao/lwmexam/lwmpaperDAO.java:71`

- [ ] **Step 1: 修改班级筛选 SQL**

在 `lwmpaperDAO.java` 第 71 行的 `lwmQueryByTeacherWithFilters` 方法中，将：
```java
            sql.append(" AND p.lwmclassname = ?");
```
改为：
```java
            sql.append(" AND p.lwmclassname LIKE CONCAT('%', ?, '%')");
```

---

### Task 10: 验证所有变更

**Files:**
- All modified files

- [ ] **Step 1: 编译项目**

```bash
cd D:/Java/IdeaProjects/lwmexam && mvn compile -q
```
Expected: BUILD SUCCESS

- [ ] **Step 2: 检查无遗漏的 lwmclassname 写入**

```bash
cd D:/Java/IdeaProjects/lwmexam && grep -rn "setLwmclassname\|lwmclassname.*request.getParameter" src/main/java/com/example/lwmexam/action/lwmexam/lwmCreatePaper.java src/main/java/com/example/lwmexam/action/lwmexam/lwmUpdatePaper.java
```
Expected: 只有 `lwmCreatePaper.java` 中的 `paper.setLwmclassname(classname);`（其中 classname 现在是空字符串 ""），`lwmUpdatePaper.java` 中不应有 setLwmclassname 调用。

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "feat: multi-class publish for exam papers - remove class from create, add publish flow with multi-select"
```
