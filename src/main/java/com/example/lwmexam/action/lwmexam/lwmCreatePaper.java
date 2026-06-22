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

@WebServlet("/lwmCreatePaper")
public class lwmCreatePaper extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession();
        lwmTeacher teacher = (lwmTeacher) session.getAttribute("teacher");
        PrintWriter out = response.getWriter();

        if (teacher == null) { out.println("<script>alert('请先登录');location.href='login.jsp';</script>"); return; }

        String mode = request.getParameter("mode");
        int subjectId = Integer.parseInt(request.getParameter("lwmsubjectid"));
        String classname = "";
        String paperName = request.getParameter("lwmpapername");
        String startTime = request.getParameter("lwmstarttime");
        String endTime = request.getParameter("lwmendtime");
        int examTime = 0;
        try {
            examTime = Integer.parseInt(request.getParameter("lwmexamtime"));
        } catch (NumberFormatException ignored) {}

        // Validate start time is before end time
        if (startTime != null && !startTime.isEmpty() && endTime != null && !endTime.isEmpty()) {
            if (startTime.compareTo(endTime) >= 0) {
                out.println("<script>alert('考试开始时间必须早于结束时间');history.go(-1);</script>");
                return;
            }
        }

        if (examTime <= 0) {
            out.println("<script>alert('考试时间必须大于0分钟');history.go(-1);</script>");
            return;
        }

        List<lwmExamQuestion> selectedQuestions = new ArrayList<>();
        lwmquestionDAO qDao = new lwmquestionDAO();
        int danxScore = 0, duoxScore = 0, pdScore = 0, jdScore = 0;

        if ("manual".equals(mode)) {
            String[] ids = request.getParameterValues("questionIds");
            if (ids == null || ids.length == 0) {
                out.println("<script>alert('请至少选择一道试题');history.go(-1);</script>"); return;
            }
            for (String id : ids) {
                lwmExamQuestion q = qDao.lwmQueryById(Integer.parseInt(id));
                if (q != null) selectedQuestions.add(q);
            }
            danxScore = Integer.parseInt(request.getParameter("danxscore"));
            duoxScore = Integer.parseInt(request.getParameter("duoxscore"));
            pdScore = Integer.parseInt(request.getParameter("pdscore"));
            jdScore = Integer.parseInt(request.getParameter("jdscore"));
        } else {
            int danxNum = Integer.parseInt(request.getParameter("danxnum"));
            int duoxNum = Integer.parseInt(request.getParameter("duoxnum"));
            int pdNum = Integer.parseInt(request.getParameter("pdnum"));
            int jdNum = Integer.parseInt(request.getParameter("jdnum"));
            danxScore = Integer.parseInt(request.getParameter("danxscore"));
            duoxScore = Integer.parseInt(request.getParameter("duoxscore"));
            pdScore = Integer.parseInt(request.getParameter("pdscore"));
            jdScore = Integer.parseInt(request.getParameter("jdscore"));

            if (danxNum + duoxNum + pdNum + jdNum <= 0) {
                out.println("<script>alert('请至少选择一道试题');history.go(-1);</script>"); return;
            }

            // Validate question counts against available in question bank
            Object[][] typeChecks = {{danxNum, "单选题"}, {duoxNum, "多选题"}, {pdNum, "判断题"}, {jdNum, "简答题"}};
            for (Object[] tc : typeChecks) {
                int need = (int) tc[0];
                if (need > 0) {
                    int available = qDao.lwmCountByType(subjectId, (String) tc[1]);
                    if (need > available) {
                        out.println("<script>alert('" + tc[1] + "数量不足：需要" + need + "道，题库仅有" + available + "道');history.go(-1);</script>");
                        return;
                    }
                }
            }

            selectedQuestions.addAll(qDao.lwmRandomPick(subjectId, "单选题", danxNum));
            selectedQuestions.addAll(qDao.lwmRandomPick(subjectId, "多选题", duoxNum));
            selectedQuestions.addAll(qDao.lwmRandomPick(subjectId, "判断题", pdNum));
            selectedQuestions.addAll(qDao.lwmRandomPick(subjectId, "简答题", jdNum));
        }

        // Categorize questions and build statistics
        int danxNum = 0, duoxNum = 0, pdNum = 0, jdNum = 0;

        if (danxScore < 0 || duoxScore < 0 || pdScore < 0 || jdScore < 0) {
            out.println("<script>alert('试题分值不能为负数');history.go(-1);</script>");
            return;
        }
        StringBuilder danxNos = new StringBuilder(), duoxNos = new StringBuilder(), pdNos = new StringBuilder(), jdNos = new StringBuilder();

        for (int i = 0; i < selectedQuestions.size(); i++) {
            String type = selectedQuestions.get(i).getLwmquestiontype();
            if ("单选题".equals(type)) { danxNum++; danxNos.append(i+1).append(","); }
            else if ("多选题".equals(type)) { duoxNum++; duoxNos.append(i+1).append(","); }
            else if ("判断题".equals(type)) { pdNum++; pdNos.append(i+1).append(","); }
            else if ("简答题".equals(type)) { jdNum++; jdNos.append(i+1).append(","); }
        }

        lwmExamPaper paper = new lwmExamPaper();
        paper.setLwmpapername(paperName);
        paper.setLwmsubjectid(subjectId);
        paper.setLwmstarttime(startTime);
        paper.setLwmendtime(endTime);
        paper.setLwmteacherid(teacher.getLwmteacherid());
        paper.setLwmclassname(classname);
        paper.setLwmexamtime(examTime);
        paper.setLwmdanxnum(danxNum); paper.setLwmdanxscore(danxScore); paper.setLwmdanxnos(rmComma(danxNos));
        paper.setLwmduoxnum(duoxNum); paper.setLwmduoxscore(duoxScore); paper.setLwmduoxnos(rmComma(duoxNos));
        paper.setLwmpdnum(pdNum); paper.setLwmpdscore(pdScore); paper.setLwmpdnos(rmComma(pdNos));
        paper.setLwmjdnum(jdNum); paper.setLwmjdscore(jdScore); paper.setLwmjdnos(rmComma(jdNos));
        paper.setLwmexamsore(danxNum*danxScore + duoxNum*duoxScore + pdNum*pdScore + jdNum*jdScore);

        lwmpaperDAO pDao = new lwmpaperDAO();

        if (pDao.lwmExistPaperByNameSubject(paperName, subjectId, teacher.getLwmteacherid())) {
            out.println("<script>alert('已存在相同名称和科目的试卷，请修改试卷名称或选择其他科目');history.go(-1);</script>");
            return;
        }

        int paperId = pDao.lwmAddPaper(paper);
        if (paperId > 0) {
            for (lwmExamQuestion q : selectedQuestions) {
                pDao.lwmAddPaperQuestion(paperId, q.getLwmquestionid());
            }
            out.println("<script>alert('试卷创建成功');location.href='lwmQueryPaper';</script>");
        } else {
            out.println("<script>alert('创建失败');history.go(-1);</script>");
        }
    }

    private String rmComma(StringBuilder sb) {
        if (sb.length() > 0 && sb.charAt(sb.length()-1) == ',') sb.deleteCharAt(sb.length()-1);
        return sb.toString();
    }
}
