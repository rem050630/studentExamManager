# Student Page Separation Design

## Goal

Refactor the single-page `lwmstudent_main.jsp` into a frameset-based layout following the teacher-side pattern (`lwmteacher_main.jsp` + `lwmteacher_top.jsp` + `lwmteacher_left.jsp` + `lwmteacher_index.jsp`), separating the three content modules into their own pages.

## Architecture

```
lwmstudent_main.jsp (frameset)
├── topFrame    → lwmstudent_top.jsp    (top bar)
├── leftFrame   → lwmstudent_left.jsp   (sidebar navigation)
└── rightFrame  → lwmstudent_index.jsp  (exam center, default)
                  lwmstudent_paper.jsp  (my papers)
                  lwmstudent_message.jsp(student info)
```

## Files

### lwmstudent_main.jsp — Rewrite
- Replace all current content with a pure frameset structure
- `<frameset rows="88,*">` then `<frameset cols="187,*">` matching teacher layout
- Sources: `lwmteacher_main.jsp` lines 7-13

### lwmstudent_top.jsp — Rewrite (currently empty template)
- Extract `.top-bar` section from `lwmstudent_main.jsp` lines 667-680
- Logo area + student name/no + logout link (`SystemExit`, `target="_parent"`)
- Keep orange/gold gradient theme
- Add session/auth check

### lwmstudent_left.jsp — New file
- Extract `.sidebar` section from `lwmstudent_main.jsp` lines 683-688
- Navigation items with `<a target="rightFrame">`:
  - 考试中心 → `lwmstudent_index.jsp`
  - 我的试卷 → `lwmstudent_paper.jsp`
  - 我的错题本 → `lwmMistakeBook`
  - 个人信息 → `lwmstudent_message.jsp`
- Keep orange/gold active/hover styling
- Menu highlight JS adapted for frameset (no `data-module` toggling)

### lwmstudent_index.jsp — Rewrite (currently empty template)
- Extract `#examCenter` panel from `lwmstudent_main.jsp` lines 692-729
- Welcome card + stats grid + available exams list
- Include `availExams` DB query logic from lines 22-59
- Session/auth check

### lwmstudent_paper.jsp — Rewrite (currently empty template)
- Extract `#myPapers` panel from `lwmstudent_main.jsp` lines 732-769
- Exam records table
- Include `myRecords` DB query logic from lines 61-80
- Session/auth check

### lwmstudent_message.jsp — Rewrite (currently empty template)
- Extract `#myInfo` panel from `lwmstudent_main.jsp` lines 772-783
- Student info card (reads from session, no DB query needed)
- Session/auth check

## Style Strategy

- Each page carries its own `<style>` block with only the styles it needs
- Preserve the student-side orange/gold theme throughout
- Remove `module-panel` CSS, tab-switching JS, `data-module` attributes — no longer needed

## What Is Removed

- `module-panel` / `module-panel.active` CSS rules
- `#examCenter`, `#myPapers`, `#myInfo` div IDs (each becomes its own page)
- Tab-switching JavaScript (`querySelectorAll('.menu-item')` click handlers, URL `?tab=` support)
- `parseTimeStr` helper method (moves to `lwmstudent_index.jsp`)
- `myScores` list (declared but unused on line 21)
