package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmquestionDAO;
import com.example.lwmexam.dao.lwmexam.lwmpaperDAO;
import com.example.lwmexam.entity.lwmexam.lwmExamPaper;
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
import java.util.ArrayList;
import java.util.List;

@WebServlet("/lwmUpdatePaper")
public class lwmUpdatePaper extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        if (teacher == null) { response.sendRedirect("login.jsp"); return; }

        int paperId = Integer.parseInt(request.getParameter("id"));
        lwmpaperDAO dao = new lwmpaperDAO();
        lwmExamPaper paper = dao.lwmQueryPaperById(paperId);
        if (paper == null || paper.getLwmteacherid() != teacher.getLwmteacherid()) {
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<script>alert('试卷不存在或无权修改');history.go(-1);</script>");
            return;
        }

        lwmquestionDAO qDao = new lwmquestionDAO();
        // Load current questions on this paper
        List<Integer> currentIds = dao.lwmGetPaperQuestionIds(paperId);
        List<lwmExamQuestion> currentQuestions = new ArrayList<>();
        for (int id : currentIds) {
            lwmExamQuestion q = qDao.lwmQueryById(id);
            if (q != null) currentQuestions.add(q);
        }

        // Load all questions for this paper's subject (for adding new ones)
        List<lwmExamQuestion> subjectQuestions = qDao.lwmQueryBySubjectType(
                String.valueOf(paper.getLwmsubjectid()), null, null);

        request.setAttribute("paper", paper);
        request.setAttribute("currentQuestions", currentQuestions);
        request.setAttribute("subjectQuestions", subjectQuestions);
        request.setAttribute("hasSubmit", dao.hasSubmitRecord(paperId));
        request.getRequestDispatcher("lwmteacher_paper_edit.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        int paperId = Integer.parseInt(request.getParameter("lwmpaperid"));
        lwmpaperDAO dao = new lwmpaperDAO();
        boolean hasSubmit = dao.hasSubmitRecord(paperId);

        // Update question composition only if no students have submitted
        if (!hasSubmit) {
            String[] qIds = request.getParameterValues("questionIds");
            if (qIds != null && qIds.length > 0) {
                // Delete old associations
                dao.lwmDeletePaperQuestions(paperId);

                lwmquestionDAO qDao = new lwmquestionDAO();
                int danxNum = 0, duoxNum = 0, pdNum = 0, jdNum = 0;
                int danxScore = 0, duoxScore = 0, pdScore = 0, jdScore = 0;
                StringBuilder danxNos = new StringBuilder(), duoxNos = new StringBuilder(),
                              pdNos = new StringBuilder(), jdNos = new StringBuilder();

                for (int i = 0; i < qIds.length; i++) {
                    int qId = Integer.parseInt(qIds[i]);
                    dao.lwmAddPaperQuestion(paperId, qId);
                    lwmExamQuestion q = qDao.lwmQueryById(qId);
                    if (q != null) {
                        String type = q.getLwmquestiontype();
                        if ("单选题".equals(type)) { danxNum++; danxNos.append(i+1).append(","); }
                        else if ("多选题".equals(type)) { duoxNum++; duoxNos.append(i+1).append(","); }
                        else if ("判断题".equals(type)) { pdNum++; pdNos.append(i+1).append(","); }
                        else if ("简答题".equals(type)) { jdNum++; jdNos.append(i+1).append(","); }
                    }
                }

                // Recalculate scores from form or fall back to existing
                try { danxScore = Integer.parseInt(request.getParameter("danxscore")); } catch(Exception e) {}
                try { duoxScore = Integer.parseInt(request.getParameter("duoxscore")); } catch(Exception e) {}
                try { pdScore = Integer.parseInt(request.getParameter("pdscore")); } catch(Exception e) {}
                try { jdScore = Integer.parseInt(request.getParameter("jdscore")); } catch(Exception e) {}

                lwmExamPaper p = dao.lwmQueryPaperById(paperId);
                p.setLwmdanxnum(danxNum); p.setLwmdanxscore(danxScore); p.setLwmdanxnos(rmComma(danxNos));
                p.setLwmduoxnum(duoxNum); p.setLwmduoxscore(duoxScore); p.setLwmduoxnos(rmComma(duoxNos));
                p.setLwmpdnum(pdNum); p.setLwmpdscore(pdScore); p.setLwmpdnos(rmComma(pdNos));
                p.setLwmjdnum(jdNum); p.setLwmjdscore(jdScore); p.setLwmjdnos(rmComma(jdNos));
                p.setLwmexamsore(danxNum*danxScore + duoxNum*duoxScore + pdNum*pdScore + jdNum*jdScore);
                p.setLwmpapername(request.getParameter("lwmpapername"));

                p.setLwmstarttime(request.getParameter("lwmstarttime"));
                p.setLwmendtime(request.getParameter("lwmendtime"));
                try { p.setLwmexamtime(Integer.parseInt(request.getParameter("lwmexamtime"))); } catch(Exception e) {}
                dao.lwmUpdatePaper(p);
                out.println("<script>alert('修改成功');location.href='lwmQueryPaper';</script>");
                return;
            }
        }

        // Basic info update only (has submitted or no question changes)
        lwmExamPaper paper = new lwmExamPaper();
        paper.setLwmpaperid(paperId);
        paper.setLwmpapername(request.getParameter("lwmpapername"));
        paper.setLwmsubjectid(Integer.parseInt(request.getParameter("lwmsubjectid")));

        paper.setLwmstarttime(request.getParameter("lwmstarttime"));
        paper.setLwmendtime(request.getParameter("lwmendtime"));
        try { paper.setLwmexamtime(Integer.parseInt(request.getParameter("lwmexamtime"))); } catch(Exception e) {}
        try { paper.setLwmexamsore(Integer.parseInt(request.getParameter("lwmexamsore"))); } catch(Exception e) {}

        int res = dao.lwmUpdatePaper(paper);
        if (res > 0) {
            out.println("<script>alert('修改成功');location.href='lwmQueryPaper';</script>");
        } else {
            out.println("<script>alert('修改失败');history.go(-1);</script>");
        }
    }

    private String rmComma(StringBuilder sb) {
        if (sb.length() > 0 && sb.charAt(sb.length()-1) == ',') sb.deleteCharAt(sb.length()-1);
        return sb.toString();
    }
}
