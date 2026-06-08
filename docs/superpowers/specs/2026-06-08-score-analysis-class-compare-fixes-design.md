# Score Analysis Class Query & Class Compare Fixes

**Date**: 2026-06-08  
**Status**: approved

## Scope

3 fixes in 2 files:

| File | Change |
|------|--------|
| `lwmScoreAnalysisAction.java` | Split comma-separated class names into individual options |
| `lwmteacher_class_compare.jsp` | Fix subject dropdown filtering; allow re-compare after first compare |

## Problem 1: Class dropdown shows grouped class names

**Root cause**: `lwmScoreAnalysisAction.java` loads `lwmclassname` from `lwmexampaper`, which stores comma-separated class names (e.g. `"大数据1班,计算机科学与技术1班"`). These composite strings are placed directly into the dropdown, but the query uses exact match against student records that hold single class names.

**Fix**: After loading the distinct `lwmclassname` list, iterate each value, split by comma, trim whitespace, deduplicate with a `Set`, and pass the resulting single-class-name list to the JSP.

**File**: `lwmScoreAnalysisAction.java`, lines ~80-84

## Problem 2: Subject dropdown on class compare page has no effect

**Root cause**: `lwmteacher_class_compare.jsp` `onSubjectChange()` uses `style.display = 'none'` to hide `<option>` elements, which is unreliable across browsers.

**Fix**: 
- On page load, cache all paper options (except the placeholder) into a JS array `allPaperOptions`.
- `onSubjectChange()`: clear the paper dropdown, re-add the placeholder option, then add back only options whose `data-subject` matches the selected subject.
- If the previously selected paper is no longer in the list, reset to the placeholder.
- Call `onPaperChange()` after.

**File**: `lwmteacher_class_compare.jsp`, `onSubjectChange()` function

## Problem 3: Re-compare shows stale data

**Root cause**: `startCompare()` uses one-shot flags (`coreMetricsRendered`, `distRendered`, `kpLoaded`) that prevent re-rendering after the first compare. The button re-enables after fetch, but `renderCoreMetrics()` etc. return immediately because the flags are already `true`.

**Fix** in `startCompare()`, before calling render functions:
1. Reset `coreMetricsRendered = false`, `distRendered = false`, `kpLoaded = false`
2. Dispose old chart instances (`coreChartInst`, `distChartInst`, `kpChartInst`)
3. Clear old table HTML

**File**: `lwmteacher_class_compare.jsp`, `startCompare()` function

## Edge Cases

- **P1**: Null or empty `lwmclassname` values are skipped during split.
- **P2**: Switching subjects while a paper is selected: if the selected paper's subject doesn't match, dropdown resets to placeholder and class checkboxes clear.
- **P3**: Empty compare result correctly shows "no data" message; next compare clears and re-renders fresh.
