# Exam Answer Sheet Sidebar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a sticky answer-sheet sidebar to the left of the exam page with per-section question-number buttons that scroll to questions and reflect answer status in real time.

**Architecture:** Pure frontend change to `lwmstudent_take_exam.jsp`. Container switches to flex row; sidebar is a sticky-positioned card on the left. JSP generates sidebar HTML by iterating questions grouped by type. Vanilla JS handles scroll-to, color updates via event delegation, and collapse/expand toggle.

**Tech Stack:** JSP + vanilla CSS/JS, no libraries. Single file modified.

---

### Task 1: Update container layout + add all sidebar CSS

**Files:** Modify `src/main/webapp/lwmstudent_take_exam.jsp:43,59`

- [ ] **Step 1: Change `.container` to flex row layout**

Replace line 43:
```css
.container { max-width:900px; margin:0 auto; }
```
with:
```css
.container { max-width:1080px; margin:0 auto; display:flex; gap:20px; align-items:flex-start; }
.main-area { flex:1; min-width:0; }
```

This gives space for the 210px sidebar on the left and keeps the questions area flexible.

- [ ] **Step 2: Append sidebar CSS before `</style>` on line 60**

Insert before `</style>` (line 60):

```css
.sidebar { width:210px; flex-shrink:0; background:white; border-radius:12px; box-shadow:0 1px 3px rgba(0,0,0,0.08); position:sticky; top:24px; max-height:calc(100vh - 48px); overflow-y:auto; transition:width 0.3s ease; }
.sidebar-header { background:linear-gradient(135deg,#f59e0b,#d97706); color:white; padding:10px 14px; border-radius:12px 12px 0 0; display:flex; justify-content:space-between; align-items:center; font-size:0.9rem; font-weight:600; }
.sidebar-header button { background:none; border:none; color:white; font-size:1.2rem; cursor:pointer; padding:0 4px; line-height:1; }
.sidebar-body { padding:10px 14px 14px 14px; }
.sidebar-section-label { font-size:0.75rem; color:#94a3b8; margin:8px 0 4px 0; }
.sidebar-section-label:first-child { margin-top:0; }
.sidebar-btn-grid { display:flex; flex-wrap:wrap; gap:6px; }
.sidebar-btn { width:28px; height:28px; border-radius:8px; border:none; background:#e2e8f0; color:#64748b; font-size:0.8rem; cursor:pointer; display:inline-flex; align-items:center; justify-content:center; transition:transform 0.15s,background 0.2s; }
.sidebar-btn:hover { transform:scale(1.1); }
.sidebar-btn.answered { background:#22c55e; color:white; }
.sidebar.collapsed { width:40px; }
.sidebar.collapsed .sidebar-body { display:none; }
.sidebar.collapsed .sidebar-header { border-radius:12px; flex-direction:column; gap:6px; padding:10px 8px; }
.sidebar.collapsed .sidebar-header span { writing-mode:vertical-rl; font-size:0.8rem; }
```

- [ ] **Step 3: Verify layout**

After these CSS changes, the page still renders correctly — the container now expects a flex row. At this point the sidebar HTML doesn't exist yet so the main area fills the full width naturally (flex:1). No visual change yet.

- [ ] **Step 4: Commit**

```bash
git add src/main/webapp/lwmstudent_take_exam.jsp
git commit -m "style: add flex container and sidebar CSS to exam page"
```

---

### Task 2: Add question card IDs and wrap main content

**Files:** Modify `src/main/webapp/lwmstudent_take_exam.jsp:63,70,95,130`

- [ ] **Step 1: Wrap header + form in `.main-area` div**

After line 63 (`<div class="container">`), insert:
```html
<div class="main-area">
```

Before line 130 (`</div>` that closes `.container` — but we need to find the right spot). The `</div>` on line 130 closes `.container`. Insert `</div>` to close `.main-area` just before it. So change line 129-130 area.

Actually, looking at the structure:
- Line 63: `<div class="container">`
- Line 64-69: header
- Line 71-129: form
- Line 130: `</div>` (closes .container)

So: insert `<div class="main-area">` after line 63, and insert `</div>` before line 130.

After line 63 (`<div class="container">`), insert opening tag:
```html
<div class="main-area">
```

Before `</div>` on line 130, close it:
```html
</div><!-- .main-area -->
```

- [ ] **Step 2: Add id to each question card**

On line 95, change:
```html
<div class="card">
```
to:
```html
<div class="card" id="question_<%= q.getLwmquestionid() %>">
```

- [ ] **Step 3: Commit**

```bash
git add src/main/webapp/lwmstudent_take_exam.jsp
git commit -m "feat: add question card IDs and main-area wrapper for sidebar layout"
```

---

### Task 3: Generate sidebar HTML

**Files:** Modify `src/main/webapp/lwmstudent_take_exam.jsp:63-64`

Insert sidebar HTML after the container opening and before `.main-area`. The sidebar iterates questions again, grouped by type, with per-section numbering.

- [ ] **Step 1: Insert sidebar HTML between container and main-area**

After `<div class="container">` (line 63), insert the sidebar div BEFORE the `<div class="main-area">` from Task 2:

```html
<div class="sidebar" id="answerSidebar">
    <div class="sidebar-header">
        <span>答题卡</span>
        <button onclick="toggleSidebar()" id="sidebarToggleBtn" title="收起答题卡">&minus;</button>
    </div>
    <div class="sidebar-body">
        <%
        if (questions != null) {
            String sidebarType = "";
            int sidebarNum = 0;
            boolean firstSection = true;
            for (lwmExamQuestion q : questions) {
                String type = q.getLwmquestiontype();
                if (!type.equals(sidebarType)) {
                    if (!firstSection) { %></div><% }
                    firstSection = false;
                    sidebarType = type;
                    sidebarNum = 1;
        %>
                    <div class="sidebar-section-label"><%= sidebarType %></div>
                    <div class="sidebar-btn-grid">
        <%      }
                int qid = q.getLwmquestionid();
                boolean initAnswered = false;
                if (draftAnswers != null) {
                    String saved = draftAnswers.get(qid);
                    if (saved != null && !saved.trim().isEmpty()) initAnswered = true;
                }
        %>
                <button class="sidebar-btn<%= initAnswered ? " answered" : "" %>" data-qid="<%= qid %>" onclick="scrollToQuestion(<%= qid %>)"><%= sidebarNum++ %></button>
        <%  }
            if (!firstSection) { %></div><% }
        } %>
    </div>
</div>
```

**JSP logic:** Uses `firstSection` flag to control div closing. On first section, skip closing (no prior grid to close). On subsequent sections, close the previous `sidebar-btn-grid` div before opening a new one. After loop, close the last grid if any sections were rendered.

- [ ] **Step 2: Verify sidebar HTML by deploying and viewing page source**

Deploy to Tomcat, open the exam page, view page source. Verify:
- Sidebar div exists inside `.container` before `.main-area`
- All question buttons have correct `data-qid` values
- Section labels appear in correct order
- Per-section numbering starts at 1 for each type
- Draft-restored questions have `.answered` class

- [ ] **Step 3: Commit**

```bash
git add src/main/webapp/lwmstudent_take_exam.jsp
git commit -m "feat: generate answer sheet sidebar HTML with question-number buttons"
```

---

### Task 4: Add sidebar JavaScript

**Files:** Modify `src/main/webapp/lwmstudent_take_exam.jsp:200-201`

- [ ] **Step 1: Add sidebar JS functions before `updateTimer()` call**

Insert before line 200 (`updateTimer();`):

```javascript
// --- Sidebar ---
var sidebarCollapsed = false;

function scrollToQuestion(qid) {
    var el = document.getElementById('question_' + qid);
    if (el) el.scrollIntoView({ behavior: 'smooth', block: 'center' });
}

function toggleSidebar() {
    var sidebar = document.getElementById('answerSidebar');
    var btn = document.getElementById('sidebarToggleBtn');
    sidebarCollapsed = !sidebarCollapsed;
    if (sidebarCollapsed) {
        sidebar.classList.add('collapsed');
        btn.innerHTML = '+';
        btn.title = '展开答题卡';
    } else {
        sidebar.classList.remove('collapsed');
        btn.innerHTML = '&minus;';
        btn.title = '收起答题卡';
    }
}

function updateSidebarButton(qid) {
    var btn = document.querySelector('.sidebar-btn[data-qid="' + qid + '"]');
    if (!btn) return;
    var card = document.getElementById('question_' + qid);
    if (!card) return;
    var radios = card.querySelectorAll('input[type="radio"]');
    var checkboxes = card.querySelectorAll('input[type="checkbox"]');
    var textarea = card.querySelector('textarea');
    var answered = false;
    if (radios.length > 0) {
        for (var i = 0; i < radios.length; i++) { if (radios[i].checked) { answered = true; break; } }
    } else if (checkboxes.length > 0) {
        for (var i = 0; i < checkboxes.length; i++) { if (checkboxes[i].checked) { answered = true; break; } }
    } else if (textarea) {
        answered = textarea.value.trim() !== '';
    }
    if (answered) {
        btn.classList.add('answered');
    } else {
        btn.classList.remove('answered');
    }
}

function initSidebar() {
    var cards = document.querySelectorAll('.card');
    for (var i = 0; i < cards.length; i++) {
        var card = cards[i];
        var id = card.id;
        if (!id || id.indexOf('question_') !== 0) continue;
        var qid = parseInt(id.replace('question_', ''));
        updateSidebarButton(qid);
    }
}

// Event delegation: listen on form for all input/textarea changes
document.getElementById('examForm').addEventListener('change', function(e) {
    var target = e.target;
    if (target.tagName === 'INPUT' || target.tagName === 'TEXTAREA') {
        var card = target.closest('.card');
        if (card && card.id && card.id.indexOf('question_') === 0) {
            var qid = parseInt(card.id.replace('question_', ''));
            updateSidebarButton(qid);
        }
    }
});

document.getElementById('examForm').addEventListener('input', function(e) {
    if (e.target.tagName === 'TEXTAREA') {
        var card = e.target.closest('.card');
        if (card && card.id && card.id.indexOf('question_') === 0) {
            var qid = parseInt(card.id.replace('question_', ''));
            updateSidebarButton(qid);
        }
    }
});

initSidebar();
```

- [ ] **Step 2: Verify sidebar interactions by testing in browser**

Open the exam page and test:
1. **Scroll to question**: Click any sidebar button → page smooth-scrolls to that question card, it's centered in viewport
2. **Answer → color update**: Select a radio/checkbox in any question → corresponding sidebar button turns green immediately
3. **Unselect → gray again**: Switch radio selection in a single-choice question → button stays green (still answered). For multi-select, uncheck all → button goes gray
4. **Essay text**: Type in a textarea → sidebar button turns green. Clear textarea → button goes gray
5. **Collapse/expand**: Click minus button → sidebar shrinks to ~40px, shows vertical label and +. Click + → sidebar expands back
6. **Draft restore**: Page loads with draft answers → corresponding buttons already green (verified in Task 3 step 2)
7. **Collapsed state update**: Collapse sidebar, answer a question, expand sidebar → button color is correct

- [ ] **Step 3: Commit**

```bash
git add src/main/webapp/lwmstudent_take_exam.jsp
git commit -m "feat: add sidebar JS for scroll, color update, and collapse toggle"
```

---

### Task 5: Final integration verification

**Files:** `src/main/webapp/lwmstudent_take_exam.jsp`

- [ ] **Step 1: Full walkthrough test**

Deploy and test the complete flow:
1. Open exam page → sidebar visible on left, above questions
2. Check draft-restored answers → correct buttons green
3. Answer a new question → button turns green in real time
4. Click a green/gray button → scrolls to that question
5. Collapse sidebar → compact vertical tab
6. Expand sidebar → all buttons show correct colors
7. Submit exam → form works normally
8. Resize browser to 768px width → sidebar still functional, main area scrolls

- [ ] **Step 2: Verify no regressions**

- Countdown timer still works
- Save draft button still works
- Submit with unanswered warning still works
- Auto-submit on timeout still works
- All question types render correctly

- [ ] **Step 3: Commit**

```bash
git add src/main/webapp/lwmstudent_take_exam.jsp
git commit -m "test: confirm sidebar integration with full exam flow"
```

---

### Task 6: Final commit squashing (if desired)

All changes are in a single file across 4 commits. If you prefer fewer commits, squash before pushing.
