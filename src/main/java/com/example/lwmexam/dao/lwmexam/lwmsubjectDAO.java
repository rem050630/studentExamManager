package com.example.lwmexam.dao.lwmexam;

import com.example.lwmexam.entity.lwmexam.lwmSubject;
import com.example.lwmexam.service.lwmexam.MysqlConn;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class lwmsubjectDAO {
    MysqlConn db = new MysqlConn();
    ResultSet rs = null;
    int res = 0;

    // 查询课程信息（通用查询）
    public List<lwmSubject> lwmQuerySomeSubject(String sql, Object[] param) {
        List<lwmSubject> someSubject = new ArrayList<lwmSubject>();
        try {
            rs = db.doQuery(sql, param);
            while (rs.next()) {
                lwmSubject subject = new lwmSubject();
                subject.setLwmsubjectid(rs.getInt("lwmsubjectid"));
                subject.setLwmsubjectname(rs.getString("lwmsubjectname"));
                subject.setLwmsubjectdesc(rs.getString("lwmsubjectdesc"));
                subject.setLwmsubjectscore(rs.getInt("lwmsubjectscore"));
                subject.setLwmterm(rs.getString("lwmterm"));
                someSubject.add(subject);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        db.close();
        return someSubject;
    }

    // 添加课程信息
    public int lwmAddSubject(lwmSubject subject) {
        res = db.doUpdate("insert into lwmexamsubject(lwmsubjectname,lwmsubjectdesc,lwmsubjectscore,lwmterm) values(?,?,?,?)",
                new Object[]{
                        subject.getLwmsubjectname(),
                        subject.getLwmsubjectdesc(),
                        subject.getLwmsubjectscore(),
                        subject.getLwmterm()
                });
        db.close();
        return res;
    }

    // 根据ID查询课程
    public lwmSubject lwmQuerySubjectById(int id) {
        lwmSubject subject = null;
        try {
            rs = db.doQuery("select * from lwmexamsubject where lwmsubjectid = ?", new Object[]{id});
            if (rs.next()) {
                subject = new lwmSubject();
                subject.setLwmsubjectid(rs.getInt("lwmsubjectid"));
                subject.setLwmsubjectname(rs.getString("lwmsubjectname"));
                subject.setLwmsubjectdesc(rs.getString("lwmsubjectdesc"));
                subject.setLwmsubjectscore(rs.getInt("lwmsubjectscore"));
                subject.setLwmterm(rs.getString("lwmterm"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        db.close();
        return subject;
    }

    // 模糊查询科目（支持输入部分名称搜索）
    // 【支持：课程名称 + 课程代码】模糊查询
    public List<lwmSubject> lwmQuerySubjectByMulti(String keyword) {
        List<lwmSubject> subjectList = new ArrayList<>();
        // 同时查询 课程名 和 课程代码
        String sql = "select * from lwmexamsubject where lwmsubjectname like ? OR lwmsubjectdesc like ?";
        String likeKey = "%" + keyword.trim() + "%";

        try {
            rs = db.doQuery(sql, new Object[]{likeKey, likeKey});
            while (rs.next()) {
                lwmSubject subject = new lwmSubject();
                subject.setLwmsubjectid(rs.getInt("lwmsubjectid"));
                subject.setLwmsubjectname(rs.getString("lwmsubjectname"));
                subject.setLwmsubjectdesc(rs.getString("lwmsubjectdesc"));
                subject.setLwmsubjectscore(rs.getInt("lwmsubjectscore"));
                subject.setLwmterm(rs.getString("lwmterm"));
                subjectList.add(subject);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        db.close();
        return subjectList;
    }

    // 修改课程信息
    public int lwmUpdateSubject(lwmSubject subject) {
        res = db.doUpdate("update lwmexamsubject set lwmsubjectname=?, lwmsubjectdesc=?, lwmsubjectscore=?, lwmterm=? where lwmsubjectid=?",
                new Object[]{
                        subject.getLwmsubjectname(),
                        subject.getLwmsubjectdesc(),
                        subject.getLwmsubjectscore(),
                        subject.getLwmterm(),
                        subject.getLwmsubjectid()
                });
        db.close();
        return res;
    }

    // 删除课程
    public int lwmDeleteSubjectById(int id) {
        res = db.doUpdate("delete from lwmexamsubject where lwmsubjectid = ?", new Object[]{id});
        db.close();
        return res;
    }

    // 统计课程总数
    public int getSubjectCount() {
        int count = 0;
        try {
            rs = db.doQuery("select count(*) from lwmexamsubject", new Object[]{});
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
    // 查询所有课程（给排课功能用）
    public List<lwmSubject> lwmQueryAllSubject() {
        List<lwmSubject> list = new ArrayList<>();
        try {
            rs = db.doQuery("select * from lwmexamsubject", new Object[]{});
            while (rs.next()) {
                lwmSubject subject = new lwmSubject();
                subject.setLwmsubjectid(rs.getInt("lwmsubjectid"));
                subject.setLwmsubjectname(rs.getString("lwmsubjectname"));
                subject.setLwmsubjectdesc(rs.getString("lwmsubjectdesc"));
                subject.setLwmsubjectscore(rs.getInt("lwmsubjectscore"));
                subject.setLwmterm(rs.getString("lwmterm"));
                list.add(subject);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        db.close();
        return list;
    }
}
