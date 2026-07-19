<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>高校在线考试系统 - 添加学生</title>
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

        /* 输入框样式 & 下拉框 */
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
            appearance: none;
            background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="%2364748b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>');
            background-repeat: no-repeat;
            background-position: right 16px center;
            background-size: 16px;
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
            <h3><i class="fas fa-user-plus"></i> 添加学生信息</h3>
            <a href="lwmstudentlist.jsp" class="btn-back">
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

            <!-- 添加学生表单 -->
            <form action="lwmAddstudent" method="post" onsubmit="return validateForm()">
                <div class="form-group">
                    <label><i class="fas fa-id-card"></i> 学号 <span class="required">*</span></label>
                    <input type="text" name="lwmstudentno" id="lwmstudentno" class="form-control"
                           placeholder="请输入学号，例如：20210001" required maxlength="20">
                </div>

                <div class="form-group">
                    <label><i class="fas fa-user"></i> 姓名 <span class="required">*</span></label>
                    <input type="text" name="lwmstudentname" id="lwmstudentname" class="form-control"
                           placeholder="请输入姓名" required maxlength="50">
                </div>

                <div class="form-group">
                    <label><i class="fas fa-key"></i> 密码 <span class="required">*</span></label>
                    <div style="position: relative;">
                        <input type="password" name="lwmstudentpassword" id="lwmstudentpassword" class="form-control"
                               placeholder="请输入密码" required minlength="3" maxlength="20">
                        <i class="fas fa-eye" id="togglePassword" style="position: absolute; right: 16px; top: 50%; transform: translateY(-50%); cursor: pointer; color: #64748b; font-size: 16px;"></i>
                    </div>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-venus-mars"></i> 性别 <span class="required">*</span></label>
                    <div class="radio-group">
                        <label class="radio-label">
                            <input type="radio" name="lwmgender" value="男" checked> 男
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="lwmgender" value="女"> 女
                        </label>
                    </div>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-calendar-alt"></i> 年级 <span class="required">*</span></label>
                    <select name="lwmgrade" id="lwmgrade" class="form-control" required>
                        <option value="">请选择年级</option>
                        <option value="2021级">2021级</option>
                        <option value="2022级">2022级</option>
                        <option value="2023级">2023级</option>
                        <option value="2024级">2024级</option>
                        <option value="2025级">2025级</option>
                    </select>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-graduation-cap"></i> 专业 <span class="required">*</span></label>
                    <select name="lwmmajor" id="lwmmajor" class="form-control" required>
                        <option value="">请选择专业</option>
                        <option value="计算机科学与技术">计算机科学与技术</option>
                        <option value="软件工程">软件工程</option>
                        <option value="网络工程">网络工程</option>
                        <option value="数据科学与大数据技术">数据科学与大数据技术</option>
                        <option value="人工智能">人工智能</option>
                        <option value="信息管理与信息系统">信息管理与信息系统</option>
                    </select>
                </div>

                <!-- 班级区域：改为动态下拉选框，根据专业联动 -->
                <div class="form-group">
                    <label><i class="fas fa-users"></i> 班级 <span class="required">*</span></label>
                    <select name="lwmclassname" id="lwmclassname" class="form-control" required>
                        <option value="">请先选择专业</option>
                    </select>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn-submit">
                        <i class="fas fa-save"></i> 添加学生
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
    // ---------- 专业与班级映射表 (根据需求动态生成) ----------
    // 定义每个专业对应的班级数组 (班级后缀数字1~4，可根据实际情况扩展)
    const classMapping = {
        "计算机科学与技术": ["计算机科学与技术1班", "计算机科学与技术2班", "计算机科学与技术3班", "计算机科学与技术4班"],
        "软件工程": ["软件工程1班", "软件工程2班", "软件工程3班", "软件工程4班"],
        "网络工程": ["网络工程1班", "网络工程2班", "网络工程3班", "网络工程4班"],
        "数据科学与大数据技术": ["数据科学与大数据技术1班", "数据科学与大数据技术2班", "数据科学与大数据技术3班", "数据科学与大数据技术4班"],
        "人工智能": ["人工智能1班", "人工智能2班", "人工智能3班", "人工智能4班"],
        "信息管理与信息系统": ["信息管理与信息系统1班", "信息管理与信息系统2班", "信息管理与信息系统3班", "信息管理与信息系统4班"]
    };

    // 获取班级下拉框元素
    const majorSelect = document.getElementById('lwmmajor');
    const classSelect = document.getElementById('lwmclassname');

    // 更新班级选项的函数 (根据选中的专业值)
    function updateClassOptions() {
        const selectedMajor = majorSelect.value;
        // 清空现有选项 (保留一个占位提示)
        classSelect.innerHTML = '';

        if (!selectedMajor || selectedMajor === "") {
            // 未选择专业时，显示提示占位，并禁用表单验证友好
            const defaultOption = document.createElement('option');
            defaultOption.value = "";
            defaultOption.textContent = "请先选择专业";
            defaultOption.disabled = true;
            defaultOption.selected = true;
            classSelect.appendChild(defaultOption);
            classSelect.disabled = true;   // 未选专业时禁用班级下拉
            return;
        }

        // 获取该专业对应的班级列表
        const classList = classMapping[selectedMajor];
        if (classList && classList.length > 0) {
            // 启用班级下拉框
            classSelect.disabled = false;
            // 添加提示性选项 (不可选)
            const placeholderOption = document.createElement('option');
            placeholderOption.value = "";
            placeholderOption.textContent = "请选择班级";
            placeholderOption.disabled = true;
            placeholderOption.selected = true;
            classSelect.appendChild(placeholderOption);

            // 动态添加班级选项
            classList.forEach(className => {
                const option = document.createElement('option');
                option.value = className;
                option.textContent = className;
                classSelect.appendChild(option);
            });
        } else {
            // 兜底: 如果没有映射数据，可以提供一个默认输入? 但按照需求每个专业都有班级列表，不会走到这里
            const fallbackOption = document.createElement('option');
            fallbackOption.value = "";
            fallbackOption.textContent = "暂无班级数据";
            fallbackOption.disabled = true;
            fallbackOption.selected = true;
            classSelect.appendChild(fallbackOption);
            classSelect.disabled = true;
        }
    }

    // 监听专业下拉变化
    majorSelect.addEventListener('change', function() {
        updateClassOptions();
        // 可选：触发一次班级验证样式更新
    });

    // 表单重置时，需要重置班级下拉状态 (适配重置按钮)
    const resetBtn = document.querySelector('.btn-reset');
    if (resetBtn) {
        resetBtn.addEventListener('click', function(e) {
            // 由于重置按钮会重置表单原生状态，但动态下拉需要同步，利用setTimeout等待表单原生重置完成后再根据专业同步班级
            setTimeout(function() {
                // 重置后专业默认是空字符串（第一个option）
                // 重新根据当前专业(可能是空) 更新班级选项
                updateClassOptions();
                // 同时清空其他可能的字段视觉，但密码眼睛之类不受影响
                // 手动将性别重置为男生 (表单reset会将radio重置为默认值，但以防万一)
                const genderRadios = document.querySelectorAll('input[name="lwmgender"]');
                if (genderRadios.length) {
                    for(let radio of genderRadios) {
                        if(radio.value === '男') radio.checked = true;
                    }
                }
                // 清除隐藏提示不影响
            }, 10);
        });
    }

    // 页面加载时初始化班级下拉 (默认专业没有选中值，所以显示“请先选择专业”并禁用)
    document.addEventListener('DOMContentLoaded', function() {
        // 初始化班级下拉 (根据当前已选专业，可能后端回显时专业有值？例如编辑场景？但此页面为添加页，专业默认为空)
        // 但如果由于某些原因（浏览器记忆）专业有默认选中，则联动班级
        updateClassOptions();

        // 如果有成功或错误提示，自动隐藏
        var successAlert = document.querySelector('.alert-success');
        if (successAlert) {
            setTimeout(function() {
                successAlert.style.display = 'none';
            }, 3000);
        }
        var errorAlert = document.querySelector('.alert-error');
        if (errorAlert) {
            setTimeout(function() {
                errorAlert.style.display = 'none';
            }, 3000);
        }

        // 额外的样式修复: 如果专业默认有选中值（比如某个浏览器预置），保持班级可用
        if (majorSelect.value && majorSelect.value !== "") {
            updateClassOptions();
        }
    });

    // 密码显示/隐藏切换
    const togglePwd = document.getElementById('togglePassword');
    if (togglePwd) {
        togglePwd.addEventListener('click', function () {
            const passInput = document.getElementById('lwmstudentpassword');
            const type = passInput.type === 'password' ? 'text' : 'password';
            passInput.type = type;
            this.classList.toggle('fa-eye-slash');
        });
    }

    // 表单验证 (增强班级验证：必须选择一个具体的班级选项)
    function validateForm() {
        // 获取表单值
        var studentno = document.getElementById('lwmstudentno').value.trim();
        var studentname = document.getElementById('lwmstudentname').value.trim();
        var password = document.getElementById('lwmstudentpassword').value;
        var grade = document.getElementById('lwmgrade').value;
        var major = document.getElementById('lwmmajor').value;
        var classValue = document.getElementById('lwmclassname').value.trim();

        // 学号验证（字母数字组合，长度3-20）
        var studentnoRegex = /^[a-zA-Z0-9]{3,20}$/;
        if (!studentnoRegex.test(studentno)) {
            alert('学号格式不正确！请输入3-20位的数字或字母组合。');
            return false;
        }

        // 姓名验证（2-20个中文字符或字母）
        var nameRegex = /^[\u4e00-\u9fa5a-zA-Z]{2,20}$/;
        if (!nameRegex.test(studentname)) {
            alert('姓名格式不正确！请输入2-20位的中文或字母。');
            return false;
        }

        // 密码验证（3-20位，任意字符但长度限制）
        if (password.length < 3 || password.length > 20) {
            alert('密码长度必须在3-20位之间！');
            return false;
        }

        // 年级验证
        if (grade === '') {
            alert('请选择年级！');
            return false;
        }

        // 专业验证
        if (major === '') {
            alert('请选择专业！');
            return false;
        }

        // 班级验证：必须选中非空且不是占位提示的值，并且班级下拉不可禁用选项
        if (!classValue || classValue === "") {
            alert('请根据所选专业选择班级！');
            return false;
        }

        // 额外可选：确保班级值属于当前专业映射 (二次保证)
        const validClasses = classMapping[major];
        if (validClasses && !validClasses.includes(classValue)) {
            alert('班级与所选专业不匹配，请重新选择班级。');
            return false;
        }

        return true;
    }

    // 绑定专业变更后，清空班级无效验证样式（不必须，仅体验）
    majorSelect.addEventListener('change', function() {
        // 触发班级下拉更新已自带重置选中，无需额外操作。
        // 如果原先班级验证错误标记，可以清除错误样式（不需要样式切换）
    });

    // 为了确保重置时也把班级恢复禁用（如果专业为空）并清除选中，再触发一次重置联动
    // 监听表单重置事件完美支持
    const addForm = document.querySelector('form');
    if(addForm) {
        addForm.addEventListener('reset', function() {
            // 原生reset会重置select到初始值，但动态select的innerHTML会被覆盖；需延时重新根据专业同步。
            setTimeout(() => {
                // 专业恢复为默认空（因为html中option第一个是"请选择专业"）
                // 重新根据当前专业值（空）刷新班级下拉
                updateClassOptions();
                // 同时确保性别选项重置为“男”
                const maleRadio = document.querySelector('input[name="lwmgender"][value="男"]');
                if(maleRadio) maleRadio.checked = true;
            }, 5);
        });
    }
</script>
</body>
</html>
```