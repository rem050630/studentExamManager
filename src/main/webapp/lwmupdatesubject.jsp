<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>高校在线考试系统 - 修改课程信息</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        /* 全局样式与重置 */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #e9edf2 100%);
            min-height: 100vh;
            padding: 40px 24px;
            color: #1e293b;
        }

        /* 主容器 */
        .container {
            max-width: 800px;
            margin: 0 auto;
            width: 100%;
        }

        /* 表单卡片 */
        .form-card {
            background: rgba(255, 255, 255, 0.96);
            backdrop-filter: blur(0px);
            border-radius: 28px;
            box-shadow: 0 20px 35px -12px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.02);
            overflow: hidden;
            border: 1px solid rgba(255, 255, 255, 0.5);
            animation: fadeInUp 0.5s ease-out;
        }

        /* 卡片头部 */
        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1.5rem 2rem;
            background: #ffffff;
            border-bottom: 1px solid #eef2f6;
        }

        .card-header h3 {
            font-size: 1.5rem;
            font-weight: 600;
            letter-spacing: -0.3px;
            background: linear-gradient(135deg, #1f2b3c, #2c3e50);
            background-clip: text;
            -webkit-background-clip: text;
            color: transparent;
            display: inline-flex;
            align-items: center;
            gap: 12px;
        }

        .card-header h3 i {
            background: linear-gradient(135deg, #3b82f6, #6366f1);
            background-clip: text;
            -webkit-background-clip: text;
            color: transparent;
            font-size: 1.6rem;
        }

        /* 返回按钮 */
        .btn-back {
            background: #f1f5f9;
            border: none;
            padding: 8px 18px;
            border-radius: 40px;
            font-weight: 500;
            font-size: 0.85rem;
            color: #475569;
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            font-family: 'Inter', sans-serif;
        }

        .btn-back:hover {
            background: #e2e8f0;
            transform: translateX(-2px);
        }

        /* 表单主体 */
        .form-body {
            padding: 2rem;
        }

        /* 表单组 */
        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 600;
            color: #334155;
            font-size: 0.85rem;
            letter-spacing: 0.3px;
            text-transform: uppercase;
        }

        .form-group label i {
            margin-right: 6px;
            color: #3b82f6;
            font-size: 0.8rem;
        }

        .required {
            color: #ef4444;
            margin-left: 4px;
        }

        /* 输入框样式 */
        .form-control {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e2e8f0;
            border-radius: 16px;
            font-size: 0.95rem;
            font-family: 'Inter', sans-serif;
            transition: all 0.2s ease;
            background: #ffffff;
            color: #1e293b;
        }

        .form-control:focus {
            outline: none;
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }

        /* 按钮组 */
        .form-actions {
            display: flex;
            gap: 16px;
            margin-top: 2rem;
            padding-top: 1rem;
        }

        .btn-submit {
            flex: 1;
            background: linear-gradient(100deg, #3b82f6, #6366f1);
            border: none;
            padding: 12px 24px;
            border-radius: 40px;
            font-weight: 600;
            font-size: 0.95rem;
            color: white;
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            box-shadow: 0 2px 5px rgba(59, 130, 246, 0.2);
            font-family: 'Inter', sans-serif;
        }

        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 18px rgba(59, 130, 246, 0.3);
            background: linear-gradient(100deg, #2563eb, #4f46e5);
        }

        .btn-reset {
            flex: 1;
            background: #f1f5f9;
            border: 1px solid #e2e8f0;
            padding: 12px 24px;
            border-radius: 40px;
            font-weight: 600;
            font-size: 0.95rem;
            color: #475569;
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            font-family: 'Inter', sans-serif;
        }

        .btn-reset:hover {
            background: #e2e8f0;
            transform: translateY(-1px);
        }

        /* 提示信息 */
        .alert {
            padding: 12px 16px;
            border-radius: 16px;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 0.85rem;
            animation: slideDown 0.3s ease-out;
        }

        .alert-success {
            background: #f0fdf4;
            border: 1px solid #bbf7d0;
            color: #166534;
        }

        .alert-error {
            background: #fef2f2;
            border: 1px solid #fecaca;
            color: #991b1b;
        }

        .alert i {
            font-size: 1rem;
        }

        /* 入场动画 */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* 响应式 */
        @media (max-width: 640px) {
            body {
                padding: 20px 16px;
            }

            .card-header {
                padding: 1.2rem 1.2rem;
            }

            .card-header h3 {
                font-size: 1.25rem;
            }

            .form-body {
                padding: 1.5rem;
            }

            .form-actions {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
<div class="container">
    <div class="form-card">
        <div class="card-header">
            <h3><i class="fas fa-book-edit"></i> 修改课程信息</h3>
            <a href="lwmsubject.jsp?t=<%=System.currentTimeMillis()%>" class="btn-back">
                <i class="fas fa-arrow-left"></i> 返回列表
            </a>
        </div>
        <div class="form-body">
            <!-- 提示信息 -->
            <c:if test="${not empty error}">
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i>
                    <span>${error}</span>
                </div>
            </c:if>
            <c:if test="${not empty success}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i>
                    <span>${success}</span>
                </div>
            </c:if>

            <!-- 修改课程表单：提交到修改Servlet，自动回显原有数据 -->
            <form action="lwmUpdatesubject" method="post" onsubmit="return validateForm()">
                <!-- 隐藏域：传递课程ID -->
                <input type="hidden" name="lwmsubjectid" value="${subject.lwmsubjectid}">

                <div class="form-group">
                    <label><i class="fas fa-book-open"></i> 课程名称 <span class="required">*</span></label>
                    <input type="text" name="lwmsubjectname" id="lwmsubjectname" class="form-control"
                           value="${subject.lwmsubjectname}" placeholder="请输入课程名称" required maxlength="50">
                </div>

                <div class="form-group">
                    <label><i class="fas fa-file-alt"></i> 课程代码 <span class="required">*</span></label>
                    <input type="text" name="lwmsubjectdesc" id="lwmsubjectdesc" class="form-control"
                           value="${subject.lwmsubjectdesc}" placeholder="请输入课程描述" required maxlength="200">
                </div>

                <div class="form-group">
                    <label><i class="fas fa-star"></i> 课程学分 <span class="required">*</span></label>
                    <input type="number" name="lwmsubjectscore" id="lwmsubjectscore" class="form-control"
                           value="${subject.lwmsubjectscore}" placeholder="请输入课程学分（1-10）" required min="1" max="10">
                </div>

                <div class="form-group">
                    <label><i class="fas fa-calendar"></i> 开课学期 <span class="required">*</span></label>
                    <select name="lwmterm" id="lwmterm" class="form-control" required>
                        <option value="">请选择学期</option>
                        <option value="2021-2022第一学期" ${subject.lwmterm=='2021-2022第一学期' ? 'selected' : ''}>2021-2022第一学期</option>
                        <option value="2021-2022第二学期" ${subject.lwmterm=='2021-2022第二学期' ? 'selected' : ''}>2021-2022第二学期</option>
                        <option value="2022-2023第一学期" ${subject.lwmterm=='2022-2023第一学期' ? 'selected' : ''}>2022-2023第一学期</option>
                        <option value="2022-2023第二学期" ${subject.lwmterm=='2022-2023第二学期' ? 'selected' : ''}>2022-2023第二学期</option>
                        <option value="2023-2024第一学期" ${subject.lwmterm=='2023-2024第一学期' ? 'selected' : ''}>2023-2024第一学期</option>
                        <option value="2023-2024第二学期" ${subject.lwmterm=='2023-2024第二学期' ? 'selected' : ''}>2023-2024第二学期</option>
                        <option value="2024-2025第一学期" ${subject.lwmterm=='2024-2025第一学期' ? 'selected' : ''}>2024-2025第一学期</option>
                        <option value="2024-2025第二学期" ${subject.lwmterm=='2024-2025第二学期' ? 'selected' : ''}>2024-2025第二学期</option>
                    </select>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn-submit">
                        <i class="fas fa-save"></i> 保存修改
                    </button>
                    <button type="reset" class="btn-reset">
                        <i class="fas fa-undo-alt"></i> 重置
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // 表单验证
    function validateForm() {
        var subjectname = document.getElementById('lwmsubjectname').value.trim();
        var subjectdesc = document.getElementById('lwmsubjectdesc').value.trim();
        var score = document.getElementById('lwmsubjectscore').value;
        var term = document.getElementById('lwmterm').value;

        if (subjectname.length < 2 || subjectname.length > 50) {
            alert('课程名称长度必须在2-50位之间！');
            return false;
        }
        if (subjectdesc.length < 2 || subjectdesc.length > 200) {
            alert('课程描述长度必须在2-200位之间！');
            return false;
        }
        if (score < 1 || score > 10) {
            alert('学分必须在1-10之间！');
            return false;
        }
        if (term === '') {
            alert('请选择开课学期！');
            return false;
        }
        return true;
    }

    // 自动隐藏提示
    document.addEventListener('DOMContentLoaded', function() {
        var successAlert = document.querySelector('.alert-success');
        if (successAlert) {
            setTimeout(() => successAlert.style.display = 'none', 3000);
        }
        var errorAlert = document.querySelector('.alert-error');
        if (errorAlert) {
            setTimeout(() => errorAlert.style.display = 'none', 3000);
        }
    });
</script>
</body>
</html>