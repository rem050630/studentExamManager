package com.example.lwmexam.entity.lwmexam;

public class lwmKnowledgePoint {
    private int lwmkpid;
    private int lwmsubjectid;
    private String lwmkpname;
    private String lwmkpdesc;
    private String lwmsubjectname;  // for JOIN display

    public int getLwmkpid() { return lwmkpid; }
    public void setLwmkpid(int lwmkpid) { this.lwmkpid = lwmkpid; }
    public int getLwmsubjectid() { return lwmsubjectid; }
    public void setLwmsubjectid(int lwmsubjectid) { this.lwmsubjectid = lwmsubjectid; }
    public String getLwmkpname() { return lwmkpname; }
    public void setLwmkpname(String lwmkpname) { this.lwmkpname = lwmkpname; }
    public String getLwmkpdesc() { return lwmkpdesc; }
    public void setLwmkpdesc(String lwmkpdesc) { this.lwmkpdesc = lwmkpdesc; }
    public String getLwmsubjectname() { return lwmsubjectname; }
    public void setLwmsubjectname(String lwmsubjectname) { this.lwmsubjectname = lwmsubjectname; }
}
