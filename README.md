# 在线考试管理系统（lwmexam）

一个基于 **Servlet + JSP + MySQL** 的校园在线考试管理系统，支持**管理员、教师、学生**三种角色，覆盖题库管理、智能组卷、在线考试、自动/人工阅卷、成绩分析、错题本、知识点分析等完整考试流程，并集成了 **DeepSeek AI 智能分析**能力，可自动生成考试质量分析报告。

---

## 目录

- [项目简介](#项目简介)
- [功能特性](#功能特性)
- [技术栈](#技术栈)
- [系统架构](#系统架构)
- [环境要求](#环境要求)
- [快速开始](#快速开始)
- [默认账号](#默认账号)
- [AI 智能分析](#ai-智能分析)
- [项目结构](#项目结构)
- [常见问题](#常见问题)

---

## 项目简介

本项目是一个面向高校的在线考试管理系统。系统以传统三层架构（JSP → Servlet → DAO → MySQL）构建，无需复杂框架即可运行，适合教学演示、课程设计与中小规模考试场景。

核心能力：

- **多角色权限体系**：管理员、教师、学生三种身份独立登录、独立操作界面。
- **全流程覆盖**：题库建设 → 组卷发布 → 在线考试 → 阅卷评分 → 成绩与学情分析。
- **数据驱动分析**：基于考试数据的成绩分析、试题质量分析、知识点薄弱环节分析。
- **AI 智能报告**：调用 DeepSeek 大模型，一键生成结构化考试质量分析报告。

---

## 功能特性

### 👨‍💼 管理员

- **学生管理**：学生信息增删改查、批量导入导出（Excel）。
- **教师管理**：教师信息增删改查、批量导入导出（Excel）。
- **科目管理**：科目增删改查、批量导入导出（Excel）。
- **课程安排**：班级—科目—教师的排课管理，可查看班级学生名单。

### 👩‍🏫 教师

- **题库管理**：试题增删改查，支持单选题、多选题、判断题、简答题四种题型，试题可关联知识点。
- **知识点管理**：按科目维护知识点，用于学情归因分析。
- **智能组卷**：手工选题组卷，或按规则**随机抽题**自动组卷，可设置各题型数量与分值、考试时长、起止时间、及格线。
- **试卷管理**：试卷编辑、发布/撤销发布，发布后学生可见，已提交的试卷禁止撤销。
- **在线阅卷**：客观题自动评分，主观题（简答题）人工阅卷并填写得分。
- **成绩分析**：成绩分布、及格率、班级横向对比等统计图表。
- **AI 智能分析**：针对单份试卷或指定班级，自动生成"整体成绩—试题质量—知识点薄弱环节—教学改进建议"四段式分析报告。
- **学情分析**：知识点掌握度分析、试题质量（难度/区分度）分析、错题归因分析。

### 🧑‍🎓 学生

- **在线考试**：限时作答，内置**考试时长倒计时**与**答题卡侧边栏**，可快速跳题、标记未答。
- **草稿保存**：考试过程中自动/手动保存草稿，防止意外丢失。
- **成绩查看**：考试结束后查看本人成绩与试卷作答详情。
- **错题本**：自动收录做错的题目，支持复习状态标记。

---

## 技术栈

| 层级 | 技术 |
|------|------|
| 前端 | JSP + HTML + CSS + JavaScript |
| 控制层 | HttpServlet（原生 Servlet，`@WebServlet` 注解） |
| 数据访问层 | DAO 模式 + JDBC（PreparedStatement 防 SQL 注入） |
| 数据库 | MySQL 8.0 |
| 构建工具 | Maven（`war` 打包） |
| 应用服务器 | Tomcat 9 |
| 第三方库 | JExcelApi（Excel 导入导出）、MySQL Connector/J 8.0.17 |
| AI 能力 | DeepSeek API（Anthropic 兼容接口） |

---

## 系统架构

### 三层架构

```
浏览器
   │
   ▼
JSP（视图层：login.jsp / lwm*_index.jsp ...）
   │
   ▼
Action（控制层：com.example.lwmexam.action.lwmexam，共 40+ 个 Servlet）
   │
   ▼
Service（工具层：MysqlConn 数据库连接 / Fpage 分页 / ExcelBook Excel 处理）
   │
   ▼
DAO（数据访问层：com.example.lwmexam.dao.lwmexam）
   │
   ▼
Entity（实体层：与数据表一一对应的 POJO）
   │
   ▼
MySQL 8.0（数据库 lwmexam）
```

### 数据库设计（14 张表）

| 表名 | 用途 |
|------|------|
| `lwmadmin` | 管理员信息 |
| `lwmteacher` | 教师信息 |
| `lwmstudent` | 学生信息 |
| `lwmexamsubject` | 考试科目 |
| `lwmexamquestion` | 试题库（题型、选项、正确答案） |
| `lwmexampaper` | 试卷（题型数量/分值、考试时间、及格线、总分） |
| `lwmpaperquestion` | 试卷—试题关联（多对多中间表） |
| `lwmexamrecord` | 考试记录（开始/结束时间、提交状态） |
| `lwmstudentanswer` | 学生答题详情（每道题的作答与得分） |
| `lwmexamscore` | 成绩表（总分、阅卷教师、评分时间） |
| `lwmstudentcourseteacher` | 班级—科目—教师排课表 |
| `lwmknowledgepoint` | 知识点 |
| `lwmquestionknowledge` | 试题—知识点关联 |
| `lwmmistakebook` | 学生错题本 |

---

## 环境要求

| 软件 | 版本 |
|------|------|
| JDK | 1.8+ |
| Maven | 3.6+ |
| MySQL | 8.0 |
| Tomcat | 9.x |

---

## 快速开始

### 1. 初始化数据库

```bash
# 进入 MySQL，执行项目根目录下的建库脚本
mysql -u root -p < lwmexam.sql
```

脚本会自动创建数据库 `lwmexam` 并导入全部表结构与演示数据。

### 2. 配置数据库连接

数据库连接信息位于 [`src/main/java/com/example/lwmexam/service/lwmexam/MysqlConn.java`](src/main/java/com/example/lwmexam/service/lwmexam/MysqlConn.java)：

```java
String url = "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=gbk&mysqlEncoding=utf8";
String user = "root";
String password = "123456";
```

如果你的 MySQL 账号密码不同，请修改 `user` 与 `password`。

### 3. 配置 AI 分析功能（可选）

AI 智能分析需要设置环境变量 `DEEPSEEK_API_KEY`（[DeepSeek 开放平台](https://platform.deepseek.com/) 申请），未设置时 AI 功能不可用，其余功能不受影响。

```bash
# Windows（cmd）
setx DEEPSEEK_API_KEY "你的API密钥"

# Windows（PowerShell）
$env:DEEPSEEK_API_KEY = "你的API密钥"

# Linux / macOS
export DEEPSEEK_API_KEY="你的API密钥"
```

> 设置后需**重启 Tomcat** 才会生效。

### 4. 打包并部署

```bash
# 打包为 war
mvn clean package

# 将 target/lwmexam.war 复制到 Tomcat 的 webapps 目录
cp target/lwmexam.war $TOMCAT_HOME/webapps/
```

### 5. 启动访问

启动 Tomcat 后，浏览器访问：

```
http://localhost:8080/lwmexam/
```

选择身份（管理员 / 教师 / 学生），输入账号密码即可登录。

---

## 默认账号

> 以下为 `lwmexam.sql` 内置的演示账号，请勿在生产环境使用默认密码。

| 身份 | 账号 | 密码 | 说明 |
|------|------|------|------|
| 管理员 | `123` | `321` | 管理员 `张` |
| 管理员 | `111` | `222` | 管理员 `李` |
| 教师 | `211` | `123` | 工号登录，教师 `lwm` |
| 教师 | `123` | `345` | 工号登录，教师 `夕熙` |
| 学生 | `20230551003` | `111111` | 学号登录，学生 `lxl` |
| 学生 | `20230551009` | `111111` | 学号登录，学生 `lwm` |

---

## AI 智能分析

教师可在"成绩分析"中对试卷（可指定班级）一键生成 AI 分析报告。系统将考试成绩概览、试题作答情况、知识点得分率等结构化数据发送给 DeepSeek 大模型，生成四段式报告：

1. **整体成绩评价**：平均分、及格率、分数分布与波动特点。
2. **试题质量诊断**：识别难度异常、区分度不足的题目并分析成因。
3. **知识点薄弱环节**：定位低于整体得分率的知识点，分析薄弱原因。
4. **教学改进建议**：针对每个薄弱点给出对应的教学干预建议。

---

## 项目结构

```
lwmexam/
├── lwmexam.sql                  # 数据库建库脚本（含演示数据）
├── pom.xml                      # Maven 配置
├── mvnw / mvnw.cmd              # Maven Wrapper
└── src
    └── main
        ├── java/com/example/lwmexam
        │   ├── action/          # 控制层 Servlet（登录、题库、组卷、考试、阅卷、分析等 40+ 类）
        │   ├── service/         # 工具层（MysqlConn 连接、Fpage 分页、ExcelBook）
        │   ├── dao/             # 数据访问层（每张表对应一个 DAO）
        │   └── entity/          # 实体层（与数据表对应的 POJO）
        └── webapp               # JSP 视图页面
            ├── login.jsp        # 登录页
            ├── WEB-INF/
            │   ├── web.xml
            │   └── lib/         # 第三方 jar（jxl、jsmartcom、mysql-connector）
            ├── lwmadmin_*.jsp       # 管理员端页面
            ├── lwmteacher_*.jsp     # 教师端页面
            └── lwmstudent_*.jsp     # 学生端页面
```

---

## 常见问题

**Q：部署后打开页面提示数据库连接失败？**
检查 MySQL 是否已启动、是否已执行 `lwmexam.sql`，并确认 `MysqlConn.java` 中的账号密码与本地一致。

**Q：AI 分析功能提示"未配置 API Key"？**
确认已设置 `DEEPSEEK_API_KEY` 环境变量，并重启 Tomcat。

**Q：打包时报缺少依赖 jar？**
项目将 `jxl`、`jsmartcom_zh_CN`、`mysql-connector-java` 以 `system` 作用域依赖指向 `src/main/webapp/WEB-INF/lib/`，请勿删除该目录下的 jar 文件。

---

*本项目为教学/课程设计用途，数据库连接密码为演示配置，请勿直接用于生产环境。*
