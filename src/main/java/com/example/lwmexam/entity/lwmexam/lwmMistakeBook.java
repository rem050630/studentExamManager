package com.example.lwmexam.entity.lwmexam;

public class lwmMistakeBook {
    private int lwmmid;
    private int lwmstudentid;
    private int lwmquestionid;
    private int lwmiswrong;
    private int lwmreviewstatus;
    private String lwmlastupdatetime;
    // Joined fields for display
    private String lwmquestiontype;
    private String lwmquestioncontent;
    private String lwmoptiona;
    private String lwmoptionb;
    private String lwmoptionc;
    private String lwmoptiond;
    private String lwmcorrectanswer;
    private String lwmstudentanswer;
    private String lwmsubjectname;
    private int lwmsubjectid;
    private String lwmkpnames;  // comma-separated KP names

    public int getLwmmid() { return lwmmid; }
    public void setLwmmid(int lwmmid) { this.lwmmid = lwmmid; }
    public int getLwmstudentid() { return lwmstudentid; }
    public void setLwmstudentid(int lwmstudentid) { this.lwmstudentid = lwmstudentid; }
    public int getLwmquestionid() { return lwmquestionid; }
    public void setLwmquestionid(int lwmquestionid) { this.lwmquestionid = lwmquestionid; }
    public int getLwmiswrong() { return lwmiswrong; }
    public void setLwmiswrong(int lwmiswrong) { this.lwmiswrong = lwmiswrong; }
    public int getLwmreviewstatus() { return lwmreviewstatus; }
    public void setLwmreviewstatus(int lwmreviewstatus) { this.lwmreviewstatus = lwmreviewstatus; }
    public String getLwmlastupdatetime() { return lwmlastupdatetime; }
    public void setLwmlastupdatetime(String lwmlastupdatetime) { this.lwmlastupdatetime = lwmlastupdatetime; }
    public String getLwmquestiontype() { return lwmquestiontype; }
    public void setLwmquestiontype(String lwmquestiontype) { this.lwmquestiontype = lwmquestiontype; }
    public String getLwmquestioncontent() { return lwmquestioncontent; }
    public void setLwmquestioncontent(String lwmquestioncontent) { this.lwmquestioncontent = lwmquestioncontent; }
    public String getLwmoptiona() { return lwmoptiona; }
    public void setLwmoptiona(String lwmoptiona) { this.lwmoptiona = lwmoptiona; }
    public String getLwmoptionb() { return lwmoptionb; }
    public void setLwmoptionb(String lwmoptionb) { this.lwmoptionb = lwmoptionb; }
    public String getLwmoptionc() { return lwmoptionc; }
    public void setLwmoptionc(String lwmoptionc) { this.lwmoptionc = lwmoptionc; }
    public String getLwmoptiond() { return lwmoptiond; }
    public void setLwmoptiond(String lwmoptiond) { this.lwmoptiond = lwmoptiond; }
    public String getLwmcorrectanswer() { return lwmcorrectanswer; }
    public void setLwmcorrectanswer(String lwmcorrectanswer) { this.lwmcorrectanswer = lwmcorrectanswer; }
    public String getLwmstudentanswer() { return lwmstudentanswer; }
    public void setLwmstudentanswer(String lwmstudentanswer) { this.lwmstudentanswer = lwmstudentanswer; }
    public String getLwmsubjectname() { return lwmsubjectname; }
    public void setLwmsubjectname(String lwmsubjectname) { this.lwmsubjectname = lwmsubjectname; }
    public int getLwmsubjectid() { return lwmsubjectid; }
    public void setLwmsubjectid(int lwmsubjectid) { this.lwmsubjectid = lwmsubjectid; }
    public String getLwmkpnames() { return lwmkpnames; }
    public void setLwmkpnames(String lwmkpnames) { this.lwmkpnames = lwmkpnames; }
}
