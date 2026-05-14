<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>高校在线考试系统 - 修改教师信息</title>
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

        /* 单选按钮组 */
        .radio-group {
            display: flex;
            gap: 24px;
            padding: 8px 0;
        }

        .radio-label {
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            font-weight: 500;
            color: #334155;
        }

        .radio-label input[type="radio"] {
            width: 18px;
            height: 18px;
            cursor: pointer;
            accent-color: #3b82f6;
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

            .radio-group {
                gap: 16px;
            }
        }
    </style>
</head>
<body>
<div class="container">
    <div class="form-card">
        <div class="card-header">
            <h3><i class="fas fa-user-edit"></i> 修改教师信息</h3>
            <a href="lwmteacherlist.jsp?t=<%=System.currentTimeMillis()%>" class="btn-back">
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

            <!-- 修改教师表单 -->
            <form action="lwmUpdateteacher" method="post" onsubmit="return validateForm()">
                <!-- 隐藏域：传递教师ID -->
                <input type="hidden" name="lwmteacherid" value="${teacher.lwmteacherid}">

                <div class="form-group">
                    <label><i class="fas fa-id-card"></i> 工号 <span class="required">*</span></label>
                    <input type="text" name="lwmteacherno" id="lwmteacherno" class="form-control"
                           value="${teacher.lwmteacherno}" placeholder="请输入工号" required maxlength="20">
                </div>

                <div class="form-group">
                    <label><i class="fas fa-user"></i> 姓名 <span class="required">*</span></label>
                    <input type="text" name="lwmteachername" id="lwmteachername" class="form-control"
                           value="${teacher.lwmteachername}" placeholder="请输入姓名" required maxlength="50">
                </div>

                <div class="form-group">
                    <label><i class="fas fa-key"></i> 密码 <span class="required">*</span></label>
                    <div style="position: relative;">
                        <input type="password" name="lwmteacherpassword" id="lwmteacherpassword" class="form-control"
                               value="${teacher.lwmteacherpassword}" placeholder="请输入密码" required minlength="3" maxlength="20">
                        <i class="fas fa-eye" id="togglePassword" style="position: absolute; right: 16px; top: 50%; transform: translateY(-50%); cursor: pointer; color: #64748b; font-size: 16px;"></i>
                    </div>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-venus-mars"></i> 性别 <span class="required">*</span></label>
                    <div class="radio-group">
                        <label class="radio-label">
                            <input type="radio" name="lwmteachergender" value="男" ${teacher.lwmteachergender=='男' ? 'checked' : ''}> 男
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="lwmteachergender" value="女" ${teacher.lwmteachergender=='女' ? 'checked' : ''}> 女
                        </label>
                    </div>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-phone"></i> 联系电话 <span class="required">*</span></label>
                    <input type="text" name="lwmteacherphone" id="lwmteacherphone" class="form-control"
                           value="${teacher.lwmteacherphone}" placeholder="请输入联系电话" required maxlength="20">
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
        var teacherno = document.getElementById('lwmteacherno').value.trim();
        var teachername = document.getElementById('lwmteachername').value.trim();
        var password = document.getElementById('lwmteacherpassword').value;
        var phone = document.getElementById('lwmteacherphone').value.trim();

        var teachernoRegex = /^[a-zA-Z0-9]{3,20}$/;
        if (!teachernoRegex.test(teacherno)) {
            alert('工号格式不正确！请输入3-20位的数字或字母组合。');
            return false;
        }

        var nameRegex = /^[\u4e00-\u9fa5a-zA-Z]{2,20}$/;
        if (!nameRegex.test(teachername)) {
            alert('姓名格式不正确！请输入2-20位的中文或字母。');
            return false;
        }

        if (password.length < 3 || password.length > 20) {
            alert('密码长度必须在3-20位之间！');
            return false;
        }

        if(phone.trim() === ''){
            alert('请输入联系电话！');
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

    // 密码显示/隐藏切换
    document.getElementById('togglePassword').addEventListener('click', function () {
        const pass = document.getElementById('lwmteacherpassword');
        const type = pass.type === 'password' ? 'text' : 'password';
        pass.type = type;
        this.classList.toggle('fa-eye-slash');
    });
</script>
</body>
</html>