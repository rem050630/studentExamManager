package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.entity.lwmexam.lwmTeacher;
import com.example.lwmexam.service.lwmexam.MysqlConn;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/lwmScoreAnalysis")
public class lwmScoreAnalysisAction extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        if (teacher == null) { response.sendRedirect("login.jsp"); return; }

        String paperIdStr = request.getParameter("paperid");
        String classname = request.getParameter("classname");
        String subjectIdStr = request.getParameter("subjectid");

        Integer paperId = (paperIdStr != null && !paperIdStr.isEmpty()) ? Integer.parseInt(paperIdStr) : null;
        Integer subjectId = (subjectIdStr != null && !subjectIdStr.isEmpty()) ? Integer.parseInt(subjectIdStr) : null;

        List<String[]> subjectList = new ArrayList<>(); // [id, name]
        List<String[]> paperList = new ArrayList<>();   // [id, name, classname, subjectid]
        List<String> classList = new ArrayList<>();

        MysqlConn db = new MysqlConn();
        ResultSet rs = null;

        try {
            // Load subjects for this teacher
            rs = db.doQuery(
                "SELECT DISTINCT p.lwmsubjectid, s.lwmsubjectname FROM lwmexampaper p " +
                "LEFT JOIN lwmexamsubject s ON p.lwmsubjectid = s.lwmsubjectid " +
                "WHERE p.lwmteacherid = ? ORDER BY s.lwmsubjectname",
                new Object[]{teacher.getLwmteacherid()});
            while (rs.next()) {
                subjectList.add(new String[]{String.valueOf(rs.getInt("lwmsubjectid")), rs.getString("lwmsubjectname")});
            }
            rs.close();

            // Load papers for this teacher (filter by subject if provided)
            String paperSql;
            Object[] paperParams;
            if (subjectId != null) {
                paperSql = "SELECT p.lwmpaperid, p.lwmpapername, p.lwmclassname, p.lwmsubjectid FROM lwmexampaper p " +
                           "WHERE p.lwmteacherid = ? AND p.lwmsubjectid = ? AND p.lwmclassname IS NOT NULL AND p.lwmclassname != '' ORDER BY p.lwmpaperid DESC";
                paperParams = new Object[]{teacher.getLwmteacherid(), subjectId};
            } else {
                paperSql = "SELECT p.lwmpaperid, p.lwmpapername, p.lwmclassname, p.lwmsubjectid FROM lwmexampaper p " +
                           "WHERE p.lwmteacherid = ? AND p.lwmclassname IS NOT NULL AND p.lwmclassname != '' ORDER BY p.lwmpaperid DESC";
                paperParams = new Object[]{teacher.getLwmteacherid()};
            }
            rs = db.doQuery(paperSql, paperParams);
            while (rs.next()) {
                paperList.add(new String[]{
                    String.valueOf(rs.getInt("lwmpaperid")),
                    rs.getString("lwmpapername"),
                    rs.getString("lwmclassname"),
                    String.valueOf(rs.getInt("lwmsubjectid"))
                });
            }
            rs.close();

            // Load distinct class names for this teacher
            rs = db.doQuery(
                "SELECT DISTINCT lwmclassname FROM lwmexampaper WHERE lwmteacherid = ? AND lwmclassname IS NOT NULL AND lwmclassname != '' ORDER BY lwmclassname",
                new Object[]{teacher.getLwmteacherid()});
            while (rs.next()) classList.add(rs.getString("lwmclassname"));
            rs.close();
        } catch (Exception e) { e.printStackTrace(); }
        db.close();

        // Query score stats if paperId is provided
        Map<String, Object> stats = null;
        int[] distribution = null;
        double passRate = 0;
        List<Map<String, Object>> studentScores = new ArrayList<>();

        if (paperId != null) {
            db = new MysqlConn();
            try {
                // Query score statistics
                StringBuilder statsSql = new StringBuilder(
                    "SELECT COUNT(*) AS cnt, AVG(sc.lwmtotalscore) AS avg, MAX(sc.lwmtotalscore) AS max, " +
                    "MIN(sc.lwmtotalscore) AS min, STDDEV_POP(sc.lwmtotalscore) AS stddev " +
                    "FROM lwmexamscore sc " +
                    "JOIN lwmexamrecord r ON sc.lwmrecordid = r.lwmrecordid " +
                    "JOIN lwmstudent s ON sc.lwmstudentid = s.lwmstudentid " +
                    "WHERE sc.lwmpaperid = ?");
                List<Object> statsParams = new ArrayList<>();
                statsParams.add(paperId);
                if (classname != null && !classname.isEmpty()) {
                    statsSql.append(" AND s.lwmclassname = ?");
                    statsParams.add(classname);
                }

                rs = db.doQuery(statsSql.toString(), statsParams.toArray());
                if (rs.next()) {
                    stats = new LinkedHashMap<>();
                    stats.put("cnt", rs.getInt("cnt"));
                    stats.put("avg", rs.getDouble("avg"));
                    stats.put("max", rs.getInt("max"));
                    stats.put("min", rs.getInt("min"));
                    stats.put("stddev", rs.getDouble("stddev"));
                }
                rs.close();

                // Query score distribution into 5 buckets
                StringBuilder distSql = new StringBuilder(
                    "SELECT " +
                    "SUM(CASE WHEN sc.lwmtotalscore < 60 THEN 1 ELSE 0 END) AS b0_59, " +
                    "SUM(CASE WHEN sc.lwmtotalscore >= 60 AND sc.lwmtotalscore < 70 THEN 1 ELSE 0 END) AS b60_69, " +
                    "SUM(CASE WHEN sc.lwmtotalscore >= 70 AND sc.lwmtotalscore < 80 THEN 1 ELSE 0 END) AS b70_79, " +
                    "SUM(CASE WHEN sc.lwmtotalscore >= 80 AND sc.lwmtotalscore < 90 THEN 1 ELSE 0 END) AS b80_89, " +
                    "SUM(CASE WHEN sc.lwmtotalscore >= 90 THEN 1 ELSE 0 END) AS b90_100 " +
                    "FROM lwmexamscore sc " +
                    "JOIN lwmexamrecord r ON sc.lwmrecordid = r.lwmrecordid " +
                    "JOIN lwmstudent s ON sc.lwmstudentid = s.lwmstudentid " +
                    "WHERE sc.lwmpaperid = ?");
                List<Object> distParams = new ArrayList<>();
                distParams.add(paperId);
                if (classname != null && !classname.isEmpty()) {
                    distSql.append(" AND s.lwmclassname = ?");
                    distParams.add(classname);
                }

                rs = db.doQuery(distSql.toString(), distParams.toArray());
                if (rs.next()) {
                    distribution = new int[5];
                    distribution[0] = rs.getInt("b0_59");
                    distribution[1] = rs.getInt("b60_69");
                    distribution[2] = rs.getInt("b70_79");
                    distribution[3] = rs.getInt("b80_89");
                    distribution[4] = rs.getInt("b90_100");
                }
                rs.close();

                // Query pass rate (score >= 60)
                StringBuilder passSql = new StringBuilder(
                    "SELECT COUNT(*) AS total, SUM(CASE WHEN sc.lwmtotalscore >= 60 THEN 1 ELSE 0 END) AS pass_count " +
                    "FROM lwmexamscore sc " +
                    "JOIN lwmexamrecord r ON sc.lwmrecordid = r.lwmrecordid " +
                    "JOIN lwmstudent s ON sc.lwmstudentid = s.lwmstudentid " +
                    "WHERE sc.lwmpaperid = ?");
                List<Object> passParams = new ArrayList<>();
                passParams.add(paperId);
                if (classname != null && !classname.isEmpty()) {
                    passSql.append(" AND s.lwmclassname = ?");
                    passParams.add(classname);
                }

                rs = db.doQuery(passSql.toString(), passParams.toArray());
                if (rs.next()) {
                    int total = rs.getInt("total");
                    int passCount = rs.getInt("pass_count");
                    passRate = total > 0 ? (double) passCount / total * 100.0 : 0;
                }
                rs.close();

                // Query student detail list
                StringBuilder stSql = new StringBuilder(
                    "SELECT s.lwmstudentno, s.lwmstudentname, s.lwmclassname, sc.lwmtotalscore " +
                    "FROM lwmexamscore sc " +
                    "JOIN lwmexamrecord r ON sc.lwmrecordid = r.lwmrecordid " +
                    "JOIN lwmstudent s ON sc.lwmstudentid = s.lwmstudentid " +
                    "WHERE sc.lwmpaperid = ?");
                List<Object> stParams = new ArrayList<>();
                stParams.add(paperId);
                if (classname != null && !classname.isEmpty()) {
                    stSql.append(" AND s.lwmclassname = ?");
                    stParams.add(classname);
                }
                stSql.append(" ORDER BY sc.lwmtotalscore DESC");

                rs = db.doQuery(stSql.toString(), stParams.toArray());
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("no", rs.getString("lwmstudentno"));
                    row.put("name", rs.getString("lwmstudentname"));
                    row.put("classname", rs.getString("lwmclassname"));
                    row.put("score", rs.getInt("lwmtotalscore"));
                    studentScores.add(row);
                }
                rs.close();
            } catch (Exception e) { e.printStackTrace(); }
            db.close();
        }

        request.setAttribute("subjectList", subjectList);
        request.setAttribute("paperList", paperList);
        request.setAttribute("classList", classList);
        request.setAttribute("selectedPaperId", paperIdStr != null ? paperIdStr : "");
        request.setAttribute("selectedClass", classname != null ? classname : "");
        request.setAttribute("selectedSubjectId", subjectIdStr != null ? subjectIdStr : "");
        request.setAttribute("stats", stats);
        request.setAttribute("distribution", distribution);
        request.setAttribute("passRate", passRate);
        request.setAttribute("studentScores", studentScores);
        request.getRequestDispatcher("lwmteacher_score_analysis.jsp").forward(request, response);
    }
}
