//package com.example.lwmexam.action.lwmexam;
//import com.example.lwmexam.dao.lwmexam.lwmTeacherDAO;
//import com.example.lwmexam.dao.lwmexam.lwmsubjectDAO;
//import com.example.lwmexam.entity.lwmexam.lwmSubject;
//import com.example.lwmexam.entity.lwmexam.lwmTeacher;
//
//import javax.servlet.ServletException;
//import javax.servlet.annotation.WebServlet;
//import javax.servlet.http.HttpServlet;
//import javax.servlet.http.HttpServletRequest;
//import javax.servlet.http.HttpServletResponse;
//import java.io.IOException;
//import java.util.List;
//
//@WebServlet("/lwmTeacherAssignCourse")
//public class lwmTeacherAssignCourse extends HttpServlet {
//    @Override
//    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
//        this.doPost(request,response);
//    }
//
//    @Override
//    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
//        int id = Integer.parseInt(request.getParameter("id"));
//
//        lwmTeacherDAO dao = new lwmTeacherDAO();
//        lwmsubjectDAO sdao = new lwmsubjectDAO();
//
//        lwmTeacher teacher = dao.lwmQueryTeacherById(id);
//        List<lwmSubject> subjectList = sdao.lwmQueryAllSubject();
//        List<String> classList = dao.lwmGetAllClassName();
//
//        request.setAttribute("teacher", teacher);
//        request.setAttribute("subjectList", subjectList);
//        request.setAttribute("classList", classList);
//
//        request.getRequestDispatcher("lwmaddcourse.jsp").forward(request, response);
//    }
//}