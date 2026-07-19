package com.example.lwmexam.service.lwmexam;


import com.example.lwmexam.dao.lwmexam.lwmstudentDAO;

import java.sql.ResultSet;

public class Fpage {
    private int pageSize = 6;//页面大小
    private int pageNow = 0;//当前页
    private int start = 0;//起始条数
    private int pageCount = 0;//共多少页
    private int rowCount = 0;//共多少条记录

    public int getPageSize() {
        return pageSize;
    }

    public void setPageSize(int pageSize) {
        this.pageSize = pageSize;
    }

    public int getPageNow() {
        return pageNow;
    }

    public void setPageNow(int pageNow) {
        this.pageNow = pageNow;
    }

    public int getStart() {
        return start;
    }

    public void setStart(int start) {
        this.start = start;
    }

    public int getPageCount() {
        return pageCount;
    }

    public void setPageCount(int pageCount) {
        this.pageCount = pageCount;
    }

    public int getRowCount() {
        return rowCount;
    }

    public void setRowCount(int rowCount) {
        this.rowCount = rowCount;
        if (rowCount % pageSize == 0)
            pageCount = rowCount / pageSize;
        else
            pageCount = rowCount / pageSize + 1;
        start = pageNow * pageSize;
    }

    public void setFpage(String sql, Object[] param) {
       start=pageNow*pageSize;
       lwmstudentDAO hdao = new lwmstudentDAO();
       ResultSet rs = null;
       MysqlConn db = new MysqlConn();
        try {
            rs=db.doQuery(sql, param);
            if(rs.next())
                rowCount = rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
            if (rowCount % pageSize == 0)
                pageCount = rowCount / pageSize;
            else
                pageCount = rowCount / pageSize + 1;
        db.close();

    }


}

