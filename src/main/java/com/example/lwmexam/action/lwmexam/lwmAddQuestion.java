package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmquestionDAO;
import com.example.lwmexam.dao.lwmexam.lwmKnowledgePointDAO;
import com.example.lwmexam.entity.lwmexam.lwmExamQuestion;
import com.example.lwmexam.entity.lwmexam.lwmTeacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/lwmAddQuestion")
public class lwmAddQuestion extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        PrintWriter out = response.getWriter();

        try {
        if (teacher == null) {
            out.println("<script>alert('请先登录');location.href='login.jsp';</script>");
            out.flush(); return;
        }

        lwmExamQuestion q = new lwmExamQuestion();
        q.setLwmsubjectid(Integer.parseInt(request.getParameter("lwmsubjectid")));
        q.setLwmquestiontype(request.getParameter("lwmquestiontype"));
        q.setLwmquestioncontent(request.getParameter("lwmquestioncontent"));
        q.setLwmoptiona(request.getParameter("lwmoptiona") != null ? request.getParameter("lwmoptiona") : "");
        q.setLwmoptionb(request.getParameter("lwmoptionb") != null ? request.getParameter("lwmoptionb") : "");
        q.setLwmoptionc(request.getParameter("lwmoptionc") != null ? request.getParameter("lwmoptionc") : "");
        q.setLwmoptiond(request.getParameter("lwmoptiond") != null ? request.getParameter("lwmoptiond") : "");
        String[] answers = request.getParameterValues("lwmcorrectanswer");
        StringBuilder answerSb = new StringBuilder();
        if (answers != null) {
            for (String a : answers) {
                if (a != null && !a.isEmpty()) {
                    if (answerSb.length() > 0) answerSb.append(",");
                    answerSb.append(a);
                }
            }
        }
        String answer = answerSb.toString();
        q.setLwmcorrectanswer(answer);

        String questionType = q.getLwmquestiontype();

        if (answer == null || answer.isEmpty()) {
            out.println("<script>alert('请选择正确答案');history.go(-1);</script>");
            out.flush(); return;
        }

        if ("单选题".equals(questionType) || "多选题".equals(questionType)) {
            String optA = q.getLwmoptiona(), optB = q.getLwmoptionb();
            String optC = q.getLwmoptionc(), optD = q.getLwmoptiond();
            if (optA == null || optA.trim().isEmpty() ||
                optB == null || optB.trim().isEmpty() ||
                optC == null || optC.trim().isEmpty() ||
                optD == null || optD.trim().isEmpty()) {
                out.println("<script>alert('请填写全部ABCD选项的内容');history.go(-1);</script>");
                out.flush(); return;
            }
        }

        lwmquestionDAO dao = new lwmquestionDAO();

        if (dao.lwmExistQuestionByContent(q)) {
            out.print("<script>alert('已存在题目内容相同的" + questionType + "，请勿重复添加');history.go(-1);</script>");
            out.flush(); return;
        }

        if (dao.lwmExistQuestion(q)) {
            out.print("<script>alert('试题已存在，请勿重复添加');history.go(-1);</script>");
            out.flush(); return;
        }

        int res = dao.lwmAddQuestion(q);
        if (res > 0) {
            // Save knowledge point links
            String[] kpidsParam = request.getParameterValues("kpids");
            if (kpidsParam != null && kpidsParam.length > 0) {
                // Get the newly inserted question ID
                int newQid = 0;
                try {
                    java.sql.ResultSet rs = null;
                    com.example.lwmexam.service.lwmexam.MysqlConn conn = new com.example.lwmexam.service.lwmexam.MysqlConn();
                    rs = conn.doQuery(
                        "SELECT MAX(lwmquestionid) FROM lwmexamquestion WHERE lwmsubjectid = ? AND lwmquestiontype = ? AND lwmquestioncontent = ?",
                        new Object[]{q.getLwmsubjectid(), q.getLwmquestiontype(), q.getLwmquestioncontent()});
                    if (rs.next()) newQid = rs.getInt(1);
                    rs.close();
                    conn.close();
                } catch (Exception ignored) {}
                if (newQid > 0) {
                    int[] kpids = new int[kpidsParam.length];
                    for (int i = 0; i < kpidsParam.length; i++) {
                        kpids[i] = Integer.parseInt(kpidsParam[i]);
                    }
                    lwmKnowledgePointDAO kpDao = new lwmKnowledgePointDAO();
                    kpDao.saveQuestionKPs(newQid, kpids);
                }
            }
            out.print("<script>alert('添加成功');location.href='lwmQueryQuestion';</script>");
        } else {
            out.print("<script>alert('添加失败');history.go(-1);</script>");
        }
        out.flush();

        } catch (Exception e) {
            e.printStackTrace();
            out.print("<script>alert('系统错误，请重试');history.go(-1);</script>");
            out.flush();
        }
    }
}
