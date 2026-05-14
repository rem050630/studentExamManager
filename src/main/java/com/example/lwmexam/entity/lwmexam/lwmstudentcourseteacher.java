package com.example.lwmexam.entity.lwmexam;

public class lwmstudentcourseteacher {
    private Integer lwmsctid;
    // 学生班级
    private String lwmclassname;
    // 课程ID
    private Integer lwmsubjectid;
    // 授课教师ID
    private Integer lwmteacherid;
    // 学期
    private String lwmsemester;
    private String lwmsubjectname;
    private String lwmteachername;

    public String getLwmsubjectname() {
        return lwmsubjectname;
    }

    public void setLwmsubjectname(String lwmsubjectname) {
        this.lwmsubjectname = lwmsubjectname;
    }

    public String getLwmteachername() {
        return lwmteachername;
    }

    public void setLwmteachername(String lwmteachername) {
        this.lwmteachername = lwmteachername;
    }

    public Integer getLwmsctid() {
        return lwmsctid;
    }

    public void setLwmsctid(Integer lwmsctid) {
        this.lwmsctid = lwmsctid;
    }

    public String getLwmclassname() {
        return lwmclassname;
    }

    public void setLwmclassname(String lwmclassname) {
        this.lwmclassname = lwmclassname;
    }

    public Integer getLwmsubjectid() {
        return lwmsubjectid;
    }

    public void setLwmsubjectid(Integer lwmsubjectid) {
        this.lwmsubjectid = lwmsubjectid;
    }

    public Integer getLwmteacherid() {
        return lwmteacherid;
    }

    public void setLwmteacherid(Integer lwmteacherid) {
        this.lwmteacherid = lwmteacherid;
    }

    public String getLwmsemester() {
        return lwmsemester;
    }

    public void setLwmsemester(String lwmsemester) {
        this.lwmsemester = lwmsemester;
    }
}
