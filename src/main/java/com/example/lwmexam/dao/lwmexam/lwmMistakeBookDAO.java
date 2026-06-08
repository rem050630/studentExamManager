package com.example.lwmexam.dao.lwmexam;

import com.example.lwmexam.entity.lwmexam.lwmMistakeBook;
import com.example.lwmexam.service.lwmexam.MysqlConn;

import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class lwmMistakeBookDAO {
    MysqlConn db = new MysqlConn();
    ResultSet rs = null;
    int res = 0;

    // Paginated mistake list with question details and KP names
    public List<lwmMistakeBook> queryMistakes(int studentId, Integer subjectId, Integer kpId, Integer reviewStatus, int start, int pageSize) {
        List<lwmMistakeBook> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT mb.*, q.lwmquestiontype, q.lwmquestioncontent, q.lwmoptiona, q.lwmoptionb, " +
            "q.lwmoptionc, q.lwmoptiond, q.lwmcorrectanswer, s.lwmsubjectname, q.lwmsubjectid, " +
            "(SELECT GROUP_CONCAT(kp.lwmkpname SEPARATOR ', ') FROM lwmquestionknowledge qk " +
            "JOIN lwmknowledgepoint kp ON qk.lwmkpid = kp.lwmkpid WHERE qk.lwmquestionid = mb.lwmquestionid) AS lwmkpnames, " +
            "(SELECT sa.lwmstudentanswer FROM lwmstudentanswer sa " +
            "JOIN lwmexamrecord r ON sa.lwmrecordid = r.lwmrecordid " +
            "WHERE sa.lwmquestionid = mb.lwmquestionid AND r.lwmstudentid = mb.lwmstudentid " +
            "ORDER BY r.lwmstarttime DESC LIMIT 1) AS lwmstudentanswer " +
            "FROM lwmmistakebook mb " +
            "JOIN lwmexamquestion q ON mb.lwmquestionid = q.lwmquestionid " +
            "LEFT JOIN lwmexamsubject s ON q.lwmsubjectid = s.lwmsubjectid " +
            "WHERE mb.lwmstudentid = ? AND mb.lwmiswrong = 1 ");
        List<Object> params = new ArrayList<>();
        params.add(studentId);
        if (subjectId != null) {
            sql.append("AND q.lwmsubjectid = ? ");
            params.add(subjectId);
        }
        if (kpId != null) {
            sql.append("AND EXISTS (SELECT 1 FROM lwmquestionknowledge qk WHERE qk.lwmquestionid = mb.lwmquestionid AND qk.lwmkpid = ?) ");
            params.add(kpId);
        }
        if (reviewStatus != null) {
            sql.append("AND mb.lwmreviewstatus = ? ");
            params.add(reviewStatus);
        }
        sql.append("ORDER BY mb.lwmlastupdatetime DESC LIMIT ?,?");
        params.add(start);
        params.add(pageSize);
        try {
            rs = db.doQuery(sql.toString(), params.toArray());
            while (rs.next()) {
                lwmMistakeBook mb = new lwmMistakeBook();
                mb.setLwmmid(rs.getInt("lwmmid"));
                mb.setLwmstudentid(rs.getInt("lwmstudentid"));
                mb.setLwmquestionid(rs.getInt("lwmquestionid"));
                mb.setLwmiswrong(rs.getInt("lwmiswrong"));
                mb.setLwmreviewstatus(rs.getInt("lwmreviewstatus"));
                mb.setLwmlastupdatetime(rs.getString("lwmlastupdatetime"));
                mb.setLwmquestiontype(rs.getString("lwmquestiontype"));
                mb.setLwmquestioncontent(rs.getString("lwmquestioncontent"));
                mb.setLwmoptiona(rs.getString("lwmoptiona"));
                mb.setLwmoptionb(rs.getString("lwmoptionb"));
                mb.setLwmoptionc(rs.getString("lwmoptionc"));
                mb.setLwmoptiond(rs.getString("lwmoptiond"));
                mb.setLwmcorrectanswer(rs.getString("lwmcorrectanswer"));
                mb.setLwmsubjectname(rs.getString("lwmsubjectname"));
                mb.setLwmsubjectid(rs.getInt("lwmsubjectid"));
                mb.setLwmkpnames(rs.getString("lwmkpnames"));
                mb.setLwmstudentanswer(rs.getString("lwmstudentanswer"));
                list.add(mb);
            }
        } catch (Exception e) { e.printStackTrace(); }
        db.close();
        return list;
    }

    public int countMistakes(int studentId, Integer subjectId, Integer kpId, Integer reviewStatus) {
        int count = 0;
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM lwmmistakebook mb " +
            "JOIN lwmexamquestion q ON mb.lwmquestionid = q.lwmquestionid " +
            "WHERE mb.lwmstudentid = ? AND mb.lwmiswrong = 1 ");
        List<Object> params = new ArrayList<>();
        params.add(studentId);
        if (subjectId != null) { sql.append("AND q.lwmsubjectid = ? "); params.add(subjectId); }
        if (kpId != null) {
            sql.append("AND EXISTS (SELECT 1 FROM lwmquestionknowledge qk WHERE qk.lwmquestionid = mb.lwmquestionid AND qk.lwmkpid = ?) ");
            params.add(kpId);
        }
        if (reviewStatus != null) { sql.append("AND mb.lwmreviewstatus = ? "); params.add(reviewStatus); }
        try {
            rs = db.doQuery(sql.toString(), params.toArray());
            if (rs.next()) count = rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        db.close();
        return count;
    }

    // Upsert mistake: call on exam submit
    public void upsertMistake(int studentId, int questionId, boolean isWrong) {
        db.doUpdate(
            "INSERT INTO lwmmistakebook(lwmstudentid,lwmquestionid,lwmiswrong,lwmreviewstatus,lwmlastupdatetime) " +
            "VALUES(?,?,?,0,NOW()) ON DUPLICATE KEY UPDATE lwmiswrong=?, lwmlastupdatetime=NOW()",
            new Object[]{studentId, questionId, isWrong ? 1 : 0, isWrong ? 1 : 0});
        db.close();
    }

    // Update review status (0=unreviewed, 1=reviewed, 2=mastered)
    public void updateReviewStatus(int studentId, int questionId, int status) {
        db.doUpdate(
            "UPDATE lwmmistakebook SET lwmreviewstatus = ? WHERE lwmstudentid = ? AND lwmquestionid = ?",
            new Object[]{status, studentId, questionId});
        db.close();
    }

    // Get per-KP mastery data for radar chart: returns List of String[] {kpid, kpname, total_q, wrong_q}
    public List<String[]> getKPMastery(int studentId, int subjectId) {
        List<String[]> list = new ArrayList<>();
        String sql =
            "SELECT kp.lwmkpid, kp.lwmkpname, " +
            "COUNT(DISTINCT mb.lwmquestionid) AS total_q, " +
            "SUM(CASE WHEN mb.lwmiswrong = 1 THEN 1 ELSE 0 END) AS wrong_q " +
            "FROM lwmknowledgepoint kp " +
            "LEFT JOIN lwmquestionknowledge qk ON kp.lwmkpid = qk.lwmkpid " +
            "LEFT JOIN lwmmistakebook mb ON qk.lwmquestionid = mb.lwmquestionid AND mb.lwmstudentid = ? " +
            "WHERE kp.lwmsubjectid = ? " +
            "GROUP BY kp.lwmkpid, kp.lwmkpname " +
            "HAVING total_q > 0";
        try {
            rs = db.doQuery(sql, new Object[]{studentId, subjectId});
            while (rs.next()) {
                list.add(new String[]{
                    rs.getString("lwmkpid"),
                    rs.getString("lwmkpname"),
                    String.valueOf(rs.getInt("total_q")),
                    String.valueOf(rs.getInt("wrong_q"))
                });
            }
        } catch (Exception e) { e.printStackTrace(); }
        db.close();
        return list;
    }
}
