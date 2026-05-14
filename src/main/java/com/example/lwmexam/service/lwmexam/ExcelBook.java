package com.example.lwmexam.service.lwmexam;

import jxl.Sheet;
import jxl.Workbook;
import jxl.read.biff.BiffException;
import jxl.write.Label;
import jxl.write.WritableSheet;
import jxl.write.WritableWorkbook;

import java.io.File;
import java.io.IOException;
import java.sql.ResultSet;
import java.util.ArrayList;

public class ExcelBook {

    //将数据导出到Excel
    public void excelOut(String path, ResultSet rs, Object[] params) {
        WritableWorkbook bWorkbook = null;
        try {
            // 创建Excel对象
            bWorkbook = Workbook.createWorkbook(new File(path));
            //  通过Excel对象创建一个选项卡对象
            WritableSheet sheet = bWorkbook.createSheet("sheet1", 0);
            ////使用循环将数据读出
            int j=0;
            for (int i = 0; i < params.length; i++) {
                Label label=new Label(i,j,(String)params[i]);
                sheet.addCell(label);
            }

            j++;
            while(rs!=null && rs.next()){
                for (int i = 0; i < params.length; i++) {
                    Label label=new Label(i,j,rs.getString(i+1));
                    sheet.addCell(label);
                }
           /* Label label=new Label(0,j,String.valueOf(rs.getString(1)));
            Label label1=new Label(1,j,String.valueOf(rs.getString(2)));
            Label label2=new Label(2,j,String.valueOf(rs.getString(3)));
            sheet.addCell(label);
            sheet.addCell(label1);
            sheet.addCell(label2);*/
                j++;
            }

            // 创建一个单元格对象，第一个为列，第二个为行，第三个为值
            //Label label = new Label(0, 2, "test");
            // 将创建好的单元格放入选项卡中
            //sheet.addCell(label);
            // 写入目标路径
            bWorkbook.write();

        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } finally {
            try {
                bWorkbook.close();
            } catch (Exception e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }

    }


    ////excel导入
    public ArrayList<String[]> ExcelIn(String path){
        ArrayList<String[]>arrayList=new ArrayList<String[]>();
        Workbook bWorkbook=null;
        try {
            bWorkbook=Workbook.getWorkbook(new File(path));
            Sheet sheet=bWorkbook.getSheet(0);
            for (int i = 0; i < sheet.getRows(); i++) {
                String[] str=new String[sheet.getColumns()];
                //获取单元格对象
                //Cell cell =sheet.getCell(0,i);
                //  获取单元格的值

                for(int j=0; j<sheet.getColumns(); j++)
                {
                    str[j] = sheet.getCell(j,i).getContents();
                }
                arrayList.add(str);
            }

        } catch (BiffException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }finally {
            bWorkbook.close();
        }
        return arrayList;
    }


    public static void main(String[] args) {

        //将数据导出到Excel中
    	/*MysqlConn db = new MysqlConn();
    	ResultSet rs = null;
        ExcelBook book = new ExcelBook();
        rs = db.doQuery("select *from student", new Object[]{});

	    book.excelOut("D:/学生信息.xls",rs, new Object[]{"学号","密码", "姓名","性别","专业","管理员"});
	    System.out.println("导出成功");*/
        //将数据从Excel中导入
        ExcelBook book = new ExcelBook();
        MysqlConn db = new MysqlConn();
        ArrayList<String[]> list = book.ExcelIn("D:/学生信息.xls");

        for(int i = 0 ; i < list.size() ; i++)
        {
            for(int j = 0 ; j < list.get(i).length ; j++)
            {
                System.out.print(list.get(i)[j]+" ");
            }
            db.doUpdate("insert into stu values(?,?,?,?,?,?)", list.get(i));
            System.out.println();
        }


    }
}  
