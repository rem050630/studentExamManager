# AI Analysis Feature Design

## Overview

在教师端成绩分析页面新增"AI分析"Tab，整合成绩概览、试题质量、知识点分析三部分数据，调用 DeepSeek API 给出 200-300 字的精简综合分析和教学建议。

## Architecture

```
lwmteacher_score_analysis.jsp (第5个Tab: AI分析)
       │ JS fetch GET /lwmAIAnalysis?paperid=...&classname=...
       ▼
lwmAIAnalysisAction.java (新Servlet)
       │ 1. 查询成绩概览 stats + distribution + passRate
       │ 2. 查询试题质量 (每题 difficulty/discrimination)
       │ 3. 查询知识点分析 (每知识点 rate/weak)
       │ 4. 构建 prompt → POST DeepSeek API
       │ 5. 返回 {analysis: "...", model: "deepseek-chat"}
       ▼
DeepSeek API (api.deepseek.com/v1/chat/completions)
```

## Files

### New Files

| File | Purpose |
|------|---------|
| `src/main/webapp/WEB-INF/config.properties` | DeepSeek API key and URL |
| `src/main/java/com/example/lwmexam/action/lwmexam/lwmAIAnalysisAction.java` | AI analysis servlet |

### Modified Files

| File | Change |
|------|--------|
| `src/main/webapp/lwmteacher_score_analysis.jsp` | Add "AI分析" tab button + tab content area with loading/result/error states |

## Data Flow

1. User selects paper → clicks "AI分析" tab
2. Frontend JS: `fetch('lwmAIAnalysis?paperid=...&classname=...')` with loading spinner
3. Servlet collects three data sets:
   - **Overview**: count, avg, max, min, passRate, distribution[5]
   - **Question quality**: per-question type, difficulty, discrimination, related KPs
   - **Knowledge points**: per-KP name, score rate, weak flag
4. Servlet builds prompt:
   - System: "你是一位教育数据分析专家。请根据以下考试数据给出200-300字的精简分析，包含2-3个核心问题和针对性教学建议。"
   - User: structured text with the three data blocks
5. Servlet calls DeepSeek API via `HttpURLConnection`
6. Returns JSON `{analysis: "...", model: "deepseek-chat"}` to frontend
7. Frontend renders analysis text with basic paragraph formatting

## Configuration

`WEB-INF/config.properties`:
```properties
deepseek.api.key=sk-xxx
deepseek.api.url=https://api.deepseek.com/v1/chat/completions
```

Servlet reads config on init via `ServletContext.getResourceAsStream()`.

## DeepSeek API Call

- Endpoint: `https://api.deepseek.com/v1/chat/completions`
- Format: OpenAI-compatible JSON
- Model: `deepseek-chat`
- HttpURLConnection (Java 1.8 built-in, no extra dependency)

## Frontend States

| State | UI |
|-------|----|
| Loading | Spinner + "AI正在分析中，请稍候..." |
| Success | Formatted analysis text with paragraph breaks |
| Error | Error message with fallback suggestion |
| No paper selected | "请先选择试卷进行成绩分析" |

## Prompt Design

System message: 教育数据分析专家，精简风格，200-300字。
User message: 结构化数据文本（成绩概览、试题质量、知识点），中文字段名。
