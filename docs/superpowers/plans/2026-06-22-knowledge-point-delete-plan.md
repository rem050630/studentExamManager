# Knowledge Point Delete Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在教师端添加/编辑试题页面的关联知识点列表中，支持删除历史知识点。

**Architecture:** 在现有 `lwmManageKnowledgePoint` servlet 增加 `delete` action，DAO 增加关联检查方法，JSP 在每个知识点旁加删除按钮。删除前检查 `lwmquestionknowledge` 表，有引用则拒绝。

**Tech Stack:** Java Servlet, JDBC (MysqlConn), JavaScript fetch, JSP

---

### Task 1: DAO — 新增 countQuestionsByKP 方法

**Files:**
- Modify: `src/main/java/com/example/lwmexam/dao/lwmexam/lwmKnowledgePointDAO.java`

- [ ] **Step 1: 新增 countQuestionsByKP 方法**

在 `lwmKnowledgePointDAO.java` 中，`getKPNamesByQuestion` 方法之后添加：

```java
    // Count how many questions reference a knowledge point
    public int countQuestionsByKP(int kpId) {
        int count = 0;
        try {
            rs = db.doQuery("SELECT COUNT(*) FROM lwmquestionknowledge WHERE lwmkpid = ?", new Object[]{kpId});
            if (rs.next()) count = rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        db.close();
        return count;
    }
```

- [ ] **Step 2: 验证编译通过**

Run: `cd "D:/Java/IdeaProjects/lwmexam" && mvn compile -q`
Expected: BUILD SUCCESS

- [ ] **Step 3: Commit**

```bash
git add src/main/java/com/example/lwmexam/dao/lwmexam/lwmKnowledgePointDAO.java
git commit -m "feat: add countQuestionsByKP method to knowledge point DAO"
```

---

### Task 2: Servlet — 新增 delete action

**Files:**
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmManageKnowledgePoint.java`

- [ ] **Step 1: 在 doPost 中新增 delete 分支**

在 `lwmManageKnowledgePoint.java` 的 `doPost` 方法中，`"saveQuestionKPs".equals(action)` 分支的 `else if` 之后、最后的 `else` 之前，插入：

```java
        } else if ("delete".equals(action)) {
            String kpIdStr = request.getParameter("kpid");
            if (kpIdStr == null || kpIdStr.isEmpty()) {
                response.getWriter().print("{\"success\":false,\"message\":\"缺少kpid参数\"}");
                return;
            }
            int kpId = Integer.parseInt(kpIdStr);

            int refCount = kpDao.countQuestionsByKP(kpId);
            if (refCount > 0) {
                response.getWriter().print("{\"success\":false,\"message\":\"该知识点已被试题使用，无法删除\"}");
                return;
            }

            int result = kpDao.delete(kpId);
            if (result > 0) {
                response.getWriter().print("{\"success\":true}");
            } else {
                response.getWriter().print("{\"success\":false,\"message\":\"删除失败\"}");
            }
```

- [ ] **Step 2: 验证编译通过**

Run: `cd "D:/Java/IdeaProjects/lwmexam" && mvn compile -q`
Expected: BUILD SUCCESS

- [ ] **Step 3: Commit**

```bash
git add src/main/java/com/example/lwmexam/action/lwmexam/lwmManageKnowledgePoint.java
git commit -m "feat: add delete action to knowledge point management servlet"
```

---

### Task 3: JSP — 知识点列表新增删除按钮

**Files:**
- Modify: `src/main/webapp/lwmteacher_question_add.jsp`

- [ ] **Step 1: 在 loadKnowledgePoints 渲染的 HTML 中添加删除 span**

找到 `loadKnowledgePoints()` 函数中构建 checkbox label 的 HTML 部分（当前为）：

```javascript
html += '<label style="display:inline-block;margin-right:16px;margin-bottom:6px;font-size:0.85rem;cursor:pointer;">';
html += '<input type="checkbox" name="kpids" value="' + kp.kpid + '"' + checked + ' style="margin-right:4px;">';
html += kp.kpname;
html += '</label>';
```

修改为：

```javascript
html += '<span class="kp-item" style="display:inline-block;margin-right:16px;margin-bottom:6px;">';
html += '<label style="font-size:0.85rem;cursor:pointer;">';
html += '<input type="checkbox" name="kpids" value="' + kp.kpid + '"' + checked + ' style="margin-right:4px;">';
html += kp.kpname;
html += '</label>';
html += '<span onclick="deleteKP(' + kp.kpid + ')" style="cursor:pointer;color:#ef4444;margin-left:4px;font-size:0.85rem;" title="删除知识点">×</span>';
html += '</span>';
```

- [ ] **Step 2: 新增 deleteKP JS 函数**

在 `quickAddKP()` 函数之后添加：

```javascript
    function deleteKP(kpId) {
        if (!confirm('确定删除该知识点？删除后不可恢复')) return;
        fetch('lwmManageKnowledgePoint', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'action=delete&kpid=' + encodeURIComponent(kpId)
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                existingKpIds = existingKpIds.filter(function(id) { return id !== kpId; });
                loadKnowledgePoints();
            } else {
                alert(data.message || '删除失败');
            }
        })
        .catch(function() { alert('网络错误，删除失败'); });
    }
```

- [ ] **Step 3: Commit**

```bash
git add src/main/webapp/lwmteacher_question_add.jsp
git commit -m "feat: add delete button for knowledge points in question add/edit page"
```

---

### Verification

全部完成后，验证编译：

```bash
cd "D:/Java/IdeaProjects/lwmexam" && mvn compile -q
```

Expected: BUILD SUCCESS
