package com.example.lwmexam.dao.lwmexam;

import com.example.lwmexam.entity.lwmexam.lwmStudent;
import com.example.lwmexam.service.lwmexam.MysqlConn;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class lwmstudentDAO {
    MysqlConn db = new MysqlConn();
    ResultSet rs = null;
    int res = 0;

    // 查询学生信息（通用查询）
    public List<lwmStudent> lwmQuerySomeStudent(String sql, Object[] param) {
        List<lwmStudent> someStudent = new ArrayList<lwmStudent>();
        try {
            rs = db.doQuery(sql, param);
            while (rs.next()) {
                lwmStudent student = new lwmStudent();
                student.setLwmstudentid(rs.getInt("lwmstudentid"));
                student.setLwmstudentno(rs.getString("lwmstudentno"));
                student.setLwmstudentname(rs.getString("lwmstudentname"));
                student.setLwmstudentpassword(rs.getString("lwmstudentpassword"));
                student.setLwmgender(rs.getString("lwmgender"));
                student.setLwmgrade(rs.getString("lwmgrade"));
                student.setLwmmajor(rs.getString("lwmmajor"));
                student.setLwmclassname(rs.getString("lwmclassname"));
                someStudent.add(student);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        db.close();
        return someStudent;
    }

    // 添加学生信息
    public int lwmAddStudent(lwmStudent student) {
        res = db.doUpdate("insert into lwmstudent(lwmstudentno,lwmstudentname,lwmstudentpassword,lwmgender,lwmgrade,lwmmajor,lwmclassname) values(?,?,?,?,?,?,?)",
                new Object[]{student.getLwmstudentno(), student.getLwmstudentname(),
                        student.getLwmstudentpassword(), student.getLwmgender(),
                        student.getLwmgrade(), student.getLwmmajor(), student.getLwmclassname()});
        db.close();
        return res;
    }

    // 根据ID查询学生信息
    public lwmStudent lwmQueryStudentById(int id) {
        lwmStudent student = null;
        try {
            rs = db.doQuery("select * from lwmstudent where lwmstudentid = ?", new Object[]{id});
            if (rs.next()) {
                student = new lwmStudent();
                student.setLwmstudentid(rs.getInt("lwmstudentid"));
                student.setLwmstudentno(rs.getString("lwmstudentno"));
                student.setLwmstudentname(rs.getString("lwmstudentname"));
                student.setLwmstudentpassword(rs.getString("lwmstudentpassword"));
                student.setLwmgender(rs.getString("lwmgender"));
                student.setLwmgrade(rs.getString("lwmgrade"));
                student.setLwmmajor(rs.getString("lwmmajor"));
                student.setLwmclassname(rs.getString("lwmclassname"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        db.close();
        return student;
    }

    // ===================== 单输入框万能查询：学号 / 姓名 / 年级 / 专业 / 班级 =====================
    public List<lwmStudent> lwmSearchStudent(String keyword) {
        List<lwmStudent> stuList = new ArrayList<>();
        String sql = "SELECT * FROM lwmstudent " +
                "WHERE lwmstudentno LIKE ? " +
                "OR lwmstudentname LIKE ? " +
                "OR lwmgrade LIKE ? " +
                "OR lwmmajor LIKE ? " +
                "OR lwmclassname LIKE ?";

        String likeKey = "%" + keyword.trim() + "%";
        Object[] params = {likeKey, likeKey, likeKey, likeKey, likeKey};

        try {
            rs = db.doQuery(sql, params);
            while (rs.next()) {
                lwmStudent student = new lwmStudent();
                student.setLwmstudentid(rs.getInt("lwmstudentid"));
                student.setLwmstudentno(rs.getString("lwmstudentno"));
                student.setLwmstudentname(rs.getString("lwmstudentname"));
                student.setLwmstudentpassword(rs.getString("lwmstudentpassword"));
                student.setLwmgender(rs.getString("lwmgender"));
                student.setLwmgrade(rs.getString("lwmgrade"));
                student.setLwmmajor(rs.getString("lwmmajor"));
                student.setLwmclassname(rs.getString("lwmclassname"));
                stuList.add(student);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        db.close();
        return stuList;
    }

    // 修改学生信息
    public int lwmUpdateStudent(lwmStudent student) {
        res = db.doUpdate("update lwmstudent set lwmstudentno=?, lwmstudentname=?, lwmstudentpassword=?, lwmgender=?, lwmgrade=?, lwmmajor=?, lwmclassname=? where lwmstudentid=?",
                new Object[]{student.getLwmstudentno(), student.getLwmstudentname(),
                        student.getLwmstudentpassword(), student.getLwmgender(),
                        student.getLwmgrade(), student.getLwmmajor(), student.getLwmclassname(),
                        student.getLwmstudentid()});
        db.close();
        return res;
    }

    // 删除学生信息
    public int lwmDeleteStudentById(int id) {
        res = db.doUpdate("delete from lwmstudent where lwmstudentid = ?", new Object[]{id});
        db.close();
        return res;
    }

    // 统计学生总人数
    public int getStudentCount() {
        int count = 0;
        try {
            rs = db.doQuery("select count(*) from lwmstudent", new Object[]{});
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            db.close();
        }
        return count;
    }

    // ===================== 获取所有班级（去重，排课专用） =====================
    public List<String> lwmGetAllClassName() {
        List<String> classList = new ArrayList<>();
        try {
            rs = db.doQuery("select distinct lwmclassname from lwmstudent order by lwmclassname", new Object[]{});
            while (rs.next()) {
                classList.add(rs.getString("lwmclassname"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        db.close();
        return classList;
    }
}