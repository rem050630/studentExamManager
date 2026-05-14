<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>高校在线考试系统 - 管理员控制台</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
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

        .container {
            max-width: 1400px;
            margin: 0 auto;
            width: 100%;
        }

        .module-panel {
            background: transparent;
            animation: fadeInUp 0.5s ease-out;
        }

        .data-card {
            background: rgba(255, 255, 255, 0.96);
            border-radius: 20px;
            box-shadow: 0 10px 25px -15px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            border: 1px solid #eef2f6;
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 22px 28px;
            background: #ffffff;
            border-bottom: 1px solid #eef2f6;
            flex-wrap: wrap;
            gap: 16px;
        }

        .card-header h3 {
            font-size: 22px;
            font-weight: 600;
            color: #1e293b;
            display: inline-flex;
            align-items: center;
            gap: 10px;
        }

        .card-header h3 i {
            color: #3b82f6;
            font-size: 22px;
        }

        .btn-primary {
            background: linear-gradient(100deg, #3b82f6, #2563eb);
            border: none;
            padding: 10px 20px;
            border-radius: 12px;
            font-weight: 600;
            font-size: 14px;
            color: white;
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none !important;
        }

        .btn-primary:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(59, 130, 246, 0.2);
        }

        .data-card table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }

        .data-card thead tr {
            background: #f8fafc;
            border-bottom: 1px solid #e2e8f0;
        }

        .data-card th {
            text-align: left;
            padding: 16px 20px;
            font-weight: 600;
            color: #334155;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.4px;
        }

        .data-card td {
            padding: 16px 20px;
            border-bottom: 1px solid #f0f2f5;
            color: #1e293b;
            vertical-align: middle;
            font-weight: 500;
        }

        .data-card tbody tr:hover {
            background: #f8fafd;
        }

        .action-btn {
            background: transparent;
            border: none;
            padding: 6px 14px;
            margin-right: 6px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none !important;
        }

        .action-btn:first-child {
            background: #eff6ff;
            color: #2563eb;
        }

        .action-btn:first-child:hover {
            background: #dbeafe;
        }

        .action-btn:last-child {
            background: #fef2f2;
            color: #dc2626;
        }

        .action-btn:last-child:hover {
            background: #fee2e2;
        }

        .excel-action-bar {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }

        .export-btn {
            background: #3b82f6;
            color: #fff !important;
            padding: 8px 16px;
            border-radius: 10px;
            text-decoration: none !important;
            font-size: 14px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s;
        }

        .export-btn:hover {
            background: #2563eb;
        }

        .import-form {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .file-upload-btn {
            background: #64748b;
            color: white;
            padding: 8px 16px;
            border-radius: 10px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s;
        }

        .file-upload-btn:hover {
            background: #475569;
        }

        .file-input {
            display: none;
        }

        .import-submit-btn {
            background: #10b981;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 10px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.2s;
        }

        .import-submit-btn:hover {
            background: #059669;
        }

        .file-name {
            padding: 8px 12px;
            font-size: 13px;
            color: #64748b;
            background: #f8fafc;
            border-radius: 8px;
            border: 1px dashed #cbd5e1;
            min-width: 140px;
            text-align: center;
        }

        .search-input {
            height: 36px;
            padding: 0 12px;
            border-radius: 10px;
            border: 1px solid #e2e8f0;
            width: 220px;
            font-size: 14px;
            outline: none;
            transition: all 0.2s;
        }

        .search-input:focus {
            border-color: #3b82f6;
            box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.1);
        }

        .search-btn {
            height: 36px;
            padding: 0 14px;
            border-radius: 10px;
            background: #3b82f6;
            color: white;
            border: none;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.2s;
        }

        .search-btn:hover {
            background: #2563eb;
        }

        .search-form {
            display: flex;
            gap: 8px;
            align-items: center;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @media (max-width: 768px) {
            .card-header {
                padding: 18px 20px;
            }
            .data-card th, .data-card td {
                padding: 14px 16px;
            }
        }
    </style>
</head>
<body>
<div class="container">
    <div class="module-panel">
        <div class="data-card">
            <div class="card-header">
                <h3><i class="fas fa-users"></i> 学生信息列表</h3>

                <div>
                    <div class="excel-action-bar">
                        <a href="lwmstudentExcel" class="export-btn">
                            <i class="fas fa-file-export"></i> 导出学生信息
                        </a>
                        <form action="lwmstudentExcel" method="post" enctype="multipart/form-data" class="import-form">
                            <label class="file-upload-btn">
                                <i class="fas fa-file-import"></i> 选择文件
                                <input name="file" type="file" class="file-input" id="excelFile">
                            </label>
                            <span class="file-name" id="fileName">未选择文件</span>
                            <button type="submit" class="import-submit-btn">导入数据</button>
                        </form>
                        <form action="lwmquerystudent" method="post" class="search-form">
                            <input type="text" name="keyword" class="search-input" placeholder="输入学号/姓名/年级/专业/班级查询" required>
                            <button type="submit" class="search-btn">
                                <i class="fas fa-search"></i> 查询
                            </button>
                        </form>
                    </div>
                </div>
                <a href="lwmaddstudent.jsp" class="btn-primary">+ 添加学生</a>
            </div>

            <table>
                <thead>
                <tr>
                    <th>学号</th>
                    <th>姓名</th>
                    <th>性别</th>
                    <th>年级</th>
                    <th>专业</th>
                    <th>班级</th>
                    <th>操作</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${someStudent}" var="somestu" varStatus="status">
                    <tr>
                        <td>${somestu.lwmstudentno}</td>
                        <td>${somestu.lwmstudentname}</td>
                        <td>${somestu.lwmgender}</td>
                        <td>${somestu.lwmgrade}</td>
                        <td>${somestu.lwmmajor}</td>
                        <td>${somestu.lwmclassname}</td>
                        <td>
                            <a href="lwmUpdatestudent?id=${somestu.lwmstudentid}" class="action-btn">修改</a>
                            <a href="lwmstudentDelete?id=${somestu.lwmstudentid}" class="action-btn" onclick="return confirm('确认删除吗?')">删除</a>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
            <jsp:include page="lwmfoot.jsp"></jsp:include>
        </div>
    </div>
</div>

<script>
    document.getElementById('excelFile').addEventListener('change', function (e) {
        let fileName = e.target.files[0]?.name || '未选择文件';
        document.getElementById('fileName').textContent = fileName;
    });
</script>
</body>
</html>