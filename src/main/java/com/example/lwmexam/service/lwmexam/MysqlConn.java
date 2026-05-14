package com.example.lwmexam.service.lwmexam;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class MysqlConn {
    String Driver = "com.mysql.cj.jdbc.Driver";
    String url = "jdbc:mysql://localhost:3306/lwmexam?serverTimezone=UTC&useUnicode=true&characterEncoding=gbk&mysqlEncoding=utf8";
    String user = "root";
    String password = "123456";
    Connection conn = null;//连接
    PreparedStatement pstmt = null;//预处理命令
    ResultSet rs = null;//结果集
    int res = 0;

    public void getConnection(){
        try {
            Class.forName(Driver);//加载驱动
            conn = DriverManager.getConnection(url, user, password);//建立连接
        }catch (Exception e){
            System.out.println("建立失败!");
            e.printStackTrace();
        }
    }
    public ResultSet doQuery(String sql, Object[] param){
        this.getConnection();
        try {
            pstmt = this.conn.prepareStatement(sql);
            for (int i = 0; i < param.length; i++)
                pstmt.setObject(i + 1, param[i]);
            rs = pstmt.executeQuery();
        }catch (Exception e){
            System.out.println("查询失败!");
            e.printStackTrace();
        }
        return rs;
    }
    public int doUpdate(String sql, Object[] param){
        this.getConnection();
        try {
            pstmt = this.conn.prepareStatement(sql);
            for (int i = 0; i < param.length; i++)
                pstmt.setObject(i + 1, param[i]);
            res = pstmt.executeUpdate();
        }catch (Exception e){
            System.out.println("修改失败!");
            e.printStackTrace();
        }
        return res;
    }
    public void close(){
        try {
            if (rs != null)
                rs.close();
            if (pstmt != null)
                pstmt.close();
            if(conn!=null)
                conn.close();
        }catch (Exception e){
            System.out.println("关闭失败!");
            e.printStackTrace();
        }
    }
    
}
