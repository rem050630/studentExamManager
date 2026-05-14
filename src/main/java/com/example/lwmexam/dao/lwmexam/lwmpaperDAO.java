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

    // Private helper: map ResultSet to List<lwmExamPaper>. Handles JOIN fields silently.
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

    // Query all papers for a teacher.
    public List<lwmExamPaper> lwmQueryByTeacher(int teacherId) {
        return lwmQuerySomePaper(
            "SELECT p.*, s.lwmsubjectname FROM lwmexampaper p " +
            "LEFT JOIN lwmexamsubject s ON p.lwmsubjectid = s.lwmsubjectid " +
            "WHERE p.lwmteacherid = ? ORDER BY p.lwmpaperid DESC",
            new Object[]{teacherId});
    }

    // Insert a new paper. Returns the auto-generated paper ID, or 0 on failure.
    public int lwmAddPaper(lwmExamPaper p) {
        int paperId = 0;
        res = db.doUpdate(
            "INSERT INTO lwmexampaper(lwmpapername,lwmsubjectid,lwmexamtime,lwmexamsore,lwmstarttime,lwmendtime,lwmteacherid,lwmclassname,lwmdanxnum,lwmdanxscore,lwmdanxnos,lwmduoxnum,lwmduoxscore,lwmduoxnos,lwmpdnum,lwmpdscore,lwmpdnos,lwmjdnum,lwmjdscore,lwmjdnos) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            new Object[]{p.getLwmpapername(),p.getLwmsubjectid(),p.getLwmexamtime(),p.getLwmexamsore(),p.getLwmstarttime(),p.getLwmendtime(),p.getLwmteacherid(),p.getLwmclassname(),p.getLwmdanxnum(),p.getLwmdanxscore(),p.getLwmdanxnos(),p.getLwmduoxnum(),p.getLwmduoxscore(),p.getLwmduoxnos(),p.getLwmpdnum(),p.getLwmpdscore(),p.getLwmpdnos(),p.getLwmjdnum(),p.getLwmjdscore(),p.getLwmjdnos()});
        if (res > 0) {
            // LAST_INSERT_ID() requires same connection as INSERT, so use MAX
            // to retrieve the inserted paper ID
            try {
                rs = db.doQuery(
                    "SELECT MAX(lwmpaperid) FROM lwmexampaper WHERE lwmteacherid=? AND lwmpapername=?",
                    new Object[]{p.getLwmteacherid(), p.getLwmpapername()});
                if (rs.next()) paperId = rs.getInt(1);
            } catch (Exception e) { e.printStackTrace(); }
        }
        db.close();
        return paperId;
    }

    // Link a question to a paper.
    public void lwmAddPaperQuestion(int paperId, int questionId) {
        db.doUpdate("INSERT INTO lwmpaperquestion(lwmpaperid,lwmquestionid) VALUES(?,?)",
                new Object[]{paperId, questionId});
        db.close();
    }

    // Get all question IDs for a paper.
    public List<Integer> lwmGetPaperQuestionIds(int paperId) {
        List<Integer> ids = new ArrayList<>();
        try {
            rs = db.doQuery("SELECT lwmquestionid FROM lwmpaperquestion WHERE lwmpaperid = ?", new Object[]{paperId});
            while (rs.next()) ids.add(rs.getInt("lwmquestionid"));
        } catch (Exception e) { e.printStackTrace(); }
        db.close();
        return ids;
    }

    // Query a paper by ID.
    public lwmExamPaper lwmQueryPaperById(int paperId) {
        List<lwmExamPaper> list = lwmQuerySomePaper(
            "SELECT p.*, s.lwmsubjectname FROM lwmexampaper p " +
            "LEFT JOIN lwmexamsubject s ON p.lwmsubjectid = s.lwmsubjectid WHERE p.lwmpaperid = ?",
            new Object[]{paperId});
        return list.isEmpty() ? null : list.get(0);
    }

    // Update paper basic info (not question composition).
    public int lwmUpdatePaper(lwmExamPaper p) {
        res = db.doUpdate(
            "UPDATE lwmexampaper SET lwmpapername=?,lwmsubjectid=?,lwmexamtime=?,lwmexamsore=?,lwmstarttime=?,lwmendtime=?,lwmclassname=? WHERE lwmpaperid=?",
            new Object[]{p.getLwmpapername(),p.getLwmsubjectid(),p.getLwmexamtime(),p.getLwmexamsore(),p.getLwmstarttime(),p.getLwmendtime(),p.getLwmclassname(),p.getLwmpaperid()});
        db.close();
        return res;
    }

    // Delete all question associations for a paper.
    public void lwmDeletePaperQuestions(int paperId) {
        db.doUpdate("DELETE FROM lwmpaperquestion WHERE lwmpaperid = ?", new Object[]{paperId});
        db.close();
    }

    // Delete a paper and its question associations.
    public int lwmDeletePaper(int paperId) {
        lwmDeletePaperQuestions(paperId);
        res = db.doUpdate("DELETE FROM lwmexampaper WHERE lwmpaperid = ?", new Object[]{paperId});
        db.close();
        return res;
    }

    // Check if any student has submitted this paper.
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
