# Score Analysis Class Query & Class Compare Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix class dropdown showing comma-grouped names, fix subject filter on class compare page, and enable re-compare after first comparison.

**Architecture:** Three small, independent fixes in two files. The Java action fix (P1) splits composite class names at the data source. The JSP fixes (P2, P3) improve client-side filtering reliability and reset render state for repeated comparisons.

**Tech Stack:** Java Servlet, JSP, JavaScript, ECharts

---

### Task 1: Split comma-separated class names in score analysis action

**Files:**
- Modify: `src/main/java/com/example/lwmexam/action/lwmexam/lwmScoreAnalysisAction.java:79-84`

- [ ] **Step 1: Replace the class list loading logic**

Replace lines 79-84:

```java
// Load distinct class names for this teacher
rs = db.doQuery(
    "SELECT DISTINCT lwmclassname FROM lwmexampaper WHERE lwmteacherid = ? AND lwmclassname IS NOT NULL AND lwmclassname != '' ORDER BY lwmclassname",
    new Object[]{teacher.getLwmteacherid()});
while (rs.next()) classList.add(rs.getString("lwmclassname"));
rs.close();
```

with:

```java
// Load distinct class names for this teacher, splitting comma-separated values
rs = db.doQuery(
    "SELECT DISTINCT lwmclassname FROM lwmexampaper WHERE lwmteacherid = ? AND lwmclassname IS NOT NULL AND lwmclassname != '' ORDER BY lwmclassname",
    new Object[]{teacher.getLwmteacherid()});
java.util.LinkedHashSet<String> classSet = new java.util.LinkedHashSet<>();
while (rs.next()) {
    String raw = rs.getString("lwmclassname");
    if (raw != null && !raw.isEmpty()) {
        String[] parts = raw.split(",");
        for (String part : parts) {
            String trimmed = part.trim();
            if (!trimmed.isEmpty()) {
                classSet.add(trimmed);
            }
        }
    }
}
rs.close();
classList.addAll(classSet);
```

`LinkedHashSet` preserves insertion order while deduplicating. `import java.util.LinkedHashSet` is already covered (part of `java.util` but this is a fully qualified reference used inline — no import change needed).

- [ ] **Step 2: Commit**

```bash
git add src/main/java/com/example/lwmexam/action/lwmexam/lwmScoreAnalysisAction.java
git commit -m "fix: split comma-separated class names in score analysis class dropdown"
```

---

### Task 2: Fix subject dropdown filtering on class compare page

**Files:**
- Modify: `src/main/webapp/lwmteacher_class_compare.jsp:176-196` (replace `onSubjectChange()`)
- Modify: `src/main/webapp/lwmteacher_class_compare.jsp:159-174` (add cache on load)

- [ ] **Step 1: Add paper options cache variable**

Insert after line 157 (`var kpChartInst = null;`):

```javascript
var allPaperOptions = [];
```

- [ ] **Step 2: Populate cache on page load**

In the `DOMContentLoaded` handler (lines 159-174), add at the beginning:

```javascript
window.addEventListener('DOMContentLoaded', function() {
    // Cache all paper options (skip the placeholder at index 0)
    var paperSel = document.getElementById('paperSelect');
    allPaperOptions = [];
    for (var i = 1; i < paperSel.options.length; i++) {
        allPaperOptions.push({
            value: paperSel.options[i].value,
            text: paperSel.options[i].text,
            subject: paperSel.options[i].getAttribute('data-subject'),
            classes: paperSel.options[i].getAttribute('data-classes')
        });
    }
    onSubjectChange();
    if (paperSel.value) {
        onPaperChange();
    }
    <% if (selectedPaperId != null && !selectedPaperId.isEmpty()) { %>
        setTimeout(function() {
            var cb = document.querySelectorAll('#classCheckboxes input[type="checkbox"]:checked');
            if (cb.length >= 2) {
                startCompare();
            }
        }, 300);
    <% } %>
});
```

- [ ] **Step 3: Replace `onSubjectChange()` with rebuild-based version**

Replace lines 176-196:

```javascript
function onSubjectChange() {
    var subId = document.getElementById('subjectSelect').value;
    var paperSel = document.getElementById('paperSelect');
    var currentVal = paperSel.value;

    // Clear dropdown
    paperSel.innerHTML = '';

    // Add placeholder
    var placeholder = document.createElement('option');
    placeholder.value = '';
    placeholder.textContent = '-- 请选择试卷 --';
    paperSel.appendChild(placeholder);

    // Re-add matching options from cache
    var foundCurrent = false;
    for (var i = 0; i < allPaperOptions.length; i++) {
        var opt = allPaperOptions[i];
        if (subId === '' || opt.subject === subId) {
            var el = document.createElement('option');
            el.value = opt.value;
            el.textContent = opt.text;
            el.setAttribute('data-subject', opt.subject);
            el.setAttribute('data-classes', opt.classes);
            if (opt.value === currentVal) {
                el.selected = true;
                foundCurrent = true;
            }
            paperSel.appendChild(el);
        }
    }

    // If previously selected paper is no longer in list, reset to placeholder
    if (!foundCurrent) {
        paperSel.selectedIndex = 0;
    }

    onPaperChange();
}
```

- [ ] **Step 4: Commit**

```bash
git add src/main/webapp/lwmteacher_class_compare.jsp
git commit -m "fix: rebuild paper dropdown options on subject change in class compare"
```

---

### Task 3: Enable re-compare after first comparison

**Files:**
- Modify: `src/main/webapp/lwmteacher_class_compare.jsp:258-293` (replace `startCompare()`)

- [ ] **Step 1: Replace `startCompare()` with version that resets render state**

Replace lines 258-293:

```javascript
function startCompare() {
    var paperId = document.getElementById('paperSelect').value;
    var classes = getSelectedClasses();
    if (!paperId || classes.length < 2) {
        alert('请选择试卷和至少2个班级');
        return;
    }
    classNames = classes;
    document.getElementById('compareBtn').disabled = true;
    document.getElementById('compareBtn').textContent = '加载中...';

    var url = 'lwmScoreAnalysis?action=compare&paperid=' + encodeURIComponent(paperId) +
              '&classnames=' + encodeURIComponent(classes.join(','));

    fetch(url)
        .then(function(r) { return r.json(); })
        .then(function(data) {
            document.getElementById('compareBtn').disabled = false;
            document.getElementById('compareBtn').textContent = '开始对比';

            // Reset render flags so re-compare re-renders everything
            coreMetricsRendered = false;
            distRendered = false;
            kpLoaded = false;

            // Dispose old chart instances
            if (coreChartInst) { coreChartInst.dispose(); coreChartInst = null; }
            if (distChartInst) { distChartInst.dispose(); distChartInst = null; }
            if (kpChartInst) { kpChartInst.dispose(); kpChartInst = null; }

            // Clear old table content
            document.getElementById('coreTable').innerHTML = '';
            document.getElementById('distChart').innerHTML = '';
            document.getElementById('kpChart').innerHTML = '';
            document.getElementById('kpChart').style.display = 'block';
            document.getElementById('kpEmpty').style.display = 'none';
            document.getElementById('kpLoading').style.display = 'none';

            if (!data || data.length === 0) {
                document.getElementById('tabsContainer').style.display = 'none';
                document.getElementById('noData').style.display = 'block';
                return;
            }
            compareData = data;
            document.getElementById('tabsContainer').style.display = 'block';
            document.getElementById('noData').style.display = 'none';
            renderCoreMetrics();
        })
        .catch(function() {
            document.getElementById('compareBtn').disabled = false;
            document.getElementById('compareBtn').textContent = '开始对比';
            alert('加载对比数据失败，请重试');
        });
}
```

- [ ] **Step 2: Commit**

```bash
git add src/main/webapp/lwmteacher_class_compare.jsp
git commit -m "fix: reset render state to allow re-compare in class comparison"
```

---

### Verification

Build the project and verify:
```bash
cd D:\Java\IdeaProjects\lwmexam && mvn compile -q
```

Manually test in browser:
1. Score analysis page → class dropdown shows individual class names (not comma-separated groups)
2. Class compare page → select different subjects, paper dropdown filters correctly
3. Class compare page → run compare, then click "开始对比" again, charts and tables refresh with new data
