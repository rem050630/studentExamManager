<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>考试登录系统</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', 'Microsoft YaHei', sans-serif;
            /* 加载本地背景图（推荐方式） */
            background:url("xy.jpg")  no-repeat center center;
            background-size: cover;
            background-attachment: fixed;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            /* 加一层半透明遮罩，让文字更清晰 */
            position: relative;
        }

        body::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.3);
            z-index: 0;
        }

        .login-container {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 48px 36px;
            width: 420px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
            border: 1px solid rgba(255,255,255,0.5);
            animation: fadeIn 0.4s ease-out;
            position: relative;
            z-index: 1;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        h2 {
            text-align: center;
            color: #1e293b;
            margin-bottom: 36px;
            font-size: 24px;
            font-weight: 700;
            letter-spacing: 1px;
        }

        .form-group {
            margin-bottom: 24px;
        }

        label {
            display: block;
            margin-bottom: 8px;
            color: #475569;
            font-weight: 600;
            font-size: 14px;
        }

        input[type="text"],
        input[type="password"] {
            width: 100%;
            padding: 14px 16px;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            font-size: 15px;
            transition: all 0.25s ease;
            background: rgba(255,255,255,0.95);
        }

        input[type="text"]:focus,
        input[type="password"]:focus {
            outline: none;
            border-color: #1e40af;
            box-shadow: 0 0 0 4px rgba(30, 64, 175, 0.15);
        }

        .role-group {
            display: flex;
            justify-content: space-between;
            margin: 30px 0;
            padding: 0 8px;
        }

        .role-option {
            flex: 1;
            text-align: center;
        }

        .role-option input[type="radio"] {
            margin-right: 6px;
            accent-color: #1e40af;
            transform: scale(1.1);
        }

        .role-option label {
            color: #64748b;
            font-weight: 500;
            cursor: pointer;
            font-size: 14px;
        }

        button {
            width: 100%;
            padding: 16px;
            background: linear-gradient(135deg, #1e3a8a, #1e40af);
            color: white;
            border: none;
            border-radius: 14px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(30, 64, 175, 0.25);
        }

        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(30, 64, 175, 0.35);
        }

        button:active {
            transform: translateY(0);
        }

        .error-message {
            color: #ef4444;
            text-align: center;
            margin-top: 12px;
            font-size: 13px;
            font-weight: 500;
        }

        .footer {
            text-align: center;
            margin-top: 32px;
            color: #64748b;
            font-size: 12px;
            letter-spacing: 0.5px;
        }
    </style>
</head>
<body>
<div class="login-container">
    <h2>考试登录系统</h2>
    <form action="lwmLogin" method="post" onsubmit="return validateForm()">
        <div class="form-group">
            <label>账号：</label>
            <input type="text" name="account" id="account" placeholder="请输入账号" required>
        </div>

        <div class="form-group">
            <label>密码：</label>
            <input type="password" name="password" id="password" placeholder="请输入密码" required>
        </div>

        <div class="role-group">
            <div class="role-option">
                <input type="radio" name="role" value="admin" id="role_admin" checked>
                <label for="role_admin">管理员</label>
            </div>
            <div class="role-option">
                <input type="radio" name="role" value="teacher" id="role_teacher">
                <label for="role_teacher">教师</label>
            </div>
            <div class="role-option">
                <input type="radio" name="role" value="student" id="role_student">
                <label for="role_student">学生</label>
            </div>
        </div>

        <button type="submit">登录</button>
    </form>

    <div class="footer">
        © 2026 考试系统 版权所有
    </div>
</div>

<script>
    function validateForm() {
        var account = document.getElementById("account").value.trim();
        var password = document.getElementById("password").value.trim();

        if (account === "") {
            alert("请输入账号！");
            return false;
        }
        if (password === "") {
            alert("请输入密码！");
            return false;
        }
        return true;
    }
</script>
</body>
</html>