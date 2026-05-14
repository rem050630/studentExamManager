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

    // Query all answers for a given exam record, joined with question details.
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

    // Save score for a single question answer.
    public void lwmSaveQuestionScore(int answerId, int score) {
        db.doUpdate("UPDATE lwmstudentanswer SET lwmquestionscore = ? WHERE lwmanswerid = ?",
                new Object[]{score, answerId});
        db.close();
    }

    // Insert or update (UPSERT) exam score. Uses INSERT ... ON DUPLICATE KEY UPDATE.
    public int lwmSaveScore(lwmExamScore score) {
        res = db.doUpdate(
            "INSERT INTO lwmexamscore(lwmrecordid,lwmtotalscore,lwmteacherid,lwmstudentid,lwmpaperid) " +
            "VALUES(?,?,?,?,?) ON DUPLICATE KEY UPDATE lwmtotalscore=?,lwmteacherid=?",
            new Object[]{score.getLwmrecordid(),score.getLwmtotalscore(),score.getLwmteacherid(),score.getLwmstudentid(),score.getLwmpaperid(),score.getLwmtotalscore(),score.getLwmteacherid()});
        db.close();
        return res;
    }
}
