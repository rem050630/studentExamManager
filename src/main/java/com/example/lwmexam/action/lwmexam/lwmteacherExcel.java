package com.example.lwmexam.action.lwmexam;

import com.example.lwmexam.service.lwmexam.ExcelBook;
import com.example.lwmexam.service.lwmexam.MysqlConn;
import com.jspsmart.upload.SmartUpload;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.ResultSet;
import java.util.ArrayList;

@WebServlet("/lwmteacherExcel")
public class lwmteacherExcel extends HttpServlet {
    private ServletConfig config;
    public final void init(ServletConfig config) throws ServletException {
        this.config = config;
    }
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        MysqlConn db = new MysqlConn();
        ResultSet rs = null;
        ExcelBook book = new ExcelBook();
        String path = "D:/教师信息.xls";

        // 查询教师表
        rs = db.doQuery("select * from lwmteacher", new Object[]{});

        // 导出表头（和你的字段一一对应）
        book.excelOut(path, rs, new Object[]{
                "教师ID", "工号", "姓名", "密码", "性别", "联系电话"
        });

        System.out.println("教师信息导出成功");

        // 下载文件
        SmartUpload myload = new SmartUpload();
        try {
            myload.initialize(config, request, response);
            myload.downloadFile(path);

            // 删除临时文件
            File file = new File(path);
            if (file.exists()) {
                file.delete();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        SmartUpload myload = new SmartUpload();
        String path = "D:/教师信息.xls";

        try {
            myload.initialize(config, request, response);
            myload.upload();

            com.jspsmart.upload.File file = myload.getFiles().getFile(0);
            file.saveAs(path);

            ExcelBook book = new ExcelBook();
            MysqlConn db = new MysqlConn();
            ArrayList<String[]> list = book.ExcelIn(path);

            // 循环插入教师
            for (int i = 0; i < list.size(); i++) {
                db.doUpdate(
                        "insert into lwmteacher values(?,?,?,?,?,?)",
                        list.get(i)
                );
            }

            response.setContentType("text/html;charset=utf-8");
            PrintWriter out = response.getWriter();
            out.println("<script>alert('教师导入成功！');location.href='lwmteacher_xx';</script>");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}