package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.dao.lwmexam.lwmMistakeBookDAO;
import com.example.lwmexam.entity.lwmexam.lwmStudent;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/lwmKnowledgeMastery")
public class lwmKnowledgeMasteryAction extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        HttpSession session = request.getSession();
        lwmStudent student = (lwmStudent) session.getAttribute("student");
        if (student == null) { response.getWriter().print("[]"); return; }

        int subjectId = Integer.parseInt(request.getParameter("subjectid"));
        lwmMistakeBookDAO dao = new lwmMistakeBookDAO();
        List<String[]> data = dao.getKPMastery(student.getLwmstudentid(), subjectId);

        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < data.size(); i++) {
            String[] row = data.get(i);
            int total = Integer.parseInt(row[2]);
            int wrong = Integer.parseInt(row[3]);
            double mastery = total > 0 ? Math.max(0, 1.0 - (double) wrong / total) : 1.0;
            json.append("{");
            json.append("\"kpid\":").append(row[0]).append(",");
            json.append("\"kpname\":\"").append(row[1]).append("\",");
            json.append("\"total\":").append(total).append(",");
            json.append("\"wrong\":").append(wrong).append(",");
            json.append("\"mastery\":").append(String.format("%.2f", mastery));
            json.append("}");
            if (i < data.size() - 1) json.append(",");
        }
        json.append("]");
        response.getWriter().print(json.toString());
    }
}
