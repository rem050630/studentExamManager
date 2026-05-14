package com.example.lwmexam.dao.lwmexam;

import com.example.lwmexam.entity.lwmexam.lwmTeacher;
import com.example.lwmexam.service.lwmexam.MysqlConn;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class lwmTeacherDAO {
    MysqlConn db = new MysqlConn();
    ResultSet rs = null;
    int res = 0;

    // 查询教师信息（通用查询）
    public List<lwmTeacher> lwmQuerySomeTeacher(String sql, Object[] param) {
        List<lwmTeacher> someTeacher = new ArrayList<lwmTeacher>();
        try {
            rs = db.doQuery(sql, param);
            while (rs.next()) {
                lwmTeacher teacher = new lwmTeacher();
                teacher.setLwmteacherid(rs.getInt("lwmteacherid"));
                teacher.setLwmteacherno(rs.getString("lwmteacherno"));
                teacher.setLwmteachername(rs.getString("lwmteachername"));
                teacher.setLwmteacherpassword(rs.getString("lwmteacherpassword"));
                teacher.setLwmteachergender(rs.getString("lwmteachergender"));
                teacher.setLwmteacherphone(rs.getString("lwmteacherphone"));
                someTeacher.add(teacher);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        db.close();
        return someTeacher;
    }

    // 添加教师信息
    public int lwmAddTeacher(lwmTeacher teacher) {
        res = db.doUpdate("insert into lwmteacher(lwmteacherno,lwmteachername,lwmteacherpassword,lwmteachergender,lwmteacherphone) values(?,?,?,?,?)",
                new Object[]{teacher.getLwmteacherno(), teacher.getLwmteachername(),
                        teacher.getLwmteacherpassword(), teacher.getLwmteachergender(),
                        teacher.getLwmteacherphone()});
        db.close();
        return res;
    }

    // 根据ID查询教师信息
    public lwmTeacher lwmQueryTeacherById(int id) {
        lwmTeacher teacher = null;
        try {
            rs = db.doQuery("select * from lwmteacher where lwmteacherid = ?", new Object[]{id});
            if (rs.next()) {
                teacher = new lwmTeacher();
                teacher.setLwmteacherid(rs.getInt("lwmteacherid"));
                teacher.setLwmteacherno(rs.getString("lwmteacherno"));
                teacher.setLwmteachername(rs.getString("lwmteachername"));
                teacher.setLwmteacherpassword(rs.getString("lwmteacherpassword"));
                teacher.setLwmteachergender(rs.getString("lwmteachergender"));
                teacher.setLwmteacherphone(rs.getString("lwmteacherphone"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        db.close();
        return teacher;
    }

    // 【支持：工号 + 姓名】模糊查询
    public List<lwmTeacher> lwmQueryTeacherByMulti(String keyword) {
        List<lwmTeacher> teacherList = new ArrayList<>();
        String sql = "select * from lwmteacher where lwmteacherno like ? OR lwmteachername like ?";
        String likeKey = "%" + keyword.trim() + "%";

        try {
            rs = db.doQuery(sql, new Object[]{likeKey, likeKey});
            while (rs.next()) {
                lwmTeacher teacher = new lwmTeacher();
                teacher.setLwmteacherid(rs.getInt("lwmteacherid"));
                teacher.setLwmteacherno(rs.getString("lwmteacherno"));
                teacher.setLwmteachername(rs.getString("lwmteachername"));
                teacher.setLwmteacherpassword(rs.getString("lwmteacherpassword"));
                teacher.setLwmteachergender(rs.getString("lwmteachergender"));
                teacher.setLwmteacherphone(rs.getString("lwmteacherphone"));
                teacherList.add(teacher);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        db.close();
        return teacherList;
    }

    // 修改教师信息
    public int lwmUpdateTeacher(lwmTeacher teacher) {
        res = db.doUpdate("update lwmteacher set lwmteacherno=?, lwmteachername=?, lwmteacherpassword=?, lwmteachergender=?, lwmteacherphone=? where lwmteacherid=?",
                new Object[]{teacher.getLwmteacherno(), teacher.getLwmteachername(),
                        teacher.getLwmteacherpassword(), teacher.getLwmteachergender(),
                        teacher.getLwmteacherphone(),
                        teacher.getLwmteacherid()});
        db.close();
        return res;
    }

    // 删除教师信息
    public int lwmDeleteTeacherById(int id) {
        res = db.doUpdate("delete from lwmteacher where lwmteacherid = ?", new Object[]{id});
        db.close();
        return res;
    }
    // ===================== 排课功能（完全匹配你的写法） =====================

    // 1. 获取所有班级（去重）
//    public List<String> lwmGetAllClassName() {
//        List<String> classList = new ArrayList<>();
//        try {
//            rs = db.doQuery("select distinct lwmclassname from lwmstudent order by lwmclassname", new Object[]{});
//            while (rs.next()) {
//                classList.add(rs.getString("lwmclassname"));
//            }
//        } catch (SQLException e) {
//            e.printStackTrace();
//        }
//        db.close();
//        return classList;
//    }
//
//    // 2. 给班级分配课程（排课保存）
//    public int lwmAssignClassCourse(String lwmclassname, int lwmsubjectid, int lwmteacherid, String lwmsemester) {
//        String sql = "insert into lwmstudentcourseteacher(lwmclassname, lwmsubjectid, lwmteacherid, lwmsemester) values(?,?,?,?)";
//        Object[] param = {lwmclassname, lwmsubjectid, lwmteacherid, lwmsemester};
//        res = db.doUpdate(sql, param);
//        db.close();
//        return res;
//    }

    public int getTeacherCount() {
        int count = 0;
        try {
            rs = db.doQuery("select count(*) from lwmteacher", new Object[]{});
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
}