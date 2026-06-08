package com.example.lwmexam.dao.lwmexam;

import com.example.lwmexam.entity.lwmexam.lwmKnowledgePoint;
import com.example.lwmexam.service.lwmexam.MysqlConn;

import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class lwmKnowledgePointDAO {
    MysqlConn db = new MysqlConn();
    ResultSet rs = null;
    int res = 0;

    private List<lwmKnowledgePoint> mapResultSet(String sql, Object[] param) {
        List<lwmKnowledgePoint> list = new ArrayList<>();
        try {
            rs = db.doQuery(sql, param);
            while (rs.next()) {
                lwmKnowledgePoint kp = new lwmKnowledgePoint();
                kp.setLwmkpid(rs.getInt("lwmkpid"));
                kp.setLwmsubjectid(rs.getInt("lwmsubjectid"));
                kp.setLwmkpname(rs.getString("lwmkpname"));
                kp.setLwmkpdesc(rs.getString("lwmkpdesc"));
                try { kp.setLwmsubjectname(rs.getString("lwmsubjectname")); } catch (java.sql.SQLException ignored) {}
                list.add(kp);
            }
        } catch (Exception e) { e.printStackTrace(); }
        db.close();
        return list;
    }

    public List<lwmKnowledgePoint> queryBySubject(int subjectId) {
        return mapResultSet(
            "SELECT kp.*, s.lwmsubjectname FROM lwmknowledgepoint kp " +
            "LEFT JOIN lwmexamsubject s ON kp.lwmsubjectid = s.lwmsubjectid " +
            "WHERE kp.lwmsubjectid = ? ORDER BY kp.lwmkpid",
            new Object[]{subjectId});
    }

    public List<lwmKnowledgePoint> queryAll() {
        return mapResultSet(
            "SELECT kp.*, s.lwmsubjectname FROM lwmknowledgepoint kp " +
            "LEFT JOIN lwmexamsubject s ON kp.lwmsubjectid = s.lwmsubjectid " +
            "ORDER BY kp.lwmsubjectid, kp.lwmkpid", new Object[]{});
    }

    public int insert(lwmKnowledgePoint kp) {
        res = db.doUpdate(
            "INSERT INTO lwmknowledgepoint(lwmsubjectid,lwmkpname,lwmkpdesc) VALUES(?,?,?)",
            new Object[]{kp.getLwmsubjectid(), kp.getLwmkpname(), kp.getLwmkpdesc()});
        db.close();
        return res;
    }

    public int update(lwmKnowledgePoint kp) {
        res = db.doUpdate(
            "UPDATE lwmknowledgepoint SET lwmkpname=?, lwmkpdesc=? WHERE lwmkpid=?",
            new Object[]{kp.getLwmkpname(), kp.getLwmkpdesc(), kp.getLwmkpid()});
        db.close();
        return res;
    }

    public int delete(int kpId) {
        res = db.doUpdate("DELETE FROM lwmknowledgepoint WHERE lwmkpid = ?", new Object[]{kpId});
        db.close();
        return res;
    }

    // Save question-KP links: delete existing then batch insert
    public void saveQuestionKPs(int questionId, int[] kpIds) {
        db.doUpdate("DELETE FROM lwmquestionknowledge WHERE lwmquestionid = ?", new Object[]{questionId});
        db.close();
        if (kpIds != null && kpIds.length > 0) {
            for (int kpId : kpIds) {
                db.doUpdate("INSERT INTO lwmquestionknowledge(lwmquestionid,lwmkpid) VALUES(?,?)",
                    new Object[]{questionId, kpId});
            }
            db.close();
        }
    }

    // Get KP IDs for a question
    public List<Integer> getKPIdsByQuestion(int questionId) {
        List<Integer> list = new ArrayList<>();
        try {
            rs = db.doQuery("SELECT lwmkpid FROM lwmquestionknowledge WHERE lwmquestionid = ?", new Object[]{questionId});
            while (rs.next()) list.add(rs.getInt("lwmkpid"));
        } catch (Exception e) { e.printStackTrace(); }
        db.close();
        return list;
    }

    // Get KP names as comma-separated string per question
    public String getKPNamesByQuestion(int questionId) {
        StringBuilder sb = new StringBuilder();
        try {
            rs = db.doQuery(
                "SELECT kp.lwmkpname FROM lwmquestionknowledge qk " +
                "JOIN lwmknowledgepoint kp ON qk.lwmkpid = kp.lwmkpid " +
                "WHERE qk.lwmquestionid = ?", new Object[]{questionId});
            while (rs.next()) {
                if (sb.length() > 0) sb.append(", ");
                sb.append(rs.getString("lwmkpname"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        db.close();
        return sb.toString();
    }
}
