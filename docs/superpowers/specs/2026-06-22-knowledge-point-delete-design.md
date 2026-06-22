# Knowledge Point Delete in Question Add/Edit Page

**Date:** 2026-06-22
**Status:** Approved

## Summary

教师端题库管理中，添加和修改试题时的"关联知识点"区域，支持直接删除历史上添加的知识点。

## Files to Modify

| File | Change |
|------|--------|
| `src/main/java/com/example/lwmexam/action/lwmexam/lwmManageKnowledgePoint.java` | 新增 `delete` action |
| `src/main/java/com/example/lwmexam/dao/lwmexam/lwmKnowledgePointDAO.java` | 新增 `countQuestionsByKP` 方法 |
| `src/main/webapp/lwmteacher_question_add.jsp` | 知识点列表每项加删除按钮 + JS 函数 |

## Backend Changes

### lwmKnowledgePointDAO — 新增方法

```java
public int countQuestionsByKP(int kpId)
```

查询 `lwmquestionknowledge` 表中 `lwmkpid = ?` 的记录数。

### lwmManageKnowledgePoint — 新增 delete action

在 `doPost` 中增加分支：

```
action = "delete"
  参数: kpid (int)
  1. 验证 teacher session 登录
  2. countQuestionsByKP(kpid) > 0 → 返回 {"success":false,"message":"该知识点已被试题使用，无法删除"}
  3. delete(kpid) → 返回 {"success":true}
```

## Frontend Changes

### lwmteacher_question_add.jsp

在 `loadKnowledgePoints()` 渲染的 HTML 中，每个知识点 label 内追加删除 span：

```html
<span onclick="deleteKP(kpid)" style="cursor:pointer;color:#ef4444;margin-left:6px;" title="删除知识点">×</span>
```

新增 JS 函数：

```javascript
function deleteKP(kpId) {
    if (!confirm('确定删除该知识点？删除后不可恢复')) return;
    fetch('lwmManageKnowledgePoint', {
        method: 'POST',
        headers: {'Content-Type':'application/x-www-form-urlencoded'},
        body: 'action=delete&kpid=' + encodeURIComponent(kpId)
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            existingKpIds = existingKpIds.filter(id => id !== kpId);
            loadKnowledgePoints();
        } else {
            alert(data.message || '删除失败');
        }
    })
    .catch(() => alert('网络错误，删除失败'));
}
```

## Constraints

- 已被试题引用的知识点不允许删除（提示用户）
- 只有登录教师可操作（复用现有 session 检查）
- 删除前前端 confirm 确认

## Data Flow

```
用户点 × → confirm确认 → fetch POST delete → servlet:
  → countQuestionsByKP > 0 → 返回错误消息，前端alert
  → countQuestionsByKP = 0 → DAO.delete() → 返回成功，前端刷新列表
```
