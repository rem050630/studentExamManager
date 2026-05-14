
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>分页组件</title>
    <style>
        /* 分页组件样式 - 现代简洁设计 */
        .pagination-wrapper {
            margin-top: 24px;
            margin-bottom: 16px;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
        }

        .pagin {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
            background: #ffffff;
            padding: 12px 20px;
            border-radius: 48px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04), 0 1px 2px rgba(0, 0, 0, 0.03);
        }

        /* 信息统计区域 */
        .message {
            font-size: 0.85rem;
            color: #475569;
            background: #f8fafc;
            padding: 6px 16px;
            border-radius: 32px;
            letter-spacing: 0.2px;
            font-weight: 500;
        }

        .message i.blue {
            font-style: normal;
            color: #3b82f6;
            font-weight: 700;
            font-size: 0.95rem;
            margin: 0 2px;
        }

        /* 分页按钮列表容器 */
        .paginList {
            display: flex;
            list-style: none;
            gap: 8px;
            margin: 0;
            padding: 0;
            align-items: center;
            flex-wrap: wrap;
        }

        /* 每个分页项 */
        .paginItem {
            display: inline-block;
        }

        /* 分页链接按钮样式 */
        .paginItem a {
            display: flex;
            align-items: center;
            justify-content: center;
            min-width: 36px;
            height: 36px;
            padding: 0 12px;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 40px;
            font-size: 0.85rem;
            font-weight: 500;
            color: #334155;
            text-decoration: none;
            transition: all 0.2s ease;
            cursor: pointer;
            font-family: inherit;
        }

        /* 可点击状态的悬停效果 */
        .paginItem a:not(.disabled):hover {
            background: #eff6ff;
            border-color: #3b82f6;
            color: #2563eb;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(59, 130, 246, 0.15);
        }

        /* 禁用状态（不可点击的链接） */
        .paginItem a.disabled,
        .paginItem a[disabled] {
            opacity: 0.45;
            cursor: not-allowed;
            background: #f9fafb;
            color: #94a3b8;
            pointer-events: none;
            border-color: #e9edf2;
        }

        /* 当前激活页样式（如果需要高亮当前页，可根据需求扩展，这里保留功能性） */
        .paginItem a.active-page {
            background: #3b82f6;
            border-color: #3b82f6;
            color: white;
            box-shadow: 0 2px 8px rgba(59, 130, 246, 0.25);
        }

        /* 响应式：小屏幕下间距缩小 */
        @media (max-width: 640px) {
            .pagin {
                flex-direction: column;
                align-items: stretch;
                border-radius: 24px;
                padding: 16px;
                gap: 12px;
            }

            .message {
                text-align: center;
                width: fit-content;
                margin: 0 auto;
            }

            .paginList {
                justify-content: center;
            }

            .paginItem a {
                min-width: 32px;
                height: 32px;
                padding: 0 10px;
                font-size: 0.8rem;
            }
        }

        /* 针对暗色背景或特殊卡片内的微调 */
        .dark-card .pagin {
            background: #1e293b;
        }

        .dark-card .message {
            background: #0f172a;
            color: #cbd5e1;
        }

        .dark-card .paginItem a {
            background: #1e293b;
            border-color: #334155;
            color: #cbd5e1;
        }

        .dark-card .paginItem a:not(.disabled):hover {
            background: #2d3a4e;
            border-color: #3b82f6;
            color: #60a5fa;
        }
    </style>
</head>
<body>
<div class="pagination-wrapper">
    <div class="pagin">
        <div class="message">
            共 <i class="blue">${fp.rowCount}</i> 条记录，共 ${fp.pageCount} 页，
            当前显示第 <i class="blue">${fp.pageNow+1}</i> 页
        </div>
        <ul class="paginList">
            <%-- 首页：始终显示，如果当前不是第一页则跳转，否则禁用样式 --%>
            <li class="paginItem">
                <c:choose>
                    <c:when test="${fp.pageNow != 0}">
                        <a href="${pageUrl}?page=0&tj=${tj}">|<</a>
                    </c:when>
                    <c:otherwise>
                        <a href="javascript:void(0);" class="disabled" disabled="disabled">|<</a>
                    </c:otherwise>
                </c:choose>
            </li>
            <%-- 上一页：如果当前不是第一页则可点击 --%>
            <li class="paginItem">
                <c:choose>
                    <c:when test="${fp.pageNow != 0}">
                        <a href="${pageUrl}?page=${fp.pageNow-1}&tj=${tj}"><</a>
                    </c:when>
                    <c:otherwise>
                        <a href="javascript:void(0);" class="disabled" disabled="disabled"><</a>
                    </c:otherwise>
                </c:choose>
            </li>
            <%-- 下一页：如果当前不是最后一页则可点击 --%>
            <li class="paginItem">
                <c:choose>
                    <c:when test="${fp.pageNow != fp.pageCount-1}">
                        <a href="${pageUrl}?page=${fp.pageNow+1}&tj=${tj}">></a>
                    </c:when>
                    <c:otherwise>
                        <a href="javascript:void(0);" class="disabled" disabled="disabled">></a>
                    </c:otherwise>
                </c:choose>
            </li>
            <%-- 尾页：如果当前不是最后一页则可点击 --%>
            <li class="paginItem">
                <c:choose>
                    <c:when test="${fp.pageNow != fp.pageCount-1}">
                        <a href="${pageUrl}?page=${fp.pageCount-1}&tj=${tj}">>|</a>
                    </c:when>
                    <c:otherwise>
                        <a href="javascript:void(0);" class="disabled" disabled="disabled">>|</a>
                    </c:otherwise>
                </c:choose>
            </li>
        </ul>
    </div>
</div>
</body>
</html>