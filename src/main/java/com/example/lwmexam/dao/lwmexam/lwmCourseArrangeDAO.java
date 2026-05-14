package com.example.lwmexam.dao.lwmexam;

import com.example.lwmexam.entity.lwmexam.lwmstudentcourseteacher;
import com.example.lwmexam.service.lwmexam.MysqlConn;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
public class lwmCourseArrangeDAO {
    MysqlConn db = new MysqlConn();
    ResultSet rs = null;
    int res = 0;


    public List<lwmstudentcourseteacher> lwmQuerySomeSct(String sql, Object[] param) {
        List<lwmstudentcourseteacher> someSct = new ArrayList<lwmstudentcourseteacher>();
        try {
            rs = db.doQuery(sql, param);
            while (rs.next()) {
                lwmstudentcourseteacher sct = new lwmstudentcourseteacher();
                sct.setLwmsctid(rs.getInt("lwmsctid"));
                sct.setLwmclassname(rs.getString("lwmclassname"));
                sct.setLwmsubjectid(rs.getInt("lwmsubjectid"));
                sct.setLwmteacherid(rs.getInt("lwmteacherid"));
                sct.setLwmsemester(rs.getString("lwmsemester"));
                sct.setLwmsubjectname(rs.getString("lwmsubjectname"));
                sct.setLwmteachername(rs.getString("lwmteachername"));

                someSct.add(sct);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        db.close();
        return someSct;
    }
    // 添加排课信息
    public int lwmAddSct(lwmstudentcourseteacher sct) {
        res = db.doUpdate("insert into lwmstudentcourseteacher(lwmclassname,lwmsubjectid,lwmteacherid,lwmsemester) values(?,?,?,?)",
                new Object[]{sct.getLwmclassname(),
                        sct.getLwmsubjectid(),
                        sct.getLwmteacherid(),
                        sct.getLwmsemester()});
        db.close();
        return res;
    }

    // 根据ID查询排课信息
    public lwmstudentcourseteacher lwmQuerySctById(int id) {
        lwmstudentcourseteacher sct = null;
        try {
            rs = db.doQuery("select * from lwmstudentcourseteacher where lwmsctid = ?", new Object[]{id});
            if (rs.next()) {
                sct = new lwmstudentcourseteacher();
                sct.setLwmsctid(rs.getInt("lwmsctid"));
                sct.setLwmclassname(rs.getString("lwmclassname"));
                sct.setLwmsubjectid(rs.getInt("lwmsubjectid"));
                sct.setLwmteacherid(rs.getInt("lwmteacherid"));
                sct.setLwmsemester(rs.getString("lwmsemester"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        db.close();
        return sct;
    }

    // 修改排课信息
    public int lwmUpdateSct(lwmstudentcourseteacher sct) {
        res = db.doUpdate("update lwmstudentcourseteacher set lwmclassname=?, lwmsubjectid=?, lwmteacherid=?, lwmsemester=? where lwmsctid=?",
                new Object[]{sct.getLwmclassname(),
                        sct.getLwmsubjectid(),
                        sct.getLwmteacherid(),
                        sct.getLwmsemester(),
                        sct.getLwmsctid()});
        db.close();
        return res;
    }

    // 删除排课信息
    public int lwmDeleteSctById(int id) {
        res = db.doUpdate("delete from lwmstudentcourseteacher where lwmsctid = ?", new Object[]{id});
        db.close();
        return res;
    }

    // 查询全部排课
    // 查询全部排课（三表联查）
    public List<lwmstudentcourseteacher> lwmQueryAllSct() {
        return lwmQuerySomeSct(
                "SELECT sct.*, sub.lwmsubjectname, tea.lwmteachername " +
                        "FROM lwmstudentcourseteacher sct " +
                        "LEFT JOIN lwmexamsubject sub ON sct.lwmsubjectid = sub.lwmsubjectid " +
                        "LEFT JOIN lwmteacher tea ON sct.lwmteacherid = tea.lwmteacherid",
                new Object[]{}
        );
    }

    // 单输入框搜索：班级、科目名、教师名
    public List<lwmstudentcourseteacher> lwmSearchArrange(String keyword) {
        List<lwmstudentcourseteacher> list = new ArrayList<>();

        String sql = "SELECT sct.*, sub.lwmsubjectname, tea.lwmteachername " +
                "FROM lwmstudentcourseteacher sct " +
                "LEFT JOIN lwmexamsubject sub ON sct.lwmsubjectid = sub.lwmsubjectid " +
                "LEFT JOIN lwmteacher tea ON sct.lwmteacherid = tea.lwmteacherid " +
                "WHERE sct.lwmclassname LIKE ? " +
                "OR sub.lwmsubjectname LIKE ? " +
                "OR tea.lwmteachername LIKE ?";

        String likeKey = "%" + keyword.trim() + "%";
        Object[] params = {likeKey, likeKey, likeKey};

        try {
            // 调用你原来的通用方法，避免重复造轮子
            return lwmQuerySomeSct(sql, params);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    public int getstudentcourseteacherCount() {
        int count = 0;
        try {
            rs = db.doQuery("select count(*) from lwmstudentcourseteacher", new Object[]{});
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
