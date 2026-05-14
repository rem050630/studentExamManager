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

    // Private helper: executes a query and maps ResultSet to List<lwmExamQuestion>.
    // Handles subjectname from JOIN if present (catch SQLException silently).
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
        } catch (Exception e) { e.printStackTrace(); }
        db.close();
        return list;
    }

    // Query questions by subject IDs (comma-separated), optional questiontype filter, optional keyword search.
    // subjectIds can be null/empty (no filter). questiontype can be null/empty (all types).
    // keyword searches in question content.
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

    // Add a new question. Returns row count (1 on success).
    public int lwmAddQuestion(lwmExamQuestion q) {
        res = db.doUpdate(
            "INSERT INTO lwmexamquestion(lwmsubjectid,lwmquestiontype,lwmquestioncontent,lwmoptiona,lwmoptionb,lwmoptionc,lwmoptiond,lwmcorrectanswer) VALUES(?,?,?,?,?,?,?,?)",
            new Object[]{q.getLwmsubjectid(), q.getLwmquestiontype(), q.getLwmquestioncontent(),
                    q.getLwmoptiona(), q.getLwmoptionb(), q.getLwmoptionc(), q.getLwmoptiond(), q.getLwmcorrectanswer()});
        db.close();
        return res;
    }

    // Query single question by ID. Returns null if not found.
    public lwmExamQuestion lwmQueryById(int id) {
        List<lwmExamQuestion> list = lwmQuerySomeQuestion(
            "SELECT q.*, s.lwmsubjectname FROM lwmexamquestion q LEFT JOIN lwmexamsubject s ON q.lwmsubjectid = s.lwmsubjectid WHERE q.lwmquestionid = ?",
            new Object[]{id});
        return list.isEmpty() ? null : list.get(0);
    }

    // Update a question. Returns row count.
    public int lwmUpdateQuestion(lwmExamQuestion q) {
        res = db.doUpdate(
            "UPDATE lwmexamquestion SET lwmsubjectid=?,lwmquestiontype=?,lwmquestioncontent=?,lwmoptiona=?,lwmoptionb=?,lwmoptionc=?,lwmoptiond=?,lwmcorrectanswer=? WHERE lwmquestionid=?",
            new Object[]{q.getLwmsubjectid(), q.getLwmquestiontype(), q.getLwmquestioncontent(),
                    q.getLwmoptiona(), q.getLwmoptionb(), q.getLwmoptionc(), q.getLwmoptiond(),
                    q.getLwmcorrectanswer(), q.getLwmquestionid()});
        db.close();
        return res;
    }

    // Delete a question by ID. Returns row count.
    public int lwmDeleteQuestion(int id) {
        res = db.doUpdate("DELETE FROM lwmexamquestion WHERE lwmquestionid = ?", new Object[]{id});
        db.close();
        return res;
    }

    // Randomly pick N questions for a given subject and type. Used for auto paper generation.
    public List<lwmExamQuestion> lwmRandomPick(int subjectId, String questiontype, int count) {
        return lwmQuerySomeQuestion(
            "SELECT q.*, s.lwmsubjectname FROM lwmexamquestion q " +
            "LEFT JOIN lwmexamsubject s ON q.lwmsubjectid = s.lwmsubjectid " +
            "WHERE q.lwmsubjectid = ? AND q.lwmquestiontype = ? ORDER BY RAND() LIMIT ?",
            new Object[]{subjectId, questiontype, count});
    }

    // Count questions by subject and type.
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
