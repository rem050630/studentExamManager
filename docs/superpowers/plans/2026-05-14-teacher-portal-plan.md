# 教师端功能实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现教师端全部功能——排课查看、题库管理、试卷管理（手动+自动组卷）、学生考试情况查看、客观题自动评分+简答题手动评分

**Architecture:** 沿用现有 `JSP → @WebServlet → DAO → MysqlConn(JDBC)` 三层模式。每个操作一个独立 Servlet，每个表一个 DAO，每个功能模块若干 JSP 页面。

**Tech Stack:** Java 8, javax.servlet 4.0.1, MySQL 8.0, JDBC, JSP, Maven WAR

---

### Task 1: 新建实体类

**Files:**
- Create: `src/main/java/com/example/lwmexam/entity/lwmexam/lwmExamQuestion.java`
- Create: `src/main/java/com/example/lwmexam/entity/lwmexam/lwmExamPaper.java`
- Create: `src/main/java/com/example/lwmexam/entity/lwmexam/lwmExamRecord.java`
- Create: `src/main/java/com/example/lwmexam/entity/lwmexam/lwmStudentAnswer.java`
- Create: `src/main/java/com/example/lwmexam/entity/lwmexam/lwmExamScore.java`

- [ ] **Step 1: 创建 lwmExamQuestion 实体**

```java
package com.example.lwmexam.entity.lwmexam;

public class lwmExamQuestion {
    private int lwmquestionid;
    private int lwmsubjectid;
    private String lwmquestiontype;
    private String lwmquestioncontent;
    private String lwmoptiona;
    private String lwmoptionb;
    private String lwmoptionc;
    private String lwmoptiond;
    private String lwmcorrectanswer;
    private String lwmsubjectname; // 联表查询用

    public int getLwmquestionid() { return lwmquestionid; }
    public void setLwmquestionid(int lwmquestionid) { this.lwmquestionid = lwmquestionid; }
    public int getLwmsubjectid() { return lwmsubjectid; }
    public void setLwmsubjectid(int lwmsubjectid) { this.lwmsubjectid = lwmsubjectid; }
    public String getLwmquestiontype() { return lwmquestiontype; }
    public void setLwmquestiontype(String lwmquestiontype) { this.lwmquestiontype = lwmquestiontype; }
    public String getLwmquestioncontent() { return lwmquestioncontent; }
    public void setLwmquestioncontent(String lwmquestioncontent) { this.lwmquestioncontent = lwmquestioncontent; }
    public String getLwmoptiona() { return lwmoptiona; }
    public void setLwmoptiona(String lwmoptiona) { this.lwmoptiona = lwmoptiona; }
    public String getLwmoptionb() { return lwmoptionb; }
    public void setLwmoptionb(String lwmoptionb) { this.lwmoptionb = lwmoptionb; }
    public String getLwmoptionc() { return lwmoptionc; }
    public void setLwmoptionc(String lwmoptionc) { this.lwmoptionc = lwmoptionc; }
    public String getLwmoptiond() { return lwmoptiond; }
    public void setLwmoptiond(String lwmoptiond) { this.lwmoptiond = lwmoptiond; }
    public String getLwmcorrectanswer() { return lwmcorrectanswer; }
    public void setLwmcorrectanswer(String lwmcorrectanswer) { this.lwmcorrectanswer = lwmcorrectanswer; }
    public String getLwmsubjectname() { return lwmsubjectname; }
    public void setLwmsubjectname(String lwmsubjectname) { this.lwmsubjectname = lwmsubjectname; }
}
```

- [ ] **Step 2: 创建 lwmExamPaper 实体**

```java
package com.example.lwmexam.entity.lwmexam;

public class lwmExamPaper {
    private int lwmpaperid;
    private String lwmpapername;
    private int lwmsubjectid;
    private int lwmexamtime;
    private int lwmexamsore;
    private String lwmstarttime;
    private String lwmendtime;
    private int lwmteacherid;
    private int lwmexamtime;
    private int lwmexamsore;
    private int lwmdanxnum;
    private int lwmdanxscore;
    private String lwmdanxnos;
    private int lwmduoxnum;
    private int lwmduoxscore;
    private String lwmduoxnos;
    private int lwmpdnum;
    private int lwmpdscore;
    private String lwmpdnos;
    private int lwmjdnum;
    private int lwmjdscore;
    private String lwmjdnos;
    private String lwmclassname;
    private String lwmsubjectname;
    private String lwmteachername;

    public int getLwmpaperid() { return lwmpaperid; }
    public void setLwmpaperid(int lwmpaperid) { this.lwmpaperid = lwmpaperid; }
    public String getLwmpapername() { return lwmpapername; }
    public void setLwmpapername(String lwmpapername) { this.lwmpapername = lwmpapername; }
    public int getLwmsubjectid() { return lwmsubjectid; }
    public void setLwmsubjectid(int lwmsubjectid) { this.lwmsubjectid = lwmsubjectid; }
    public int getLwmexamtime() { return lwmexamtime; }
    public void setLwmexamtime(int lwmexamtime) { this.lwmexamtime = lwmexamtime; }
    public int getLwmexamsore() { return lwmexamsore; }
    public void setLwmexamsore(int lwmexamsore) { this.lwmexamsore = lwmexamsore; }
    public String getLwmstarttime() { return lwmstarttime; }
    public void setLwmstarttime(String lwmstarttime) { this.lwmstarttime = lwmstarttime; }
    public String getLwmendtime() { return lwmendtime; }
    public void setLwmendtime(String lwmendtime) { this.lwmendtime = lwmendtime; }
    public int getLwmteacherid() { return lwmteacherid; }
    public void setLwmteacherid(int lwmteacherid) { this.lwmteacherid = lwmteacherid; }
    public int getLwmdanxnum() { return lwmdanxnum; }
    public void setLwmdanxnum(int lwmdanxnum) { this.lwmdanxnum = lwmdanxnum; }
    public int getLwmdanxscore() { return lwmdanxscore; }
    public void setLwmdanxscore(int lwmdanxscore) { this.lwmdanxscore = lwmdanxscore; }
    public String getLwmdanxnos() { return lwmdanxnos; }
    public void setLwmdanxnos(String lwmdanxnos) { this.lwmdanxnos = lwmdanxnos; }
    public int getLwmduoxnum() { return lwmduoxnum; }
    public void setLwmduoxnum(int lwmduoxnum) { this.lwmduoxnum = lwmduoxnum; }
    public int getLwmduoxscore() { return lwmduoxscore; }
    public void setLwmduoxscore(int lwmduoxscore) { this.lwmduoxscore = lwmduoxscore; }
    public String getLwmduoxnos() { return lwmduoxnos; }
    public void setLwmduoxnos(String lwmduoxnos) { this.lwmduoxnos = lwmduoxnos; }
    public int getLwmpdnum() { return lwmpdnum; }
    public void setLwmpdnum(int lwmpdnum) { this.lwmpdnum = lwmpdnum; }
    public int getLwmpdscore() { return lwmpdscore; }
    public void setLwmpdscore(int lwmpdscore) { this.lwmpdscore = lwmpdscore; }
    public String getLwmpdnos() { return lwmpdnos; }
    public void setLwmpdnos(String lwmpdnos) { this.lwmpdnos = lwmpdnos; }
    public int getLwmjdnum() { return lwmjdnum; }
    public void setLwmjdnum(int lwmjdnum) { this.lwmjdnum = lwmjdnum; }
    public int getLwmjdscore() { return lwmjdscore; }
    public void setLwmjdscore(int lwmjdscore) { this.lwmjdscore = lwmjdscore; }
    public String getLwmjdnos() { return lwmjdnos; }
    public void setLwmjdnos(String lwmjdnos) { this.lwmjdnos = lwmjdnos; }
    public String getLwmclassname() { return lwmclassname; }
    public void setLwmclassname(String lwmclassname) { this.lwmclassname = lwmclassname; }
    public String getLwmsubjectname() { return lwmsubjectname; }
    public void setLwmsubjectname(String lwmsubjectname) { this.lwmsubjectname = lwmsubjectname; }
    public String getLwmteachername() { return lwmteachername; }
    public void setLwmteachername(String lwmteachername) { this.lwmteachername = lwmteachername; }
}
```

- [ ] **Step 3: 创建 lwmExamRecord 实体**

```java
package com.example.lwmexam.entity.lwmexam;

public class lwmExamRecord {
    private int lwmrecordid;
    private int lwmpaperid;
    private int lwmstudentid;
    private String lwmstarttime;
    private String lwmendtime;
    private int lwmsubmitstatus;
    private String lwmstudentno;
    private String lwmstudentname;
    private String lwmclassname;
    private String lwmpapername;

    public int getLwmrecordid() { return lwmrecordid; }
    public void setLwmrecordid(int lwmrecordid) { this.lwmrecordid = lwmrecordid; }
    public int getLwmpaperid() { return lwmpaperid; }
    public void setLwmpaperid(int lwmpaperid) { this.lwmpaperid = lwmpaperid; }
    public int getLwmstudentid() { return lwmstudentid; }
    public void setLwmstudentid(int lwmstudentid) { this.lwmstudentid = lwmstudentid; }
    public String getLwmstarttime() { return lwmstarttime; }
    public void setLwmstarttime(String lwmstarttime) { this.lwmstarttime = lwmstarttime; }
    public String getLwmendtime() { return lwmendtime; }
    public void setLwmendtime(String lwmendtime) { this.lwmendtime = lwmendtime; }
    public int getLwmsubmitstatus() { return lwmsubmitstatus; }
    public void setLwmsubmitstatus(int lwmsubmitstatus) { this.lwmsubmitstatus = lwmsubmitstatus; }
    public String getLwmstudentno() { return lwmstudentno; }
    public void setLwmstudentno(String lwmstudentno) { this.lwmstudentno = lwmstudentno; }
    public String getLwmstudentname() { return lwmstudentname; }
    public void setLwmstudentname(String lwmstudentname) { this.lwmstudentname = lwmstudentname; }
    public String getLwmclassname() { return lwmclassname; }
    public void setLwmclassname(String lwmclassname) { this.lwmclassname = lwmclassname; }
    public String getLwmpapername() { return lwmpapername; }
    public void setLwmpapername(String lwmpapername) { this.lwmpapername = lwmpapername; }
}
```

- [ ] **Step 4: 创建 lwmStudentAnswer 实体**

```java
package com.example.lwmexam.entity.lwmexam;

public class lwmStudentAnswer {
    private int lwmanswerid;
    private int lwmrecordid;
    private int lwmquestionid;
    private String lwmstudentanswer;
    private int lwmquestionscore;
    private int lwmstudentid;
    private int lwmpaperid;
    // 联表查询字段
    private String lwmquestiontype;
    private String lwmquestioncontent;
    private String lwmoptiona;
    private String lwmoptionb;
    private String lwmoptionc;
    private String lwmoptiond;
    private String lwmcorrectanswer;
    private int lwmpaperscore;

    public int getLwmanswerid() { return lwmanswerid; }
    public void setLwmanswerid(int lwmanswerid) { this.lwmanswerid = lwmanswerid; }
    public int getLwmrecordid() { return lwmrecordid; }
    public void setLwmrecordid(int lwmrecordid) { this.lwmrecordid = lwmrecordid; }
    public int getLwmquestionid() { return lwmquestionid; }
    public void setLwmquestionid(int lwmquestionid) { this.lwmquestionid = lwmquestionid; }
    public String getLwmstudentanswer() { return lwmstudentanswer; }
    public void setLwmstudentanswer(String lwmstudentanswer) { this.lwmstudentanswer = lwmstudentanswer; }
    public int getLwmquestionscore() { return lwmquestionscore; }
    public void setLwmquestionscore(int lwmquestionscore) { this.lwmquestionscore = lwmquestionscore; }
    public int getLwmstudentid() { return lwmstudentid; }
    public void setLwmstudentid(int lwmstudentid) { this.lwmstudentid = lwmstudentid; }
    public int getLwmpaperid() { return lwmpaperid; }
    public void setLwmpaperid(int lwmpaperid) { this.lwmpaperid = lwmpaperid; }
    public String getLwmquestiontype() { return lwmquestiontype; }
    public void setLwmquestiontype(String lwmquestiontype) { this.lwmquestiontype = lwmquestiontype; }
    public String getLwmquestioncontent() { return lwmquestioncontent; }
    public void setLwmquestioncontent(String lwmquestioncontent) { this.lwmquestioncontent = lwmquestioncontent; }
    public String getLwmoptiona() { return lwmoptiona; }
    public void setLwmoptiona(String lwmoptiona) { this.lwmoptiona = lwmoptiona; }
    public String getLwmoptionb() { return lwmoptionb; }
    public void setLwmoptionb(String lwmoptionb) { this.lwmoptionb = lwmoptionb; }
    public String getLwmoptionc() { return lwmoptionc; }
    public void setLwmoptionc(String lwmoptionc) { this.lwmoptionc = lwmoptionc; }
    public String getLwmoptiond() { return lwmoptiond; }
    public void setLwmoptiond(String lwmoptiond) { this.lwmoptiond = lwmoptiond; }
    public String getLwmcorrectanswer() { return lwmcorrectanswer; }
    public void setLwmcorrectanswer(String lwmcorrectanswer) { this.lwmcorrectanswer = lwmcorrectanswer; }
    public int getLwmpaperscore() { return lwmpaperscore; }
    public void setLwmpaperscore(int lwmpaperscore) { this.lwmpaperscore = lwmpaperscore; }
}
```

- [ ] **Step 5: 创建 lwmExamScore 实体**

```java
package com.example.lwmexam.entity.lwmexam;

public class lwmExamScore {
    private int lwmscoreid;
    private int lwmrecordid;
    private int lwmtotalscore;
    private int lwmteacherid;
    private String lwmscoretime;
    private int lwmstudentid;
    private int lwmpaperid;
    // 联表查询字段
    private String lwmstudentno;
    private String lwmstudentname;
    private String lwmpapername;

    public int getLwmscoreid() { return lwmscoreid; }
    public void setLwmscoreid(int lwmscoreid) { this.lwmscoreid = lwmscoreid; }
    public int getLwmrecordid() { return lwmrecordid; }
    public void setLwmrecordid(int lwmrecordid) { this.lwmrecordid = lwmrecordid; }
    public int getLwmtotalscore() { return lwmtotalscore; }
    public void setLwmtotalscore(int lwmtotalscore) { this.lwmtotalscore = lwmtotalscore; }
    public int getLwmteacherid() { return lwmteacherid; }
    public void setLwmteacherid(int lwmteacherid) { this.lwmteacherid = lwmteacherid; }
    public String getLwmscoretime() { return lwmscoretime; }
    public void setLwmscoretime(String lwmscoretime) { this.lwmscoretime = lwmscoretime; }
    public int getLwmstudentid() { return lwmstudentid; }
    public void setLwmstudentid(int lwmstudentid) { this.lwmstudentid = lwmstudentid; }
    public int getLwmpaperid() { return lwmpaperid; }
    public void setLwmpaperid(int lwmpaperid) { this.lwmpaperid = lwmpaperid; }
    public String getLwmstudentno() { return lwmstudentno; }
    public void setLwmstudentno(String lwmstudentno) { this.lwmstudentno = lwmstudentno; }
    public String getLwmstudentname() { return lwmstudentname; }
    public void setLwmstudentname(String lwmstudentname) { this.lwmstudentname = lwmstudentname; }
    public String getLwmpapername() { return lwmpapername; }
    public void setLwmpapername(String lwmpapername) { this.lwmpapername = lwmpapername; }
}
```

- [ ] **Step 6: 编译验证**

```bash
cd "D:\Java\IdeaProjects\lwmexam" && mvn compile
```

---

### Task 2: 数据库迁移——lwmexampaper 字段修正

- [ ] **Step 1: 执行 ALTER TABLE**

在 MySQL 中执行：
```sql
-- 修正列名：lwnexamtime -> lwmexamtime
ALTER TABLE lwmexampaper CHANGE COLUMN lwnexamtime lwmexamtime int NOT NULL COMMENT '考试时长（分钟）';

-- 新增总分列
ALTER TABLE lwmexampaper ADD COLUMN lwmexamsore int DEFAULT 0 COMMENT '试卷总分' AFTER lwmexamtime;

-- 新增班级列
ALTER TABLE lwmexampaper ADD COLUMN lwmclassname varchar(50) DEFAULT '' COMMENT '分配班级' AFTER lwmteacherid;
```

- [ ] **Step 2: 验证字段**

```sql
DESC lwmexampaper;
```

确认 `lwmexamtime`、`lwmexamsore`、`lwmclassname` 三个字段存在且位置正确。

---

### Task 3: 新建 lwmquestionDAO（题库 CRUD + 随机抽取）

**Files:**
- Create: `src/main/java/com/example/lwmexam/dao/lwmexam/lwmquestionDAO.java`

- [ ] **Step 1: 创建 lwmquestionDAO**

```java
package com.example.lwmexam.dao.lwmexam;

import com.example.lwmexam.entity.lwmexam.lwmExamQuestion;
import com.example.lwmexam.service.lwmexam.MysqlConn;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class lwmquestionDAO {
    MysqlConn db = new MysqlConn();
    ResultSet rs = null;
    int res = 0;

    // 通用查询
    private List<lwmExamQuestion> lwmQuerySomeQuestion(String sql, Object[] param) {
        List<lwmExamQuestion> list = new ArrayList<>();
        try {
            rs = db.doQuery(sql, param);
            while (rs.next()) {
                lwmExamQuestion q = new lwmExamQuestion();
                q.setLwmquestionid(rs.getInt("lwmquestionid"));
                q.setLwmsubjectid(rs.getInt("lwmsubjectid"));
                q.setLwmquestiontype(rs.getString("lwmquestiontype"));
                q.setLwmquestioncontent(rs.getString("lwmquestioncontent"));
                q.setLwmoptiona(rs.getString("lwmoptiona"));
                q.setLwmoptionb(rs.getString("lwmoptionb"));
                q.setLwmoptionc(rs.getString("lwmoptionc"));
                q.setLwmoptiond(rs.getString("lwmoptiond"));
                q.setLwmcorrectanswer(rs.getString("lwmcorrectanswer"));
                try { q.setLwmsubjectname(rs.getString("lwmsubjectname")); } catch (SQLException ignored) {}
                list.add(q);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        db.close();
        return list;
    }

    // 按科目+题型+关键字查询（教师只能看自己排课科目的题目）
    public List<lwmExamQuestion> lwmQueryBySubjectType(String subjectIds, String questiontype, String keyword) {
        StringBuilder sql = new StringBuilder(
            "SELECT q.*, s.lwmsubjectname FROM lwmexamquestion q " +
            "LEFT JOIN lwmexamsubject s ON q.lwmsubjectid = s.lwmsubjectid WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (subjectIds != null && !subjectIds.isEmpty()) {
            sql.append("AND q.lwmsubjectid IN (").append(subjectIds).append(") ");
        }
        if (questiontype != null && !questiontype.isEmpty()) {
            sql.append("AND q.lwmquestiontype = ? ");
            params.add(questiontype);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND q.lwmquestioncontent LIKE ? ");
            params.add("%" + keyword.trim() + "%");
        }
        sql.append("ORDER BY q.lwmquestionid DESC");
        return lwmQuerySomeQuestion(sql.toString(), params.toArray());
    }

    // 添加试题
    public int lwmAddQuestion(lwmExamQuestion q) {
        res = db.doUpdate(
            "INSERT INTO lwmexamquestion(lwmsubjectid,lwmquestiontype,lwmquestioncontent,lwmoptiona,lwmoptionb,lwmoptionc,lwmoptiond,lwmcorrectanswer) VALUES(?,?,?,?,?,?,?,?)",
            new Object[]{q.getLwmsubjectid(), q.getLwmquestiontype(), q.getLwmquestioncontent(),
                    q.getLwmoptiona(), q.getLwmoptionb(), q.getLwmoptionc(), q.getLwmoptiond(), q.getLwmcorrectanswer()});
        db.close();
        return res;
    }

    // 按ID查单个试题
    public lwmExamQuestion lwmQueryById(int id) {
        List<lwmExamQuestion> list = lwmQuerySomeQuestion(
            "SELECT q.*, s.lwmsubjectname FROM lwmexamquestion q LEFT JOIN lwmexamsubject s ON q.lwmsubjectid = s.lwmsubjectid WHERE q.lwmquestionid = ?",
            new Object[]{id});
        return list.isEmpty() ? null : list.get(0);
    }

    // 更新试题
    public int lwmUpdateQuestion(lwmExamQuestion q) {
        res = db.doUpdate(
            "UPDATE lwmexamquestion SET lwmsubjectid=?,lwmquestiontype=?,lwmquestioncontent=?,lwmoptiona=?,lwmoptionb=?,lwmoptionc=?,lwmoptiond=?,lwmcorrectanswer=? WHERE lwmquestionid=?",
            new Object[]{q.getLwmsubjectid(), q.getLwmquestiontype(), q.getLwmquestioncontent(),
                    q.getLwmoptiona(), q.getLwmoptionb(), q.getLwmoptionc(), q.getLwmoptiond(),
                    q.getLwmcorrectanswer(), q.getLwmquestionid()});
        db.close();
        return res;
    }

    // 删除试题
    public int lwmDeleteQuestion(int id) {
        res = db.doUpdate("DELETE FROM lwmexamquestion WHERE lwmquestionid = ?", new Object[]{id});
        db.close();
        return res;
    }

    // 自动组卷：按科目+题型随机抽取 N 道不重复的题
    public List<lwmExamQuestion> lwmRandomPick(int subjectId, String questiontype, int count) {
        return lwmQuerySomeQuestion(
            "SELECT q.*, s.lwmsubjectname FROM lwmexamquestion q " +
            "LEFT JOIN lwmexamsubject s ON q.lwmsubjectid = s.lwmsubjectid " +
            "WHERE q.lwmsubjectid = ? AND q.lwmquestiontype = ? ORDER BY RAND() LIMIT ?",
            new Object[]{subjectId, questiontype, count});
    }

    // 按科目获取各题型数量
    public int lwmCountByType(int subjectId, String questiontype) {
        int count = 0;
        try {
            rs = db.doQuery(
                "SELECT COUNT(*) FROM lwmexamquestion WHERE lwmsubjectid = ? AND lwmquestiontype = ?",
                new Object[]{subjectId, questiontype});
            if (rs.next()) count = rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        db.close();
        return count;
    }
}
```

- [ ] **Step 2: 编译验证**

```bash
cd "D:\Java\IdeaProjects\lwmexam" && mvn compile
```

---

### Task 4: 新建 lwmpaperDAO（试卷 CRUD + 试题关联）

**Files:**
- Create: `src/main/java/com/example/lwmexam/dao/lwmexam/lwmpaperDAO.java`

- [ ] **Step 1: 创建 lwmpaperDAO**

```java
package com.example.lwmexam.dao.lwmexam;

import com.example.lwmexam.entity.lwmexam.lwmExamPaper;
import com.example.lwmexam.service.lwmexam.MysqlConn;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class lwmpaperDAO {
    MysqlConn db = new MysqlConn();
    ResultSet rs = null;
    int res = 0;

    // 通用查询
    private List<lwmExamPaper> lwmQuerySomePaper(String sql, Object[] param) {
        List<lwmExamPaper> list = new ArrayList<>();
        try {
            rs = db.doQuery(sql, param);
            while (rs.next()) {
                lwmExamPaper p = new lwmExamPaper();
                p.setLwmpaperid(rs.getInt("lwmpaperid"));
                p.setLwmpapername(rs.getString("lwmpapername"));
                p.setLwmsubjectid(rs.getInt("lwmsubjectid"));
                p.setLwmexamtime(rs.getInt("lwmexamtime"));
                p.setLwmexamsore(rs.getInt("lwmexamsore"));
                p.setLwmstarttime(rs.getString("lwmstarttime"));
                p.setLwmendtime(rs.getString("lwmendtime"));
                p.setLwmteacherid(rs.getInt("lwmteacherid"));
                p.setLwmclassname(rs.getString("lwmclassname"));
                p.setLwmdanxnum(rs.getInt("lwmdanxnum"));
                p.setLwmdanxscore(rs.getInt("lwmdanxscore"));
                p.setLwmdanxnos(rs.getString("lwmdanxnos"));
                p.setLwmduoxnum(rs.getInt("lwmduoxnum"));
                p.setLwmduoxscore(rs.getInt("lwmduoxscore"));
                p.setLwmduoxnos(rs.getString("lwmduoxnos"));
                p.setLwmpdnum(rs.getInt("lwmpdnum"));
                p.setLwmpdscore(rs.getInt("lwmpdscore"));
                p.setLwmpdnos(rs.getString("lwmpdnos"));
                p.setLwmjdnum(rs.getInt("lwmjdnum"));
                p.setLwmjdscore(rs.getInt("lwmjdscore"));
                p.setLwmjdnos(rs.getString("lwmjdnos"));
                try { p.setLwmsubjectname(rs.getString("lwmsubjectname")); } catch (SQLException ignored) {}
                try { p.setLwmteachername(rs.getString("lwmteachername")); } catch (SQLException ignored) {}
                list.add(p);
            }
        } catch (Exception e) { e.printStackTrace(); }
        db.close();
        return list;
    }

    // 按教师ID查询试卷列表
    public List<lwmExamPaper> lwmQueryByTeacher(int teacherId) {
        return lwmQuerySomePaper(
            "SELECT p.*, s.lwmsubjectname FROM lwmexampaper p " +
            "LEFT JOIN lwmexamsubject s ON p.lwmsubjectid = s.lwmsubjectid " +
            "WHERE p.lwmteacherid = ? ORDER BY p.lwmpaperid DESC",
            new Object[]{teacherId});
    }

    // 新增试卷（返回自增ID）
    public int lwmAddPaper(lwmExamPaper p) {
        res = db.doUpdate(
            "INSERT INTO lwmexampaper(lwmpapername,lwmsubjectid,lwmexamtime,lwmexamsore,lwmstarttime,lwmendtime,lwmteacherid,lwmclassname,lwmdanxnum,lwmdanxscore,lwmdanxnos,lwmduoxnum,lwmduoxscore,lwmduoxnos,lwmpdnum,lwmpdscore,lwmpdnos,lwmjdnum,lwmjdscore,lwmjdnos) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            new Object[]{p.getLwmpapername(),p.getLwmsubjectid(),p.getLwmexamtime(),p.getLwmexamsore(),p.getLwmstarttime(),p.getLwmendtime(),p.getLwmteacherid(),p.getLwmclassname(),p.getLwmdanxnum(),p.getLwmdanxscore(),p.getLwmdanxnos(),p.getLwmduoxnum(),p.getLwmduoxscore(),p.getLwmduoxnos(),p.getLwmpdnum(),p.getLwmpdscore(),p.getLwmpdnos(),p.getLwmjdnum(),p.getLwmjdscore(),p.getLwmjdnos()});
        int paperId = 0;
        try {
            rs = db.doQuery("SELECT LAST_INSERT_ID()", new Object[]{});
            if (rs.next()) paperId = rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        db.close();
        return paperId;
    }

    // 关联试题到试卷
    public void lwmAddPaperQuestion(int paperId, int questionId) {
        db.doUpdate("INSERT INTO lwmpaperquestion(lwmpaperid,lwmquestionid) VALUES(?,?)",
                new Object[]{paperId, questionId});
        db.close();
    }

    // 获取试卷的试题ID列表
    public List<Integer> lwmGetPaperQuestionIds(int paperId) {
        List<Integer> ids = new ArrayList<>();
        try {
            rs = db.doQuery("SELECT lwmquestionid FROM lwmpaperquestion WHERE lwmpaperid = ?", new Object[]{paperId});
            while (rs.next()) ids.add(rs.getInt("lwmquestionid"));
        } catch (Exception e) { e.printStackTrace(); }
        db.close();
        return ids;
    }

    // 按ID查询试卷
    public lwmExamPaper lwmQueryPaperById(int paperId) {
        List<lwmExamPaper> list = lwmQuerySomePaper(
            "SELECT p.*, s.lwmsubjectname FROM lwmexampaper p " +
            "LEFT JOIN lwmexamsubject s ON p.lwmsubjectid = s.lwmsubjectid WHERE p.lwmpaperid = ?",
            new Object[]{paperId});
        return list.isEmpty() ? null : list.get(0);
    }

    // 更新试卷
    public int lwmUpdatePaper(lwmExamPaper p) {
        res = db.doUpdate(
            "UPDATE lwmexampaper SET lwmpapername=?,lwmsubjectid=?,lwmexamtime=?,lwmexamsore=?,lwmstarttime=?,lwmendtime=?,lwmclassname=? WHERE lwmpaperid=?",
            new Object[]{p.getLwmpapername(),p.getLwmsubjectid(),p.getLwmexamtime(),p.getLwmexamsore(),p.getLwmstarttime(),p.getLwmendtime(),p.getLwmclassname(),p.getLwmpaperid()});
        db.close();
        return res;
    }

    // 删除试卷关联试题
    public void lwmDeletePaperQuestions(int paperId) {
        db.doUpdate("DELETE FROM lwmpaperquestion WHERE lwmpaperid = ?", new Object[]{paperId});
        db.close();
    }

    // 删除试卷
    public int lwmDeletePaper(int paperId) {
        lwmDeletePaperQuestions(paperId);
        res = db.doUpdate("DELETE FROM lwmexampaper WHERE lwmpaperid = ?", new Object[]{paperId});
        db.close();
        return res;
    }

    // 检查试卷是否有学生提交记录
    public boolean hasSubmitRecord(int paperId) {
        boolean has = false;
        try {
            rs = db.doQuery(
                "SELECT COUNT(*) FROM lwmexamrecord WHERE lwmpaperid = ? AND lwmsubmitstatus = 1",
                new Object[]{paperId});
            if (rs.next()) has = rs.getInt(1) > 0;
        } catch (Exception e) { e.printStackTrace(); }
        db.close();
        return has;
    }
}
```

- [ ] **Step 2: 编译验证**

```bash
cd "D:\Java\IdeaProjects\lwmexam" && mvn compile
```

---

### Task 5: 新建 lwmscoreDAO（评分与成绩）

**Files:**
- Create: `src/main/java/com/example/lwmexam/dao/lwmexam/lwmscoreDAO.java`

- [ ] **Step 1: 创建 lwmscoreDAO**

```java
package com.example.lwmexam.dao.lwmexam;

import com.example.lwmexam.entity.lwmexam.lwmExamScore;
import com.example.lwmexam.entity.lwmexam.lwmStudentAnswer;
import com.example.lwmexam.service.lwmexam.MysqlConn;

import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class lwmscoreDAO {
    MysqlConn db = new MysqlConn();
    ResultSet rs = null;
    int res = 0;

    // 查询某条考试记录的答题详情（联表试题信息）
    public List<lwmStudentAnswer> lwmQueryAnswersByRecord(int recordId) {
        List<lwmStudentAnswer> list = new ArrayList<>();
        try {
            rs = db.doQuery(
                "SELECT sa.*, q.lwmquestiontype, q.lwmquestioncontent, q.lwmoptiona, q.lwmoptionb, q.lwmoptionc, q.lwmoptiond, q.lwmcorrectanswer " +
                "FROM lwmstudentanswer sa " +
                "JOIN lwmexamquestion q ON sa.lwmquestionid = q.lwmquestionid " +
                "WHERE sa.lwmrecordid = ?", new Object[]{recordId});
            while (rs.next()) {
                lwmStudentAnswer a = new lwmStudentAnswer();
                a.setLwmanswerid(rs.getInt("lwmanswerid"));
                a.setLwmrecordid(rs.getInt("lwmrecordid"));
                a.setLwmquestionid(rs.getInt("lwmquestionid"));
                a.setLwmstudentanswer(rs.getString("lwmstudentanswer"));
                a.setLwmquestionscore(rs.getInt("lwmquestionscore"));
                a.setLwmstudentid(rs.getInt("lwmstudentid"));
                a.setLwmpaperid(rs.getInt("lwmpaperid"));
                a.setLwmquestiontype(rs.getString("lwmquestiontype"));
                a.setLwmquestioncontent(rs.getString("lwmquestioncontent"));
                a.setLwmoptiona(rs.getString("lwmoptiona"));
                a.setLwmoptionb(rs.getString("lwmoptionb"));
                a.setLwmoptionc(rs.getString("lwmoptionc"));
                a.setLwmoptiond(rs.getString("lwmoptiond"));
                a.setLwmcorrectanswer(rs.getString("lwmcorrectanswer"));
                list.add(a);
            }
        } catch (Exception e) { e.printStackTrace(); }
        db.close();
        return list;
    }

    // 保存单题得分
    public void lwmSaveQuestionScore(int answerId, int score) {
        db.doUpdate("UPDATE lwmstudentanswer SET lwmquestionscore = ? WHERE lwmanswerid = ?",
                new Object[]{score, answerId});
        db.close();
    }

    // 创建或更新成绩记录
    public int lwmSaveScore(lwmExamScore score) {
        res = db.doUpdate(
            "INSERT INTO lwmexamscore(lwmrecordid,lwmtotalscore,lwmteacherid,lwmstudentid,lwmpaperid) " +
            "VALUES(?,?,?,?,?) ON DUPLICATE KEY UPDATE lwmtotalscore=?,lwmteacherid=?",
            new Object[]{score.getLwmrecordid(),score.getLwmtotalscore(),score.getLwmteacherid(),score.getLwmstudentid(),score.getLwmpaperid(),score.getLwmtotalscore(),score.getLwmteacherid()});
        db.close();
        return res;
    }
}
```

- [ ] **Step 2: 编译验证**

```bash
cd "D:\Java\IdeaProjects\lwmexam" && mvn compile
```

---

### Task 6: 教师排课查看 Servlet + JSP

**Files:**
- Create: `src/main/java/com/example/lwmexam/action/lwmexam/lwmQueryTeacherCourses.java`
- Create: `src/main/webapp/lwmteacher_courses.jsp`

- [ ] **Step 1: 创建 lwmQueryTeacherCourses Servlet**

```java
package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmCourseArrangeDAO;
import com.example.lwmexam.entity.lwmexam.lwmTeacher;
import com.example.lwmexam.entity.lwmexam.lwmstudentcourseteacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/lwmQueryTeacherCourses")
public class lwmQueryTeacherCourses extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");

        if (teacher == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        lwmCourseArrangeDAO dao = new lwmCourseArrangeDAO();
        String keyword = request.getParameter("keyword");
        String sql;
        Object[] params;

        if (keyword != null && !keyword.trim().isEmpty()) {
            String likeKey = "%" + keyword.trim() + "%";
            sql = "SELECT sct.*, sub.lwmsubjectname, tea.lwmteachername " +
                  "FROM lwmstudentcourseteacher sct " +
                  "LEFT JOIN lwmexamsubject sub ON sct.lwmsubjectid = sub.lwmsubjectid " +
                  "LEFT JOIN lwmteacher tea ON sct.lwmteacherid = tea.lwmteacherid " +
                  "WHERE sct.lwmteacherid = ? AND (sct.lwmclassname LIKE ? OR sub.lwmsubjectname LIKE ?)";
            params = new Object[]{teacher.getLwmteacherid(), likeKey, likeKey};
        } else {
            sql = "SELECT sct.*, sub.lwmsubjectname, tea.lwmteachername " +
                  "FROM lwmstudentcourseteacher sct " +
                  "LEFT JOIN lwmexamsubject sub ON sct.lwmsubjectid = sub.lwmsubjectid " +
                  "LEFT JOIN lwmteacher tea ON sct.lwmteacherid = tea.lwmteacherid " +
                  "WHERE sct.lwmteacherid = ?";
            params = new Object[]{teacher.getLwmteacherid()};
        }

        List<lwmstudentcourseteacher> courses = dao.lwmQuerySomeSct(sql, params);
        request.setAttribute("courses", courses);
        request.getRequestDispatcher("lwmteacher_courses.jsp").forward(request, response);
    }
}
```

- [ ] **Step 2: 创建 lwmteacher_courses.jsp**

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmstudentcourseteacher" %>
<%
    List<lwmstudentcourseteacher> courses = (List<lwmstudentcourseteacher>) request.getAttribute("courses");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>我的排课</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; padding:24px; }
        .container { max-width:1100px; margin:0 auto; }
        .header { display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; }
        .header h2 { color:#1e293b; font-size:1.5rem; }
        .search-box input { padding:8px 16px; border:1px solid #e2e8f0; border-radius:8px; width:260px; font-size:0.9rem; }
        .search-box button { padding:8px 20px; background:#059669; color:white; border:none; border-radius:8px; cursor:pointer; margin-left:8px; }
        table { width:100%; background:white; border-radius:12px; overflow:hidden; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        th { background:#f8fafc; padding:14px 18px; text-align:left; font-weight:600; color:#475569; font-size:0.85rem; border-bottom:1px solid #e2e8f0; }
        td { padding:14px 18px; border-bottom:1px solid #f1f5f9; color:#334155; font-size:0.9rem; }
        tr:hover { background:#f8fafc; }
        .empty { text-align:center; padding:40px; color:#94a3b8; }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <h2>我的排课</h2>
        <form class="search-box" method="get" action="lwmQueryTeacherCourses">
            <input type="text" name="keyword" placeholder="搜索班级或科目..." value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>">
            <button type="submit">搜索</button>
        </form>
    </div>
    <table>
        <thead>
            <tr><th>序号</th><th>班级</th><th>科目</th><th>学期</th></tr>
        </thead>
        <tbody>
            <% if (courses != null && !courses.isEmpty()) {
                int i = 1;
                for (lwmstudentcourseteacher c : courses) { %>
                    <tr>
                        <td><%= i++ %></td>
                        <td><%= c.getLwmclassname() %></td>
                        <td><%= c.getLwmsubjectname() %></td>
                        <td><%= c.getLwmsemester() %></td>
                    </tr>
                <% }
            } else { %>
                <tr><td colspan="4" class="empty">暂无排课记录</td></tr>
            <% } %>
        </tbody>
    </table>
</div>
</body>
</html>
```

- [ ] **Step 3: 编译验证**

```bash
cd "D:\Java\IdeaProjects\lwmexam" && mvn compile
```

---

### Task 7: 题库管理 Servlet（添加/查询/编辑/删除）+ JSP

**Files:**
- Create: `src/main/java/com/example/lwmexam/action/lwmexam/lwmAddQuestion.java`
- Create: `src/main/java/com/example/lwmexam/action/lwmexam/lwmQueryQuestion.java`
- Create: `src/main/java/com/example/lwmexam/action/lwmexam/lwmUpdateQuestion.java`
- Create: `src/main/java/com/example/lwmexam/action/lwmexam/lwmDeleteQuestion.java`
- Create: `src/main/webapp/lwmteacher_question_list.jsp`
- Create: `src/main/webapp/lwmteacher_question_add.jsp`

- [ ] **Step 1: 创建 lwmAddQuestion Servlet**

```java
package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmquestionDAO;
import com.example.lwmexam.entity.lwmexam.lwmExamQuestion;
import com.example.lwmexam.entity.lwmexam.lwmTeacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/lwmAddQuestion")
public class lwmAddQuestion extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        PrintWriter out = response.getWriter();

        if (teacher == null) {
            out.println("<script>alert('请先登录');location.href='login.jsp';</script>");
            return;
        }

        lwmExamQuestion q = new lwmExamQuestion();
        q.setLwmsubjectid(Integer.parseInt(request.getParameter("lwmsubjectid")));
        q.setLwmquestiontype(request.getParameter("lwmquestiontype"));
        q.setLwmquestioncontent(request.getParameter("lwmquestioncontent"));
        q.setLwmoptiona(request.getParameter("lwmoptiona") != null ? request.getParameter("lwmoptiona") : "");
        q.setLwmoptionb(request.getParameter("lwmoptionb") != null ? request.getParameter("lwmoptionb") : "");
        q.setLwmoptionc(request.getParameter("lwmoptionc") != null ? request.getParameter("lwmoptionc") : "");
        q.setLwmoptiond(request.getParameter("lwmoptiond") != null ? request.getParameter("lwmoptiond") : "");
        q.setLwmcorrectanswer(request.getParameter("lwmcorrectanswer"));

        lwmquestionDAO dao = new lwmquestionDAO();
        int res = dao.lwmAddQuestion(q);
        if (res > 0) {
            out.println("<script>alert('添加成功');location.href='lwmQueryQuestion';</script>");
        } else {
            out.println("<script>alert('添加失败');history.go(-1);</script>");
        }
    }
}
```

- [ ] **Step 2: 创建 lwmQueryQuestion Servlet**

```java
package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmCourseArrangeDAO;
import com.example.lwmexam.dao.lwmexam.lwmquestionDAO;
import com.example.lwmexam.entity.lwmexam.lwmExamQuestion;
import com.example.lwmexam.entity.lwmexam.lwmTeacher;
import com.example.lwmexam.entity.lwmexam.lwmstudentcourseteacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/lwmQueryQuestion")
public class lwmQueryQuestion extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");

        if (teacher == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        lwmCourseArrangeDAO arrangeDao = new lwmCourseArrangeDAO();
        List<lwmstudentcourseteacher> courses = arrangeDao.lwmQuerySomeSct(
            "SELECT * FROM lwmstudentcourseteacher WHERE lwmteacherid = ?",
            new Object[]{teacher.getLwmteacherid()});

        String subjectIds = courses.stream()
            .map(c -> String.valueOf(c.getLwmsubjectid()))
            .distinct()
            .collect(Collectors.joining(","));

        String questiontype = request.getParameter("questiontype");
        String keyword = request.getParameter("keyword");

        lwmquestionDAO dao = new lwmquestionDAO();
        List<lwmExamQuestion> questions = dao.lwmQueryBySubjectType(
            subjectIds.isEmpty() ? null : subjectIds, questiontype, keyword);

        request.setAttribute("questions", questions);
        request.setAttribute("courses", courses);
        request.setAttribute("questiontype", questiontype);
        request.setAttribute("keyword", keyword);
        request.getRequestDispatcher("lwmteacher_question_list.jsp").forward(request, response);
    }
}
```

- [ ] **Step 3: 创建 lwmUpdateQuestion Servlet**

```java
package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmquestionDAO;
import com.example.lwmexam.entity.lwmexam.lwmExamQuestion;
import com.example.lwmexam.entity.lwmexam.lwmTeacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/lwmUpdateQuestion")
public class lwmUpdateQuestion extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("id");
        lwmquestionDAO dao = new lwmquestionDAO();
        lwmExamQuestion q = dao.lwmQueryById(Integer.parseInt(id));
        request.setAttribute("question", q);
        request.getRequestDispatcher("lwmteacher_question_add.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        lwmExamQuestion q = new lwmExamQuestion();
        q.setLwmquestionid(Integer.parseInt(request.getParameter("lwmquestionid")));
        q.setLwmsubjectid(Integer.parseInt(request.getParameter("lwmsubjectid")));
        q.setLwmquestiontype(request.getParameter("lwmquestiontype"));
        q.setLwmquestioncontent(request.getParameter("lwmquestioncontent"));
        q.setLwmoptiona(request.getParameter("lwmoptiona") != null ? request.getParameter("lwmoptiona") : "");
        q.setLwmoptionb(request.getParameter("lwmoptionb") != null ? request.getParameter("lwmoptionb") : "");
        q.setLwmoptionc(request.getParameter("lwmoptionc") != null ? request.getParameter("lwmoptionc") : "");
        q.setLwmoptiond(request.getParameter("lwmoptiond") != null ? request.getParameter("lwmoptiond") : "");
        q.setLwmcorrectanswer(request.getParameter("lwmcorrectanswer"));

        lwmquestionDAO dao = new lwmquestionDAO();
        int res = dao.lwmUpdateQuestion(q);
        if (res > 0) {
            out.println("<script>alert('修改成功');location.href='lwmQueryQuestion';</script>");
        } else {
            out.println("<script>alert('修改失败');history.go(-1);</script>");
        }
    }
}
```

- [ ] **Step 4: 创建 lwmDeleteQuestion Servlet**

```java
package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmquestionDAO;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/lwmDeleteQuestion")
public class lwmDeleteQuestion extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        lwmquestionDAO dao = new lwmquestionDAO();
        int res = dao.lwmDeleteQuestion(id);
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        if (res > 0) {
            out.println("<script>alert('删除成功');location.href='lwmQueryQuestion';</script>");
        } else {
            out.println("<script>alert('删除失败');history.go(-1);</script>");
        }
    }
}
```

- [ ] **Step 5: 创建 lwmteacher_question_list.jsp**

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmExamQuestion" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmstudentcourseteacher" %>
<%@ page import="java.util.stream.Collectors" %>
<%
    List<lwmExamQuestion> questions = (List<lwmExamQuestion>) request.getAttribute("questions");
    List<lwmstudentcourseteacher> courses = (List<lwmstudentcourseteacher>) request.getAttribute("courses");
    String questiontype = (String) request.getAttribute("questiontype");
    String keyword = (String) request.getAttribute("keyword");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>题库管理</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; padding:24px; }
        .container { max-width:1200px; margin:0 auto; }
        .header { display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; }
        .header h2 { color:#1e293b; font-size:1.5rem; }
        .btn { padding:8px 20px; border-radius:8px; cursor:pointer; text-decoration:none; font-size:0.9rem; border:none; display:inline-block; }
        .btn-primary { background:#059669; color:white; }
        .btn-edit { background:#3b82f6; color:white; padding:6px 14px; border-radius:6px; text-decoration:none; font-size:0.8rem; margin-right:6px; }
        .btn-delete { background:#ef4444; color:white; padding:6px 14px; border-radius:6px; text-decoration:none; font-size:0.8rem; }
        .filter-bar { display:flex; gap:12px; margin-bottom:20px; align-items:center; }
        .filter-bar select, .filter-bar input { padding:8px 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.9rem; }
        .filter-bar button { padding:8px 20px; background:#059669; color:white; border:none; border-radius:8px; cursor:pointer; }
        table { width:100%; background:white; border-radius:12px; overflow:hidden; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        th { background:#f8fafc; padding:12px 14px; text-align:left; font-weight:600; color:#475569; font-size:0.85rem; }
        td { padding:10px 14px; border-bottom:1px solid #f1f5f9; color:#334155; font-size:0.85rem; }
        tr:hover { background:#f8fafc; }
        .content { max-width:300px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
        .empty { text-align:center; padding:40px; color:#94a3b8; }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <h2>题库管理</h2>
        <a href="lwmteacher_question_add.jsp" class="btn btn-primary">+ 添加试题</a>
    </div>
    <form class="filter-bar" method="get" action="lwmQueryQuestion">
        <select name="questiontype">
            <option value="">全部题型</option>
            <option value="单选题" <%= "单选题".equals(questiontype) ? "selected" : "" %>>单选题</option>
            <option value="多选题" <%= "多选题".equals(questiontype) ? "selected" : "" %>>多选题</option>
            <option value="判断题" <%= "判断题".equals(questiontype) ? "selected" : "" %>>判断题</option>
            <option value="简答题" <%= "简答题".equals(questiontype) ? "selected" : "" %>>简答题</option>
        </select>
        <input type="text" name="keyword" placeholder="搜索题目内容..." value="<%= keyword != null ? keyword : "" %>">
        <button type="submit">筛选</button>
    </form>
    <table>
        <thead>
            <tr><th>序号</th><th>科目</th><th>题型</th><th>题目内容</th><th>正确答案</th><th>操作</th></tr>
        </thead>
        <tbody>
            <% if (questions != null && !questions.isEmpty()) {
                int i = 1;
                for (lwmExamQuestion q : questions) { %>
                    <tr>
                        <td><%= i++ %></td>
                        <td><%= q.getLwmsubjectname() != null ? q.getLwmsubjectname() : q.getLwmsubjectid() %></td>
                        <td><%= q.getLwmquestiontype() %></td>
                        <td class="content"><%= q.getLwmquestioncontent() %></td>
                        <td><%= q.getLwmcorrectanswer() %></td>
                        <td>
                            <a href="lwmUpdateQuestion?id=<%= q.getLwmquestionid() %>" class="btn-edit">编辑</a>
                            <a href="lwmDeleteQuestion?id=<%= q.getLwmquestionid() %>" class="btn-delete" onclick="return confirm('确定删除该试题？')">删除</a>
                        </td>
                    </tr>
                <% }
            } else { %>
                <tr><td colspan="6" class="empty">暂无试题</td></tr>
            <% } %>
        </tbody>
    </table>
</div>
</body>
</html>
```

- [ ] **Step 6: 创建 lwmteacher_question_add.jsp**

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmExamQuestion" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmTeacher" %>
<%@ page import="com.example.lwmexam.dao.lwmexam.lwmCourseArrangeDAO" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmstudentcourseteacher" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.stream.Collectors" %>
<%
    lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
    lwmExamQuestion question = (lwmExamQuestion) request.getAttribute("question");
    boolean isEdit = question != null;

    lwmCourseArrangeDAO arrangeDao = new lwmCourseArrangeDAO();
    List<lwmstudentcourseteacher> courses = arrangeDao.lwmQuerySomeSct(
        "SELECT DISTINCT sct.lwmsubjectid, sub.lwmsubjectname FROM lwmstudentcourseteacher sct LEFT JOIN lwmexamsubject sub ON sct.lwmsubjectid = sub.lwmsubjectid WHERE sct.lwmteacherid = ?",
        new Object[]{teacher.getLwmteacherid()});
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title><%= isEdit ? "编辑试题" : "添加试题" %></title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; padding:24px; }
        .container { max-width:700px; margin:0 auto; background:white; padding:32px; border-radius:12px; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        h2 { margin-bottom:24px; color:#1e293b; }
        .form-group { margin-bottom:18px; }
        .form-group label { display:block; margin-bottom:6px; color:#475569; font-weight:500; font-size:0.9rem; }
        .form-group select, .form-group input, .form-group textarea { width:100%; padding:10px 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.9rem; font-family:inherit; }
        .form-group textarea { resize:vertical; min-height:80px; }
        .options-area { display:none; }
        .options-area.show { display:block; }
        .btn-row { display:flex; gap:12px; justify-content:flex-end; margin-top:20px; }
        .btn { padding:10px 24px; border-radius:8px; cursor:pointer; border:none; font-size:0.9rem; text-decoration:none; }
        .btn-primary { background:#059669; color:white; }
        .btn-secondary { background:#e2e8f0; color:#475569; }
    </style>
</head>
<body>
<div class="container">
    <h2><%= isEdit ? "编辑试题" : "添加试题" %></h2>
    <form method="post" action="<%= isEdit ? "lwmUpdateQuestion" : "lwmAddQuestion" %>">
        <% if (isEdit) { %>
            <input type="hidden" name="lwmquestionid" value="<%= question.getLwmquestionid() %>">
        <% } %>
        <div class="form-group">
            <label>所属科目</label>
            <select name="lwmsubjectid" required>
                <option value="">请选择科目</option>
                <% for (lwmstudentcourseteacher c : courses) { %>
                    <option value="<%= c.getLwmsubjectid() %>" <%= isEdit && question.getLwmsubjectid() == c.getLwmsubjectid() ? "selected" : "" %>><%= c.getLwmsubjectname() %></option>
                <% } %>
            </select>
        </div>
        <div class="form-group">
            <label>题型</label>
            <select name="lwmquestiontype" id="questiontype" required onchange="toggleOptions()">
                <option value="">请选择题型</option>
                <option value="单选题" <%= isEdit && "单选题".equals(question.getLwmquestiontype()) ? "selected" : "" %>>单选题</option>
                <option value="多选题" <%= isEdit && "多选题".equals(question.getLwmquestiontype()) ? "selected" : "" %>>多选题</option>
                <option value="判断题" <%= isEdit && "判断题".equals(question.getLwmquestiontype()) ? "selected" : "" %>>判断题</option>
                <option value="简答题" <%= isEdit && "简答题".equals(question.getLwmquestiontype()) ? "selected" : "" %>>简答题</option>
            </select>
        </div>
        <div class="form-group">
            <label>题目内容</label>
            <textarea name="lwmquestioncontent" required><%= isEdit ? question.getLwmquestioncontent() : "" %></textarea>
        </div>
        <div id="optionsArea" class="options-area <%= isEdit && ("单选题".equals(question.getLwmquestiontype()) || "多选题".equals(question.getLwmquestiontype())) ? "show" : "" %>">
            <div class="form-group"><label>选项A</label><input type="text" name="lwmoptiona" value="<%= isEdit ? question.getLwmoptiona() : "" %>"></div>
            <div class="form-group"><label>选项B</label><input type="text" name="lwmoptionb" value="<%= isEdit ? question.getLwmoptionb() : "" %>"></div>
            <div class="form-group"><label>选项C</label><input type="text" name="lwmoptionc" value="<%= isEdit ? question.getLwmoptionc() : "" %>"></div>
            <div class="form-group"><label>选项D</label><input type="text" name="lwmoptiond" value="<%= isEdit ? question.getLwmoptiond() : "" %>"></div>
        </div>
        <div class="form-group">
            <label>正确答案<% if ("多选题".equals(question != null ? question.getLwmquestiontype() : "")) { %> (多选用逗号分隔，如 A,B,C)<% } %></label>
            <input type="text" name="lwmcorrectanswer" required value="<%= isEdit ? question.getLwmcorrectanswer() : "" %>">
        </div>
        <div class="btn-row">
            <a href="lwmQueryQuestion" class="btn btn-secondary">取消</a>
            <button type="submit" class="btn btn-primary">保存</button>
        </div>
    </form>
</div>
<script>
    function toggleOptions() {
        var type = document.getElementById('questiontype').value;
        var area = document.getElementById('optionsArea');
        if (type === '单选题' || type === '多选题') {
            area.classList.add('show');
        } else {
            area.classList.remove('show');
        }
    }
</script>
</body>
</html>
```

- [ ] **Step 7: 编译验证并测试**

```bash
cd "D:\Java\IdeaProjects\lwmexam" && mvn compile
```

---

### Task 8: 试卷管理 Servlet（创建/查询/预览/编辑/删除）+ JSP

**Files:**
- Create: `src/main/java/com/example/lwmexam/action/lwmexam/lwmQueryPaper.java`
- Create: `src/main/java/com/example/lwmexam/action/lwmexam/lwmCreatePaper.java`
- Create: `src/main/java/com/example/lwmexam/action/lwmexam/lwmDeletePaper.java`
- Create: `src/main/webapp/lwmteacher_paper_list.jsp`
- Create: `src/main/webapp/lwmteacher_paper_create.jsp`
- Create: `src/main/webapp/lwmteacher_paper_preview.jsp`

- [ ] **Step 1: 创建 lwmQueryPaper Servlet**

```java
package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmpaperDAO;
import com.example.lwmexam.entity.lwmexam.lwmExamPaper;
import com.example.lwmexam.entity.lwmexam.lwmTeacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/lwmQueryPaper")
public class lwmQueryPaper extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        if (teacher == null) { response.sendRedirect("login.jsp"); return; }

        lwmpaperDAO dao = new lwmpaperDAO();
        List<lwmExamPaper> papers = dao.lwmQueryByTeacher(teacher.getLwmteacherid());
        request.setAttribute("papers", papers);
        request.getRequestDispatcher("lwmteacher_paper_list.jsp").forward(request, response);
    }
}
```

- [ ] **Step 2: 创建 lwmCreatePaper Servlet**

```java
package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmquestionDAO;
import com.example.lwmexam.dao.lwmexam.lwmpaperDAO;
import com.example.lwmexam.entity.lwmexam.lwmExamPaper;
import com.example.lwmexam.entity.lwmexam.lwmExamQuestion;
import com.example.lwmexam.entity.lwmexam.lwmTeacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@WebServlet("/lwmCreatePaper")
public class lwmCreatePaper extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        PrintWriter out = response.getWriter();

        if (teacher == null) { out.println("<script>alert('请先登录');location.href='login.jsp';</script>"); return; }

        String mode = request.getParameter("mode");
        int subjectId = Integer.parseInt(request.getParameter("lwmsubjectid"));
        String classname = request.getParameter("lwmclassname");
        String paperName = request.getParameter("lwmpapername");
        String startTime = request.getParameter("lwmstarttime");
        String endTime = request.getParameter("lwmendtime");

        List<lwmExamQuestion> selectedQuestions = new ArrayList<>();
        lwmquestionDAO qDao = new lwmquestionDAO();

        if ("manual".equals(mode)) {
            String[] ids = request.getParameterValues("questionIds");
            if (ids == null || ids.length == 0) {
                out.println("<script>alert('请至少选择一道试题');history.go(-1);</script>"); return;
            }
            for (String id : ids) {
                lwmExamQuestion q = qDao.lwmQueryById(Integer.parseInt(id));
                if (q != null) selectedQuestions.add(q);
            }
        } else {
            int danxNum = Integer.parseInt(request.getParameter("danxnum"));
            int duoxNum = Integer.parseInt(request.getParameter("duoxnum"));
            int pdNum = Integer.parseInt(request.getParameter("pdnum"));
            int jdNum = Integer.parseInt(request.getParameter("jdnum"));
            int danxScore = Integer.parseInt(request.getParameter("danxscore"));
            int duoxScore = Integer.parseInt(request.getParameter("duoxscore"));
            int pdScore = Integer.parseInt(request.getParameter("pdscore"));
            int jdScore = Integer.parseInt(request.getParameter("jdscore"));

            selectedQuestions.addAll(qDao.lwmRandomPick(subjectId, "单选题", danxNum));
            selectedQuestions.addAll(qDao.lwmRandomPick(subjectId, "多选题", duoxNum));
            selectedQuestions.addAll(qDao.lwmRandomPick(subjectId, "判断题", pdNum));
            selectedQuestions.addAll(qDao.lwmRandomPick(subjectId, "简答题", jdNum));
        }

        lwmExamPaper paper = new lwmExamPaper();
        paper.setLwmpapername(paperName);
        paper.setLwmsubjectid(subjectId);
        paper.setLwmstarttime(startTime);
        paper.setLwmendtime(endTime);
        paper.setLwmteacherid(teacher.getLwmteacherid());
        paper.setLwmclassname(classname);
        paper.setLwmexamtime(0);

        // 分类统计
        int danxNum = 0, duoxNum = 0, pdNum = 0, jdNum = 0;
        int danxScore = 0, duoxScore = 0, pdScore = 0, jdScore = 0;
        StringBuilder danxNos = new StringBuilder(), duoxNos = new StringBuilder(), pdNos = new StringBuilder(), jdNos = new StringBuilder();

        for (int i = 0; i < selectedQuestions.size(); i++) {
            lwmExamQuestion q = selectedQuestions.get(i);
            String type = q.getLwmquestiontype();
            if ("单选题".equals(type)) { danxNum++; danxNos.append(i+1).append(","); }
            else if ("多选题".equals(type)) { duoxNum++; duoxNos.append(i+1).append(","); }
            else if ("判断题".equals(type)) { pdNum++; pdNos.append(i+1).append(","); }
            else if ("简答题".equals(type)) { jdNum++; jdNos.append(i+1).append(","); }
        }

        if ("auto".equals(mode)) {
            danxScore = Integer.parseInt(request.getParameter("danxscore"));
            duoxScore = Integer.parseInt(request.getParameter("duoxscore"));
            pdScore = Integer.parseInt(request.getParameter("pdscore"));
            jdScore = Integer.parseInt(request.getParameter("jdscore"));
        }

        paper.setLwmdanxnum(danxNum); paper.setLwmdanxscore(danxScore); paper.setLwmdanxnos(removeTrailingComma(danxNos));
        paper.setLwmduoxnum(duoxNum); paper.setLwmduoxscore(duoxScore); paper.setLwmduoxnos(removeTrailingComma(duoxNos));
        paper.setLwmpdnum(pdNum); paper.setLwmpdscore(pdScore); paper.setLwmpdnos(removeTrailingComma(pdNos));
        paper.setLwmjdnum(jdNum); paper.setLwmjdscore(jdScore); paper.setLwmjdnos(removeTrailingComma(jdNos));
        paper.setLwmexamsore(danxNum*danxScore + duoxNum*duoxScore + pdNum*pdScore + jdNum*jdScore);

        lwmpaperDAO pDao = new lwmpaperDAO();
        int paperId = pDao.lwmAddPaper(paper);
        if (paperId > 0) {
            for (lwmExamQuestion q : selectedQuestions) {
                pDao.lwmAddPaperQuestion(paperId, q.getLwmquestionid());
            }
            out.println("<script>alert('试卷创建成功');location.href='lwmQueryPaper';</script>");
        } else {
            out.println("<script>alert('创建失败');history.go(-1);</script>");
        }
    }

    private String removeTrailingComma(StringBuilder sb) {
        if (sb.length() > 0 && sb.charAt(sb.length()-1) == ',') {
            sb.deleteCharAt(sb.length()-1);
        }
        return sb.toString();
    }
}
```

- [ ] **Step 3: 创建 lwmDeletePaper Servlet**

```java
package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmpaperDAO;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/lwmDeletePaper")
public class lwmDeletePaper extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        int paperId = Integer.parseInt(request.getParameter("id"));
        lwmpaperDAO dao = new lwmpaperDAO();

        if (dao.hasSubmitRecord(paperId)) {
            out.println("<script>alert('该试卷已有学生提交，不可删除');history.go(-1);</script>");
            return;
        }
        int res = dao.lwmDeletePaper(paperId);
        if (res > 0) {
            out.println("<script>alert('删除成功');location.href='lwmQueryPaper';</script>");
        } else {
            out.println("<script>alert('删除失败');history.go(-1);</script>");
        }
    }
}
```

- [ ] **Step 4: 创建 lwmteacher_paper_list.jsp**

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmExamPaper" %>
<%
    List<lwmExamPaper> papers = (List<lwmExamPaper>) request.getAttribute("papers");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>试卷管理</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; padding:24px; }
        .container { max-width:1200px; margin:0 auto; }
        .header { display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; }
        .header h2 { color:#1e293b; font-size:1.5rem; }
        .btn { padding:8px 20px; border-radius:8px; cursor:pointer; text-decoration:none; font-size:0.9rem; border:none; display:inline-block; }
        .btn-primary { background:#059669; color:white; }
        .btn-danger { background:#ef4444; color:white; padding:6px 14px; border-radius:6px; text-decoration:none; font-size:0.8rem; }
        table { width:100%; background:white; border-radius:12px; overflow:hidden; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        th { background:#f8fafc; padding:12px 14px; text-align:left; font-weight:600; color:#475569; font-size:0.85rem; }
        td { padding:10px 14px; border-bottom:1px solid #f1f5f9; color:#334155; font-size:0.85rem; }
        tr:hover { background:#f8fafc; }
        .empty { text-align:center; padding:40px; color:#94a3b8; }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <h2>试卷管理</h2>
        <a href="lwmteacher_paper_create.jsp" class="btn btn-primary">+ 创建试卷</a>
    </div>
    <table>
        <thead>
            <tr><th>序号</th><th>试卷名称</th><th>科目</th><th>班级</th><th>考试时长</th><th>总分</th><th>操作</th></tr>
        </thead>
        <tbody>
            <% if (papers != null && !papers.isEmpty()) {
                int i = 1;
                for (lwmExamPaper p : papers) { %>
                    <tr>
                        <td><%= i++ %></td>
                        <td><%= p.getLwmpapername() %></td>
                        <td><%= p.getLwmsubjectname() != null ? p.getLwmsubjectname() : "" %></td>
                        <td><%= p.getLwmclassname() %></td>
                        <td><%= p.getLwmexamtime() %>分钟</td>
                        <td><%= p.getLwmexamsore() %></td>
                        <td>
                            <a href="lwmDeletePaper?id=<%= p.getLwmpaperid() %>" class="btn-danger" onclick="return confirm('确定删除该试卷？')">删除</a>
                        </td>
                    </tr>
                <% }
            } else { %>
                <tr><td colspan="7" class="empty">暂无试卷</td></tr>
            <% } %>
        </tbody>
    </table>
</div>
</body>
</html>
```

- [ ] **Step 5: 创建 lwmteacher_paper_create.jsp**

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmTeacher" %>
<%@ page import="com.example.lwmexam.dao.lwmexam.lwmCourseArrangeDAO" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmstudentcourseteacher" %>
<%@ page import="java.util.List" %>
<%
    lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
    if (teacher == null) { response.sendRedirect("login.jsp"); return; }

    lwmCourseArrangeDAO arrangeDao = new lwmCourseArrangeDAO();
    List<lwmstudentcourseteacher> courses = arrangeDao.lwmQuerySomeSct(
        "SELECT DISTINCT sct.lwmsubjectid, sct.lwmclassname, sub.lwmsubjectname " +
        "FROM lwmstudentcourseteacher sct LEFT JOIN lwmexamsubject sub ON sct.lwmsubjectid = sub.lwmsubjectid " +
        "WHERE sct.lwmteacherid = ?",
        new Object[]{teacher.getLwmteacherid()});
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>创建试卷</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; padding:24px; }
        .container { max-width:900px; margin:0 auto; background:white; padding:32px; border-radius:12px; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        h2 { margin-bottom:24px; color:#1e293b; }
        .form-group { margin-bottom:18px; }
        .form-group label { display:block; margin-bottom:6px; color:#475569; font-weight:500; font-size:0.9rem; }
        .form-group select, .form-group input { width:100%; padding:10px 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.9rem; }
        .inline-group { display:flex; gap:12px; }
        .inline-group .form-group { flex:1; }
        .mode-tabs { display:flex; gap:12px; margin-bottom:20px; }
        .mode-tab { padding:10px 24px; border-radius:8px; cursor:pointer; border:2px solid #e2e8f0; background:white; font-size:0.9rem; }
        .mode-tab.active { border-color:#059669; background:#ecfdf5; color:#059669; font-weight:600; }
        .btn-row { display:flex; gap:12px; justify-content:flex-end; margin-top:20px; }
        .btn { padding:10px 24px; border-radius:8px; cursor:pointer; border:none; font-size:0.9rem; text-decoration:none; }
        .btn-primary { background:#059669; color:white; }
        .btn-secondary { background:#e2e8f0; color:#475569; }
    </style>
</head>
<body>
<div class="container">
    <h2>创建试卷</h2>
    <form method="post" action="lwmCreatePaper">
        <div class="inline-group">
            <div class="form-group">
                <label>试卷名称</label>
                <input type="text" name="lwmpapername" required placeholder="如：2023级高数期末试卷">
            </div>
        </div>
        <div class="inline-group">
            <div class="form-group">
                <label>所属科目</label>
                <select name="lwmsubjectid" required>
                    <option value="">请选择</option>
                    <% for (lwmstudentcourseteacher c : courses) { %>
                        <option value="<%= c.getLwmsubjectid() %>"><%= c.getLwmsubjectname() %></option>
                    <% } %>
                </select>
            </div>
            <div class="form-group">
                <label>分配班级</label>
                <select name="lwmclassname" required>
                    <option value="">请选择</option>
                    <% for (lwmstudentcourseteacher c : courses) { %>
                        <option value="<%= c.getLwmclassname() %>"><%= c.getLwmclassname() %></option>
                    <% } %>
                </select>
            </div>
        </div>
        <div class="inline-group">
            <div class="form-group">
                <label>考试开始时间</label>
                <input type="datetime-local" name="lwmstarttime" required>
            </div>
            <div class="form-group">
                <label>考试结束时间</label>
                <input type="datetime-local" name="lwmendtime" required>
            </div>
        </div>

        <div class="mode-tabs">
            <div class="mode-tab active" onclick="switchMode('manual')">手动组卷</div>
            <div class="mode-tab" onclick="switchMode('auto')">自动组卷</div>
        </div>
        <input type="hidden" name="mode" id="mode" value="manual">

        <div id="manualArea">
            <p style="color:#64748b; margin-bottom:12px;">选择科目后将加载题库供勾选</p>
            <!-- 手动选题目列表将通过选择科目后 AJAX 加载 -->
        </div>
        <div id="autoArea" style="display:none;">
            <div class="inline-group">
                <div class="form-group"><label>单选题数量</label><input type="number" name="danxnum" value="0" min="0"></div>
                <div class="form-group"><label>单选题分值</label><input type="number" name="danxscore" value="0" min="0"></div>
            </div>
            <div class="inline-group">
                <div class="form-group"><label>多选题数量</label><input type="number" name="duoxnum" value="0" min="0"></div>
                <div class="form-group"><label>多选题分值</label><input type="number" name="duoxscore" value="0" min="0"></div>
            </div>
            <div class="inline-group">
                <div class="form-group"><label>判断题数量</label><input type="number" name="pdnum" value="0" min="0"></div>
                <div class="form-group"><label>判断题分值</label><input type="number" name="pdscore" value="0" min="0"></div>
            </div>
            <div class="inline-group">
                <div class="form-group"><label>简答题数量</label><input type="number" name="jdnum" value="0" min="0"></div>
                <div class="form-group"><label>简答题分值</label><input type="number" name="jdscore" value="0" min="0"></div>
            </div>
        </div>

        <div class="btn-row">
            <a href="lwmQueryPaper" class="btn btn-secondary">取消</a>
            <button type="submit" class="btn btn-primary">创建试卷</button>
        </div>
    </form>
</div>
<script>
    function switchMode(mode) {
        document.getElementById('mode').value = mode;
        document.querySelectorAll('.mode-tab').forEach(function(t) { t.classList.remove('active'); });
        event.target.classList.add('active');
        document.getElementById('manualArea').style.display = mode === 'manual' ? 'block' : 'none';
        document.getElementById('autoArea').style.display = mode === 'auto' ? 'block' : 'none';
    }
</script>
</body>
</html>
```

- [ ] **Step 6: 编译验证**

```bash
cd "D:\Java\IdeaProjects\lwmexam" && mvn compile
```

---

### Task 9: 考试情况查看 Servlet + JSP

**Files:**
- Create: `src/main/java/com/example/lwmexam/action/lwmexam/lwmQueryExamRecords.java`
- Create: `src/main/webapp/lwmteacher_exam_records.jsp`

- [ ] **Step 1: 创建 lwmQueryExamRecords Servlet**

```java
package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.entity.lwmexam.lwmTeacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/lwmQueryExamRecords")
public class lwmQueryExamRecords extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        if (teacher == null) { response.sendRedirect("login.jsp"); return; }

        List<Map<String, Object>> records = new ArrayList<>();
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8",
                "root", "123456");

            String sql = "SELECT r.*, s.lwmstudentno, s.lwmstudentname, s.lwmclassname, p.lwmpapername " +
                        "FROM lwmexamrecord r " +
                        "JOIN lwmstudent s ON r.lwmstudentid = s.lwmstudentid " +
                        "JOIN lwmexampaper p ON r.lwmpaperid = p.lwmpaperid " +
                        "WHERE p.lwmteacherid = ? ORDER BY r.lwmstarttime DESC";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, teacher.getLwmteacherid());
            ResultSet rs = pstmt.executeQuery();
            int i = 1;
            while (rs.next()) {
                Map<String, Object> record = new HashMap<>();
                record.put("index", i++);
                record.put("lwmrecordid", rs.getInt("lwmrecordid"));
                record.put("lwmpaperid", rs.getInt("lwmpaperid"));
                record.put("lwmpapername", rs.getString("lwmpapername"));
                record.put("lwmstudentno", rs.getString("lwmstudentno"));
                record.put("lwmstudentname", rs.getString("lwmstudentname"));
                record.put("lwmclassname", rs.getString("lwmclassname"));
                record.put("lwmstarttime", rs.getString("lwmstarttime"));
                record.put("lwmendtime", rs.getString("lwmendtime"));
                record.put("lwmsubmitstatus", rs.getInt("lwmsubmitstatus"));
                records.add(record);
            }
            rs.close(); pstmt.close(); conn.close();
        } catch (Exception e) { e.printStackTrace(); }

        request.setAttribute("records", records);
        request.getRequestDispatcher("lwmteacher_exam_records.jsp").forward(request, response);
    }
}
```

- [ ] **Step 2: 创建 lwmteacher_exam_records.jsp**

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    List<Map<String, Object>> records = (List<Map<String, Object>>) request.getAttribute("records");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>考试情况</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; padding:24px; }
        .container { max-width:1200px; margin:0 auto; }
        .header { margin-bottom:24px; }
        .header h2 { color:#1e293b; font-size:1.5rem; }
        .btn { padding:6px 14px; border-radius:6px; text-decoration:none; font-size:0.85rem; display:inline-block; }
        .btn-primary { background:#3b82f6; color:white; }
        .btn-disabled { background:#cbd5e1; color:#64748b; }
        .badge { padding:4px 10px; border-radius:12px; font-size:0.8rem; font-weight:500; }
        .badge-submitted { background:#dcfce7; color:#16a34a; }
        .badge-pending { background:#fef3c7; color:#d97706; }
        table { width:100%; background:white; border-radius:12px; overflow:hidden; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        th { background:#f8fafc; padding:12px 14px; text-align:left; font-weight:600; color:#475569; font-size:0.85rem; }
        td { padding:10px 14px; border-bottom:1px solid #f1f5f9; color:#334155; font-size:0.85rem; }
        tr:hover { background:#f8fafc; }
        .empty { text-align:center; padding:40px; color:#94a3b8; }
    </style>
</head>
<body>
<div class="container">
    <div class="header"><h2>学生考试情况</h2></div>
    <table>
        <thead>
            <tr><th>序号</th><th>试卷名称</th><th>学号</th><th>姓名</th><th>班级</th><th>开始时间</th><th>提交时间</th><th>状态</th><th>操作</th></tr>
        </thead>
        <tbody>
            <% if (records != null && !records.isEmpty()) {
                for (Map<String, Object> r : records) {
                    int status = (int) r.get("lwmsubmitstatus"); %>
                    <tr>
                        <td><%= r.get("index") %></td>
                        <td><%= r.get("lwmpapername") %></td>
                        <td><%= r.get("lwmstudentno") %></td>
                        <td><%= r.get("lwmstudentname") %></td>
                        <td><%= r.get("lwmclassname") %></td>
                        <td><%= r.get("lwmstarttime") %></td>
                        <td><%= r.get("lwmendtime") != null ? r.get("lwmendtime") : "--" %></td>
                        <td><span class="badge <%= status == 1 ? "badge-submitted" : "badge-pending" %>"><%= status == 1 ? "已提交" : "未提交" %></span></td>
                        <td>
                            <% if (status == 1) { %>
                                <a href="lwmGradeExam?recordId=<%= r.get("lwmrecordid") %>" class="btn btn-primary">评分</a>
                            <% } else { %>
                                <span class="btn btn-disabled">待提交</span>
                            <% } %>
                        </td>
                    </tr>
                <% }
            } else { %>
                <tr><td colspan="9" class="empty">暂无考试记录</td></tr>
            <% } %>
        </tbody>
    </table>
</div>
</body>
</html>
```

- [ ] **Step 3: 编译验证**

```bash
cd "D:\Java\IdeaProjects\lwmexam" && mvn compile
```

---

### Task 10: 评分功能 Servlet + JSP

**Files:**
- Create: `src/main/java/com/example/lwmexam/action/lwmexam/lwmGradeExam.java`
- Create: `src/main/java/com/example/lwmexam/action/lwmexam/lwmSubmitScore.java`
- Create: `src/main/webapp/lwmteacher_grading.jsp`

- [ ] **Step 1: 创建 lwmGradeExam Servlet**

```java
package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmscoreDAO;
import com.example.lwmexam.entity.lwmexam.lwmExamPaper;
import com.example.lwmexam.entity.lwmexam.lwmStudentAnswer;
import com.example.lwmexam.dao.lwmexam.lwmpaperDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

@WebServlet("/lwmGradeExam")
public class lwmGradeExam extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("teacher") == null) {
            response.sendRedirect("login.jsp"); return;
        }

        int recordId = Integer.parseInt(request.getParameter("recordId"));
        lwmscoreDAO dao = new lwmscoreDAO();
        List<lwmStudentAnswer> answers = dao.lwmQueryAnswersByRecord(recordId);

        // 自动评分客观题（如果是首次加载，得分都为0，则执行自动评分）
        boolean needAutoScore = true;
        for (lwmStudentAnswer a : answers) {
            if (a.getLwmquestionscore() > 0) { needAutoScore = false; break; }
        }

        if (needAutoScore) {
            for (lwmStudentAnswer a : answers) {
                int autoScore = autoGrade(a);
                a.setLwmquestionscore(autoScore);
            }
        }

        // 获取试卷信息以获取每题分值
        if (!answers.isEmpty()) {
            lwmpaperDAO pDao = new lwmpaperDAO();
            lwmExamPaper paper = pDao.lwmQueryPaperById(answers.get(0).getLwmpaperid());
            if (paper != null) {
                for (lwmStudentAnswer a : answers) {
                    String type = a.getLwmquestiontype();
                    if ("单选题".equals(type)) a.setLwmpaperscore(paper.getLwmdanxscore());
                    else if ("多选题".equals(type)) a.setLwmpaperscore(paper.getLwmduoxscore());
                    else if ("判断题".equals(type)) a.setLwmpaperscore(paper.getLwmpdscore());
                    else if ("简答题".equals(type)) a.setLwmpaperscore(paper.getLwmjdscore());
                }
            }
        }

        request.setAttribute("answers", answers);
        request.setAttribute("recordId", recordId);
        request.getRequestDispatcher("lwmteacher_grading.jsp").forward(request, response);
    }

    private int autoGrade(lwmStudentAnswer a) {
        String type = a.getLwmquestiontype();
        String studentAns = a.getLwmstudentanswer();
        String correctAns = a.getLwmcorrectanswer();
        if (studentAns == null || correctAns == null) return 0;

        if ("单选题".equals(type) || "判断题".equals(type)) {
            return studentAns.trim().equals(correctAns.trim()) ? a.getLwmpaperscore() : 0;
        } else if ("多选题".equals(type)) {
            String[] stuArr = studentAns.trim().replace("，", ",").split(",");
            String[] corArr = correctAns.trim().replace("，", ",").split(",");
            Arrays.sort(stuArr); Arrays.sort(corArr);
            return Arrays.equals(stuArr, corArr) ? a.getLwmpaperscore() : 0;
        }
        return 0; // 简答题不自动评分
    }
}
```

- [ ] **Step 2: 创建 lwmSubmitScore Servlet**

```java
package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmscoreDAO;
import com.example.lwmexam.entity.lwmexam.lwmExamScore;
import com.example.lwmexam.entity.lwmexam.lwmTeacher;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Enumeration;

@WebServlet("/lwmSubmitScore")
public class lwmSubmitScore extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        PrintWriter out = response.getWriter();

        if (teacher == null) { out.println("<script>alert('请先登录');location.href='login.jsp';</script>"); return; }

        int recordId = Integer.parseInt(request.getParameter("recordId"));
        int studentId = Integer.parseInt(request.getParameter("studentId"));
        int paperId = Integer.parseInt(request.getParameter("paperId"));

        lwmscoreDAO dao = new lwmscoreDAO();
        int totalScore = 0;

        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String name = paramNames.nextElement();
            if (name.startsWith("score_")) {
                int answerId = Integer.parseInt(name.substring(6));
                int score = Integer.parseInt(request.getParameter(name));
                dao.lwmSaveQuestionScore(answerId, score);
                totalScore += score;
            }
        }

        lwmExamScore examScore = new lwmExamScore();
        examScore.setLwmrecordid(recordId);
        examScore.setLwmtotalscore(totalScore);
        examScore.setLwmteacherid(teacher.getLwmteacherid());
        examScore.setLwmstudentid(studentId);
        examScore.setLwmpaperid(paperId);
        dao.lwmSaveScore(examScore);

        out.println("<script>alert('评分提交成功，总分：" + totalScore + "');location.href='lwmQueryExamRecords';</script>");
    }
}
```

- [ ] **Step 3: 创建 lwmteacher_grading.jsp**

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.lwmexam.entity.lwmexam.lwmStudentAnswer" %>
<%
    List<lwmStudentAnswer> answers = (List<lwmStudentAnswer>) request.getAttribute("answers");
    int recordId = (int) request.getAttribute("recordId");
    int studentId = answers != null && !answers.isEmpty() ? answers.get(0).getLwmstudentid() : 0;
    int paperId = answers != null && !answers.isEmpty() ? answers.get(0).getLwmpaperid() : 0;
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>评分</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:#f0f2f5; padding:24px; }
        .container { max-width:900px; margin:0 auto; }
        .header { display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; }
        .header h2 { color:#1e293b; font-size:1.5rem; }
        .card { background:white; border-radius:12px; padding:24px; margin-bottom:16px; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        .card h3 { color:#1e293b; margin-bottom:12px; font-size:1rem; }
        .card .meta { color:#64748b; font-size:0.85rem; margin-bottom:8px; }
        .card .options { margin:8px 0; padding-left:16px; color:#475569; font-size:0.9rem; }
        .card .answer { margin:8px 0; }
        .score-input { width:80px; padding:6px 10px; border:1px solid #e2e8f0; border-radius:6px; text-align:center; }
        .correct { color:#16a34a; }
        .wrong { color:#ef4444; }
        .btn { padding:10px 24px; border-radius:8px; cursor:pointer; border:none; font-size:0.9rem; }
        .btn-primary { background:#059669; color:white; }
        .btn-row { display:flex; justify-content:flex-end; margin-top:20px; }
    </style>
</head>
<body>
<div class="container">
    <div class="header"><h2>试卷评分</h2></div>
    <form method="post" action="lwmSubmitScore">
        <input type="hidden" name="recordId" value="<%= recordId %>">
        <input type="hidden" name="studentId" value="<%= studentId %>">
        <input type="hidden" name="paperId" value="<%= paperId %>">
        <% if (answers != null && !answers.isEmpty()) {
            for (lwmStudentAnswer a : answers) { %>
                <div class="card">
                    <h3><%= a.getLwmquestiontype() %> — 分值 <%= a.getLwmpaperscore() %> 分</h3>
                    <p style="margin-bottom:8px;"><strong>题目：</strong><%= a.getLwmquestioncontent() %></p>
                    <% if ("单选题".equals(a.getLwmquestiontype()) || "多选题".equals(a.getLwmquestiontype())) { %>
                        <div class="options">
                            <% if (a.getLwmoptiona() != null && !a.getLwmoptiona().isEmpty()) { %><div>A. <%= a.getLwmoptiona() %></div><% } %>
                            <% if (a.getLwmoptionb() != null && !a.getLwmoptionb().isEmpty()) { %><div>B. <%= a.getLwmoptionb() %></div><% } %>
                            <% if (a.getLwmoptionc() != null && !a.getLwmoptionc().isEmpty()) { %><div>C. <%= a.getLwmoptionc() %></div><% } %>
                            <% if (a.getLwmoptiond() != null && !a.getLwmoptiond().isEmpty()) { %><div>D. <%= a.getLwmoptiond() %></div><% } %>
                        </div>
                    <% } %>
                    <div class="answer"><strong>学生答案：</strong><%= a.getLwmstudentanswer() != null ? a.getLwmstudentanswer() : "(未作答)" %></div>
                    <div class="answer"><strong>正确答案：</strong><span class="correct"><%= a.getLwmcorrectanswer() %></span></div>
                    <div class="answer">
                        <strong>得分：</strong>
                        <input type="number" class="score-input" name="score_<%= a.getLwmanswerid() %>" value="<%= a.getLwmquestionscore() %>" min="0" max="<%= a.getLwmpaperscore() %>">
                        / <%= a.getLwmpaperscore() %>
                    </div>
                </div>
            <% }
        } else { %>
            <div class="card"><p style="color:#94a3b8;">暂无答题数据</p></div>
        <% } %>
        <div class="btn-row">
            <button type="submit" class="btn btn-primary">提交评分</button>
        </div>
    </form>
</div>
</body>
</html>
```

- [ ] **Step 4: 编译验证**

```bash
cd "D:\Java\IdeaProjects\lwmexam" && mvn compile
```

---

### Task 11: 更新教师端左侧导航菜单

**Files:**
- Modify: `src/main/webapp/lwmteacher_left.jsp`

- [ ] **Step 1: 更新 lwmteacher_left.jsp 导航链接**

将 `lwmteacher_left.jsp` 中的菜单项替换为实际功能链接。定位到第 38-49 行的菜单区域，替换为：

```jsp
<div class="sidebar">
    <div class="menu-item active">
        <i class="fas fa-tachometer-alt"></i>
        <a href="lwmteacher_index.jsp" target="rightFrame">主页</a>
    </div>
    <div class="menu-item">
        <i class="fas fa-calendar-alt"></i>
        <a href="lwmQueryTeacherCourses" target="rightFrame">我的排课</a>
    </div>
    <div class="menu-item">
        <i class="fas fa-database"></i>
        <a href="lwmQueryQuestion" target="rightFrame">题库管理</a>
    </div>
    <div class="menu-item">
        <i class="fas fa-file-alt"></i>
        <a href="lwmQueryPaper" target="rightFrame">试卷管理</a>
    </div>
    <div class="menu-item">
        <i class="fas fa-search"></i>
        <a href="lwmQueryExamRecords" target="rightFrame">考试情况</a>
    </div>
</div>
```

菜单项 CSS 中的 `.menu-item` 样式保持不变。

- [ ] **Step 2: 编译验证**

```bash
cd "D:\Java\IdeaProjects\lwmexam" && mvn compile
```

---

### Task 12: 集成测试与验证清单

启动应用后逐项验证：

- [ ] **Step 1: 教师登录** — 使用工号 211/密码 123 登录，应进入 `lwmteacher_main.jsp`
- [ ] **Step 2: 我的排课** — 点击左侧"我的排课"，应看到教师罗尉铭的排课记录
- [ ] **Step 3: 题库管理** — 添加一道单选题、一道简答题，列表应正确显示
- [ ] **Step 4: 题库筛选** — 按题型/关键字筛选功能正常
- [ ] **Step 5: 编辑/删除试题** — 编辑后正确更新，删除后弹出确认
- [ ] **Step 6: 创建试卷(自动)** — 指定各题型数量+分值，创建成功
- [ ] **Step 7: 创建试卷(手动)** — 勾选试题创建成功
- [ ] **Step 8: 删除试卷** — 无提交记录时可删除
- [ ] **Step 9: 考试情况** — 显示学生考试记录和提交状态
- [ ] **Step 10: 评分** — 客观题自动预填分数，简答题手动填写，提交后成绩正确保存
