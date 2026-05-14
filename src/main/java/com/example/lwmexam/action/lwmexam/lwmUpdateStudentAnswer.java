package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.entity.lwmexam.lwmStudent;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Enumeration;

@WebServlet("/lwmUpdateStudentAnswer")
public class lwmUpdateStudentAnswer extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession();
        lwmStudent student = (lwmStudent) session.getAttribute("student");
        PrintWriter out = response.getWriter();

        if (student == null) { out.println("<script>alert('请先登录');location.href='login.jsp';</script>"); return; }

        int recordId = Integer.parseInt(request.getParameter("recordId"));

        // Verify this record belongs to the student and is not yet graded
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=utf8",
                "root", "123456");

            PreparedStatement checkStmt = conn.prepareStatement(
                "SELECT lwmsubmitstatus FROM lwmexamrecord WHERE lwmrecordid = ? AND lwmstudentid = ?");
            checkStmt.setInt(1, recordId);
            checkStmt.setInt(2, student.getLwmstudentid());
            ResultSet rs = checkStmt.executeQuery();
            if (!rs.next()) {
                rs.close(); checkStmt.close(); conn.close();
                out.println("<script>alert('记录不存在');history.go(-1);</script>");
                return;
            }
            int status = rs.getInt("lwmsubmitstatus");
            rs.close(); checkStmt.close();

            if (status != 1) {
                conn.close();
                out.println("<script>alert('该试卷已批阅，无法修改答案');history.go(-1);</script>");
                return;
            }

            // Update each answer
            Enumeration<String> paramNames = request.getParameterNames();
            int updated = 0;
            while (paramNames.hasMoreElements()) {
                String name = paramNames.nextElement();
                if (name.startsWith("ans_")) {
                    int answerId = Integer.parseInt(name.substring(4));
                    String newAnswer = request.getParameter(name);

                    // Verify this answer belongs to this student
                    PreparedStatement verifyStmt = conn.prepareStatement(
                        "SELECT lwmstudentid FROM lwmstudentanswer WHERE lwmanswerid = ? AND lwmrecordid = ?");
                    verifyStmt.setInt(1, answerId);
                    verifyStmt.setInt(2, recordId);
                    ResultSet vRs = verifyStmt.executeQuery();
                    if (vRs.next() && vRs.getInt("lwmstudentid") == student.getLwmstudentid()) {
                        // Update answer text and reset score
                        PreparedStatement updateStmt = conn.prepareStatement(
                            "UPDATE lwmstudentanswer SET lwmstudentanswer = ?, lwmquestionscore = 0 WHERE lwmanswerid = ?");
                        updateStmt.setString(1, newAnswer != null ? newAnswer : "");
                        updateStmt.setInt(2, answerId);
                        updateStmt.executeUpdate();
                        updateStmt.close();
                        updated++;
                    }
                    vRs.close(); verifyStmt.close();
                }
            }
            conn.close();

            out.println("<script>alert('答案修改成功，共更新 " + updated + " 道题');location.href='lwmViewExam?recordId=" + recordId + "';</script>");
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('修改失败');history.go(-1);</script>");
        }
    }
}
