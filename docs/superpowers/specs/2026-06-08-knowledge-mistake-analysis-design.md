# Design: Knowledge-Point Tracking, Mistake Book & Score Analysis

## Overview

Add three capabilities to lwmexam: (1) knowledge-point tagging for questions, (2) a student mistake book with mastery tracking, and (3) teacher score-analysis dashboards with cross-class comparison. Built on the existing Servlet + JSP + MySQL stack with ECharts for charts.

## Data Model

### New Tables

**lwmknowledgepoint** — Knowledge-point dictionary per subject.

| Column | Type | Notes |
|--------|------|-------|
| lwmkpid | INT PK AUTO | |
| lwmsubjectid | INT FK → lwmexamsubject | CASCADE |
| lwmkpname | VARCHAR(50) | e.g. "定积分" |
| lwmkpdesc | VARCHAR(200) | optional |

**lwmquestionknowledge** — Many-to-many link between questions and knowledge points. One question can test multiple KPs.

| Column | Type | Notes |
|--------|------|-------|
| lwmqkid | INT PK AUTO | |
| lwmquestionid | INT FK → lwmexamquestion | CASCADE |
| lwmkpid | INT FK → lwmknowledgepoint | CASCADE |
| UNIQUE(lwmquestionid, lwmkpid) | | |

**lwmmistakebook** — Per-student, per-question mistake record. Inserted/updated automatically when an exam is submitted and an answer is wrong.

| Column | Type | Notes |
|--------|------|-------|
| lwmmid | INT PK AUTO | |
| lwmstudentid | INT FK → lwmstudent | CASCADE |
| lwmquestionid | INT FK → lwmexamquestion | CASCADE |
| lwmiswrong | TINYINT(1) | 1=wrong, 0=later-correct |
| lwmreviewstatus | TINYINT | 0=unreviewed, 1=reviewed, 2=mastered |
| lwmlastupdatetime | DATETIME | ON UPDATE CURRENT_TIMESTAMP |
| UNIQUE(lwmstudentid, lwmquestionid) | | |

Existing `lwmexampaper.lwmclassname` widened from VARCHAR(20) → VARCHAR(200) to store comma-separated multi-class names.

## Student-Facing Features

### Mistake Book (lwmstudent_mistakebook.jsp)

- Left-menu entry under student portal.
- Filters: subject dropdown, knowledge-point dropdown (cascading from subject), review-status dropdown.
- Paginated list of mistake entries. Each row shows: question type badge, truncated content, KP tags, wrong-count, last-wrong time, review-status badge.
- Expand to see: full question, all options, student's last answer, correct answer.
- Actions per entry: mark as "reviewed" / "mastered"; "find similar" (search same-KP questions).
- Tab switch: "Mistake List" | "Knowledge Analysis".

### Knowledge Mastery Radar (lwmstudent_kp_radar.jsp)

- Second tab of mistake book page.
- ECharts radar chart: axes = KPs in selected subject; value = mastery rate (1 − wrong/total_exposed, floor 0).
- Below chart: table of KP → questions seen → wrong count → mastery % → trend arrow.

### Backend Actions (student)

- **lwmMistakeBookAction** — query mistake list (paginated, filtered), update review status.
- **lwmKnowledgeMasteryAction** — compute per-KP mastery for radar chart JSON.

### Automatic Mistake Recording

On exam submit (lwmSubmitExam), after grading: for each answer where score < question max score, INSERT INTO lwmmistakebook ON DUPLICATE KEY UPDATE lwmiswrong=1, lwmlastupdatetime=NOW(). If answer is correct and a previous mistake record exists, update lwmiswrong=0.

## Teacher-Facing Features

### Score Analysis Dashboard (lwmteacher_score_analysis.jsp)

- Left-menu entry under teacher portal.
- Top filters: subject, class, paper (cascading).

**Tab 1 — Score Overview**
- 4 stat cards: mean, max, min, standard deviation.
- Score distribution bar chart (ECharts): 0-59, 60-69, 70-79, 80-89, 90-100.
- Pass-rate gauge chart (ECharts).
- Student score detail table (sortable).

**Tab 2 — Question Quality**
- Per-question rows for the selected paper:
  - Difficulty = correct_count / total_students (0–1, higher = easier). ★ to ★★★★.
  - Discrimination = (high-group correct rate) − (low-group correct rate). High group = top 27%, low group = bottom 27%. Flag < 0.2 in red.
- Click to expand per-question answer distribution.

**Tab 3 — Knowledge-Point Analysis**
- ECharts heatmap: KP × score-rate matrix.
- Table: KP | question count | avg score rate | weak-student count (score rate < 60%).

### Class Comparison (lwmteacher_class_compare.jsp)

- Third tab of score analysis page.
- Subject + paper filter; multi-select class checkboxes.

**Tab 1 — Core Metrics**
- Multi-series bar chart: mean, pass rate, excellence rate (≥80) per class.
- Comparison table.

**Tab 2 — Score Distribution**
- Grouped bar chart: class × score-bracket counts.

**Tab 3 — Knowledge Point Radar**
- Multi-series radar: one line per class, axes = KPs, values = avg score rate.

### Backend Actions (teacher)

- **lwmScoreAnalysisAction** — aggregate stats, distribution, pass rate, student detail list.
- **lwmQuestionQualityAction** — per-question difficulty, discrimination (high/low group split).
- **lwmKnowledgeAnalysisAction** — KP-level score-rate aggregation, per-class comparison data.

## Frontend Dependency

ECharts loaded via CDN in relevant JSP pages:
```html
<script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
```

## Entity & DAO Additions

- Entities: `lwmKnowledgePoint`, `lwmQuestionKnowledge`, `lwmMistakeBook`
- DAOs: `lwmKnowledgePointDAO`, `lwmMistakeBookDAO`, `lwmQuestionKnowledgeDAO`
- New methods in existing DAOs: `lwmscoreDAO` (aggregation queries), `lwmquestionDAO` (KP-tagged queries)

## Error Handling

- Charts render empty state when no data (show message instead of blank chart).
- Discrimination/Difficulty calculations guard against division by zero (no students, no answers).
- Database errors caught at DAO level, surfaced via request attribute to JSP.

## Testing

- DAO-level: verify aggregation queries return correct stats against known test data.
- Action-level: verify JSON responses match expected structure for ECharts consumption.
- UI-level: manual verification of chart rendering and filter cascading.
