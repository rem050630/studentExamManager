# Dynamic Pass Line for Score Analysis

## Goal

Replace hardcoded 60-point pass threshold with 60% of each exam paper's total score (`lwmexamsore`). Also update distribution brackets and student grade labels to use percentage-based thresholds.

## Design

### Backend: `lwmScoreAnalysisAction.java`

**New: Load paper total score**

When `paperId` is provided, query `lwmexampaper.lwmexamsore` to get the total score.

**Compute dynamic thresholds:**

```java
int totalScore = paper.getLwmexamsore();
int passLine  = (int)(totalScore * 0.6);   // 及格线
int b2End     = (int)(totalScore * 0.7);   // 60%-70%
int b3End     = (int)(totalScore * 0.8);   // 70%-80%
int excelLine = (int)(totalScore * 0.9);   // 优秀线（也是80%-90%的上界）
```

**SQL changes (6 locations):**

All hardcoded `60` replaced with Java variable `passLine`, `90` replaced with `excelLine`. Distribution bracket boundaries also computed from `totalScore` percentages. Values are integer arithmetic results concatenated into SQL (not user input, safe from injection).

**New request attributes passed to JSP:**

- `passLine` (int)
- `excelLine` (int)
- `totalScore` (int)
- `bracketLabels` (String[]) — dynamic labels for distribution chart

Affected code blocks:
- Line 143-144: compare mode pass/excel rate SQL
- Line 163-169: compare mode distribution SQL (5 CASE branches)
- Line 257-261: single paper distribution SQL (5 CASE branches)
- Line 286: single paper pass rate SQL

### Frontend: `lwmteacher_score_analysis.jsp`

- Line 191-192: student grade labels use `passLine` and `excelLine` instead of hardcoded 60/90
- Line 307: distribution chart x-axis labels use dynamic `bracketLabels` array
- Line 310 label text: dynamic from `bracketLabels` (e.g. for 150-point paper: `0-89`, `90-104`, etc.)
- Line 174: pass rate indicator text (`passRate >= 60`) unchanged — this is about pass rate percentage, not score threshold

## What Stays the Same

- The pass rate gauge text "及格率 >= 60% 为良好" — this checks the percentage of students passing, not individual scores
- Grade labels "优秀/良好/中等/及格/不及格" semantics
- Distribution chart has 5 brackets, just with dynamic boundaries

## Files Changed

- `src/main/java/com/example/lwmexam/action/lwmexam/lwmScoreAnalysisAction.java`
- `src/main/webapp/lwmteacher_score_analysis.jsp`
