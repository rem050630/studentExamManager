# Prevent Deletion of Questions Used in Exam Papers — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prevent deletion of questions that are referenced by any exam paper, and show the user which papers block the deletion.

**Architecture:** Add a DAO method to query papers by question ID via the `lwmpaperquestion` junction table, then add a pre-delete guard in the Action servlet. Follows the existing pattern in `lwmDeletePaper` (check → alert and return if blocked, otherwise proceed).

**Tech Stack:** Java Servlet, JDBC (MysqlConn helper), MySQL

## Global Constraints

- Follow existing code patterns: `lwmpaperDAO` uses `lwmQuerySomePaper` private helper for all SELECT queries; Actions use `PrintWriter` for script-based alerts
- Delete button and `confirm()` dialog in JSP remain unchanged as first line of defense
- Alert message must list specific paper names that block deletion

---

### Task 1: Add `getPapersByQuestionId` method to `lwmpaperDAO`

**Files:**
- Modify: `src/main/java/com/example/lwmexam/dao/lwmexam/lwmpaperDAO.java`

**Interfaces:**
- Produces: `public List<lwmExamPaper> getPapersByQuestionId(int questionId)` — returns all papers that reference the given question via `lwmpaperquestion` junction table, using the existing `lwmQuerySomePaper` private helper

- [ ] **Step 1: Add the method to `lwmpaperDAO.java`**

Insert the method after `hasSubmitRecord` (end of file, before the closing `}` of the class):

```java
    // Get all papers that reference a given question.
    public List<lwmExamPaper> getPapersByQuestionId(int questionId) {
        return lwmQuerySomePaper(
            "SELECT p.* FROM lwmexampaper p " +
            "INNER JOIN lwmpaperquestion pq ON p.lwmpaperid = pq.lwmpaperid " +
            "WHERE pq.lwmquestionid = ?",
            new Object[]{questionId});
    }
```

- [ ] **Step 2: Verify the file compiles**

Run: `cd D:/Java/IdeaProjects/lwmexam && mvn compile -q`

Expected: BUILD SUCCESS

- [ ] **Step 3: Commit**

```bash
git add src/main/java/com/example/lwmexam/dao/lwmexam/lwmpaperDAO.java
git commit -m "feat: add getPapersByQuestionId to lwmpaperDAO"
```

---

### Task 2: Add pre-delete guard in `lwmDeleteQuestion` Action

**Files:**
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmDeleteQuestion.java`

**Interfaces:**
- Consumes: `lwmpaperDAO.getPapersByQuestionId(int)` from Task 1

- [ ] **Step 1: Add the import and pre-delete check to `lwmDeleteQuestion.java`**

Replace the file content:

```java
package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmpaperDAO;
import com.example.lwmexam.dao.lwmexam.lwmquestionDAO;
import com.example.lwmexam.entity.lwmexam.lwmExamPaper;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/lwmDeleteQuestion")
public class lwmDeleteQuestion extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        int id = Integer.parseInt(request.getParameter("id"));

        // Check if this question is referenced by any papers.
        lwmpaperDAO paperDAO = new lwmpaperDAO();
        List<lwmExamPaper> papers = paperDAO.getPapersByQuestionId(id);
        if (papers != null && !papers.isEmpty()) {
            StringBuilder sb = new StringBuilder("该试题已被以下试卷引用，无法删除：");
            for (lwmExamPaper p : papers) {
                sb.append("\\n- ").append(p.getLwmpapername());
            }
            sb.append("\\n\\n请先从对应试卷中移除该试题后再删除。");
            out.println("<script>alert('" + sb.toString() + "');history.go(-1);</script>");
            return;
        }

        lwmquestionDAO dao = new lwmquestionDAO();
        int res = dao.lwmDeleteQuestion(id);
        if (res > 0) {
            out.println("<script>alert('删除成功');location.href='lwmQueryQuestion';</script>");
        } else {
            out.println("<script>alert('删除失败');history.go(-1);</script>");
        }
    }
}
```

- [ ] **Step 2: Verify the file compiles**

Run: `cd D:/Java/IdeaProjects/lwmexam && mvn compile -q`

Expected: BUILD SUCCESS

- [ ] **Step 3: Commit**

```bash
git add src/main/java/com/example/lwmexam/action/lwmexam/lwmDeleteQuestion.java
git commit -m "feat: prevent deletion of questions referenced by exam papers"
```
