/*
SQLyog Community v13.2.0 (64 bit)
MySQL - 8.0.43 : Database - lwmexam
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`lwmexam` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `lwmexam`;

/*Table structure for table `lwmadmin` */

DROP TABLE IF EXISTS `lwmadmin`;

CREATE TABLE `lwmadmin` (
  `lwmadminid` int NOT NULL AUTO_INCREMENT COMMENT '管理员ID（主键）',
  `lwmadminaccount` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '管理员账号',
  `lwmadminpassword` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '管理员密码（建议加密存储）',
  `lwmadminname` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '管理员姓名',
  PRIMARY KEY (`lwmadminid`),
  UNIQUE KEY `lwmadminaccount` (`lwmadminaccount`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='管理员信息表';

/*Data for the table `lwmadmin` */

insert  into `lwmadmin`(`lwmadminid`,`lwmadminaccount`,`lwmadminpassword`,`lwmadminname`) values 
(1,'123','321','张'),
(2,'111','222','李');

/*Table structure for table `lwmexampaper` */

DROP TABLE IF EXISTS `lwmexampaper`;

CREATE TABLE `lwmexampaper` (
  `lwmpaperid` int NOT NULL AUTO_INCREMENT COMMENT '试卷ID（主键）',
  `lwmpapername` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '试卷名称（如2023级高数期末试卷）',
  `lwmsubjectid` int NOT NULL COMMENT '所属科目（关联科目表）',
  `lwmexamtime` int NOT NULL COMMENT '考试时长（分钟）',
  `lwmstarttime` datetime NOT NULL COMMENT '考试开始时间',
  `lwmendtime` datetime NOT NULL COMMENT '考试结束时间',
  `lwmteacherid` int NOT NULL COMMENT '出卷老师',
  `lwmdanxnum` int DEFAULT '0' COMMENT '单选题数量',
  `lwmdanxscore` int DEFAULT '0' COMMENT '单选题分值',
  `lwmdanxnos` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '单选题题号',
  `lwmduoxnum` int DEFAULT '0' COMMENT '多选题数量',
  `lwmduoxscore` int NOT NULL DEFAULT '0' COMMENT '多选题分值',
  `lwmduoxnos` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '多选题题号',
  `lwmpdnum` int DEFAULT '0' COMMENT '判断题数量',
  `lwmpdscore` int DEFAULT '0' COMMENT '判断题分值',
  `lwmpdnos` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '判断题题号',
  `lwmjdnum` int DEFAULT '0' COMMENT '简答题数量',
  `lwmjdscore` int DEFAULT '0' COMMENT '简答题分值',
  `lwmjdnos` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '简答题题号',
  `lwmclassname` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '班级',
  `lwmexamsore` int NOT NULL COMMENT '总分',
  PRIMARY KEY (`lwmpaperid`),
  KEY `lwmsubjectid` (`lwmsubjectid`),
  CONSTRAINT `lwmexampaper_ibfk_1` FOREIGN KEY (`lwmsubjectid`) REFERENCES `lwmexamsubject` (`lwmsubjectid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='试卷信息表';

/*Data for the table `lwmexampaper` */

insert  into `lwmexampaper`(`lwmpaperid`,`lwmpapername`,`lwmsubjectid`,`lwmexamtime`,`lwmstarttime`,`lwmendtime`,`lwmteacherid`,`lwmdanxnum`,`lwmdanxscore`,`lwmdanxnos`,`lwmduoxnum`,`lwmduoxscore`,`lwmduoxnos`,`lwmpdnum`,`lwmpdscore`,`lwmpdnos`,`lwmjdnum`,`lwmjdscore`,`lwmjdnos`,`lwmclassname`,`lwmexamsore`) values 
(36,'2025',4,1,'2026-05-21 09:11:00','2026-05-31 09:11:00',1,1,2,'1',1,2,'2',1,1,'3',1,5,'4','计算机科学与技术1班',10),
(37,'2023',4,120,'2026-05-17 09:31:00','2026-05-29 09:31:00',1,1,2,'1',1,2,'2',1,1,'3',1,5,'4','计算机科学与技术1班',10),
(38,'2025',1,120,'2026-05-25 09:59:00','2026-05-25 10:54:00',1,5,2,'1,2,3,5,8',1,2,'4',1,1,'7',1,5,'6','大数据1班,计算机科学与技术1班,计算机科学与技术2班',18),
(39,'2026',4,120,'2026-05-14 10:55:00','2026-05-29 10:55:00',1,1,2,'1',0,2,'',0,1,'',1,5,'2','计算机科学与技术1班',7),
(40,'77',4,120,'2026-05-10 11:15:00','2026-05-30 11:15:00',1,1,2,'1',1,2,'2',1,1,'3',1,5,'4','计算机科学与技术1班',10),
(41,'321',4,120,'2026-05-20 11:26:00','2026-05-28 11:26:00',1,2,2,'1,2',1,2,'3',1,1,'4',1,5,'5','计算机科学与技术1班',12),
(42,'547',4,120,'2026-05-30 00:28:00','2026-06-17 00:28:00',1,1,3,'1',1,2,'2',1,1,'3',1,5,'4','大数据1班,计算机科学与技术1班',11),
(43,'4352',4,120,'2026-06-01 09:49:00','2026-06-24 09:49:00',1,1,2,'1',1,2,'2',0,1,'',0,5,'','计算机科学与技术1班',4),
(45,'2421',1,120,'2026-06-01 10:07:00','2026-06-20 10:08:00',1,1,5,'1',1,3,'2',1,2,'3',1,4,'4','计算机科学与技术1班',14),
(46,'4322',1,120,'2026-06-01 10:12:00','2026-06-20 10:12:00',1,2,4,'2,3',1,1,'1',0,1,'',0,5,'','计算机科学与技术1班',9),
(47,'432211',4,120,'2026-06-06 09:02:00','2026-06-25 09:02:00',1,1,2,'1',1,2,'2',0,1,'',0,5,'','',4);

/*Table structure for table `lwmexamquestion` */

DROP TABLE IF EXISTS `lwmexamquestion`;

CREATE TABLE `lwmexamquestion` (
  `lwmquestionid` int NOT NULL AUTO_INCREMENT COMMENT '试题ID（主键）',
  `lwmsubjectid` int NOT NULL COMMENT '所属科目（关联科目表）',
  `lwmquestiontype` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '题型（单选题/多选题/判断题/简答题）',
  `lwmquestioncontent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '试题内容',
  `lwmoptiona` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '选项A（非选择题可为空）',
  `lwmoptionb` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '选项B',
  `lwmoptionc` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '选项C',
  `lwmoptiond` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '选项D',
  `lwmcorrectanswer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '正确答案',
  PRIMARY KEY (`lwmquestionid`),
  KEY `lwmsubjectid` (`lwmsubjectid`),
  CONSTRAINT `lwmexamquestion_ibfk_1` FOREIGN KEY (`lwmsubjectid`) REFERENCES `lwmexamsubject` (`lwmsubjectid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='试题信息表';

/*Data for the table `lwmexamquestion` */

insert  into `lwmexamquestion`(`lwmquestionid`,`lwmsubjectid`,`lwmquestiontype`,`lwmquestioncontent`,`lwmoptiona`,`lwmoptionb`,`lwmoptionc`,`lwmoptiond`,`lwmcorrectanswer`) values 
(1,1,'单选题','123','1','13','122','2','A'),
(3,1,'判断题','11111','','','','','对'),
(5,1,'简答题','3333','','','','','无所谓'),
(7,5,'单选题','11','1','13','122','2','A'),
(15,1,'单选题','232','啊','吧','从','的','A'),
(16,1,'多选题','2005','啊','吧','从','的','A,C'),
(24,1,'单选题','11','11111','232','123','123','C'),
(25,1,'单选题','2312','1','11','23','2','A'),
(26,1,'单选题','2313','1','2','3','4','A'),
(27,4,'单选题','1+1=','1','2','3','4','B'),
(28,4,'单选题','2+1=','1','2','3','4','C'),
(29,4,'多选题','a+b=2，a=?,b=?','a=1,b=1','a=0.5,b=1.5','a=1,b=2','a=2,b=1','A,B'),
(30,4,'判断题','1+1=0','','','','','错'),
(31,4,'简答题','为什么1+1=2','','','','','不知道');

/*Table structure for table `lwmexamrecord` */

DROP TABLE IF EXISTS `lwmexamrecord`;

CREATE TABLE `lwmexamrecord` (
  `lwmrecordid` int NOT NULL AUTO_INCREMENT COMMENT '考试记录ID（主键）',
  `lwmpaperid` int NOT NULL COMMENT '试卷ID（关联试卷表）',
  `lwmstudentid` int NOT NULL COMMENT '学生ID（关联学生表）',
  `lwmstarttime` datetime NOT NULL COMMENT '开始考试时间',
  `lwmendtime` datetime DEFAULT NULL COMMENT '结束考试时间',
  `lwmsubmitstatus` tinyint DEFAULT '0' COMMENT '提交状态（0-未提交 1-已提交）',
  PRIMARY KEY (`lwmrecordid`),
  KEY `lwmpaperid` (`lwmpaperid`),
  KEY `lwmstudentid` (`lwmstudentid`),
  CONSTRAINT `lwmexamrecord_ibfk_1` FOREIGN KEY (`lwmpaperid`) REFERENCES `lwmexampaper` (`lwmpaperid`) ON DELETE CASCADE,
  CONSTRAINT `lwmexamrecord_ibfk_2` FOREIGN KEY (`lwmstudentid`) REFERENCES `lwmstudent` (`lwmstudentid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生考试记录表';

/*Data for the table `lwmexamrecord` */

insert  into `lwmexamrecord`(`lwmrecordid`,`lwmpaperid`,`lwmstudentid`,`lwmstarttime`,`lwmendtime`,`lwmsubmitstatus`) values 
(28,36,20,'2026-05-25 01:11:55','2026-05-25 09:12:57',1),
(31,39,20,'2026-05-25 02:56:09','2026-05-25 10:56:19',2),
(33,40,20,'2026-05-25 03:23:20','2026-05-25 11:23:33',2),
(42,43,20,'2026-06-01 01:54:35','2026-06-01 01:54:35',0),
(43,45,20,'2026-06-01 02:08:36','2026-06-01 10:08:42',2),
(44,46,20,'2026-06-08 00:45:01','2026-06-08 09:13:26',1),
(45,42,20,'2026-06-08 01:29:11','2026-06-08 01:29:11',0);

/*Table structure for table `lwmexamscore` */

DROP TABLE IF EXISTS `lwmexamscore`;

CREATE TABLE `lwmexamscore` (
  `lwmscoreid` int NOT NULL AUTO_INCREMENT COMMENT '成绩ID（主键）',
  `lwmrecordid` int NOT NULL COMMENT '关联考试记录（一对一）',
  `lwmtotalscore` int DEFAULT '0' COMMENT '总成绩',
  `lwmteacherid` int DEFAULT NULL COMMENT '阅卷教师（关联教师表）',
  `lwmscoretime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '评分时间',
  `lwmstudentid` int NOT NULL COMMENT '学生学号',
  `lwmpaperid` int NOT NULL COMMENT '试卷编号',
  PRIMARY KEY (`lwmscoreid`),
  UNIQUE KEY `lwmrecordid` (`lwmrecordid`),
  KEY `lwmteacherid` (`lwmteacherid`),
  CONSTRAINT `lwmexamscore_ibfk_1` FOREIGN KEY (`lwmrecordid`) REFERENCES `lwmexamrecord` (`lwmrecordid`) ON DELETE CASCADE,
  CONSTRAINT `lwmexamscore_ibfk_2` FOREIGN KEY (`lwmteacherid`) REFERENCES `lwmteacher` (`lwmteacherid`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=55 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生成绩表';

/*Data for the table `lwmexamscore` */

insert  into `lwmexamscore`(`lwmscoreid`,`lwmrecordid`,`lwmtotalscore`,`lwmteacherid`,`lwmscoretime`,`lwmstudentid`,`lwmpaperid`) values 
(28,31,7,1,'2026-05-25 11:07:58',20,39),
(46,33,9,1,'2026-05-25 11:23:48',20,40),
(52,43,13,1,'2026-06-01 10:09:05',20,45),
(54,44,4,1,'2026-06-08 09:13:55',20,46);

/*Table structure for table `lwmexamsubject` */

DROP TABLE IF EXISTS `lwmexamsubject`;

CREATE TABLE `lwmexamsubject` (
  `lwmsubjectid` int NOT NULL AUTO_INCREMENT COMMENT '科目ID（主键）',
  `lwmsubjectname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '科目名称（如高等数学、Python编程）',
  `lwmsubjectdesc` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '科目代码',
  `lwmsubjectscore` int NOT NULL COMMENT '科目学分',
  `lwmterm` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '开设学期',
  PRIMARY KEY (`lwmsubjectid`),
  UNIQUE KEY `lwmsubjectname` (`lwmsubjectname`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='考试科目表';

/*Data for the table `lwmexamsubject` */

insert  into `lwmexamsubject`(`lwmsubjectid`,`lwmsubjectname`,`lwmsubjectdesc`,`lwmsubjectscore`,`lwmterm`) values 
(1,'大学英语','G001',5,'2023-2024第一学期'),
(4,'高等数学','G002',4,'2021-2022第一学期'),
(5,'单片机','G003',4,'2023-2024第二学期'),
(6,'数据库原理','G004',4,'2022-2023第一学期');

/*Table structure for table `lwmknowledgepoint` */

DROP TABLE IF EXISTS `lwmknowledgepoint`;

CREATE TABLE `lwmknowledgepoint` (
  `lwmkpid` int NOT NULL AUTO_INCREMENT COMMENT '知识点ID',
  `lwmsubjectid` int NOT NULL COMMENT '所属科目ID',
  `lwmkpname` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '知识点名称（如"定积分"）',
  `lwmkpdesc` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '知识点描述',
  PRIMARY KEY (`lwmkpid`),
  KEY `idx_subject` (`lwmsubjectid`),
  CONSTRAINT `fk_kp_subject` FOREIGN KEY (`lwmsubjectid`) REFERENCES `lwmexamsubject` (`lwmsubjectid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='知识点表';

/*Data for the table `lwmknowledgepoint` */

/*Table structure for table `lwmmistakebook` */

DROP TABLE IF EXISTS `lwmmistakebook`;

CREATE TABLE `lwmmistakebook` (
  `lwmmid` int NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `lwmstudentid` int NOT NULL COMMENT '学生ID',
  `lwmquestionid` int NOT NULL COMMENT '试题ID',
  `lwmiswrong` tinyint DEFAULT '1' COMMENT '1=做错 0=后续做对（动态更新）',
  `lwmreviewstatus` tinyint DEFAULT '0' COMMENT '0=未复习 1=已复习 2=已掌握',
  `lwmlastupdatetime` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  PRIMARY KEY (`lwmmid`),
  UNIQUE KEY `uk_student_question` (`lwmstudentid`,`lwmquestionid`),
  KEY `idx_student` (`lwmstudentid`),
  KEY `idx_question` (`lwmquestionid`),
  KEY `idx_status` (`lwmiswrong`,`lwmreviewstatus`),
  CONSTRAINT `fk_mb_question` FOREIGN KEY (`lwmquestionid`) REFERENCES `lwmexamquestion` (`lwmquestionid`) ON DELETE CASCADE,
  CONSTRAINT `fk_mb_student` FOREIGN KEY (`lwmstudentid`) REFERENCES `lwmstudent` (`lwmstudentid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='错题本表';

/*Data for the table `lwmmistakebook` */

/*Table structure for table `lwmpaperquestion` */

DROP TABLE IF EXISTS `lwmpaperquestion`;

CREATE TABLE `lwmpaperquestion` (
  `lwmid` int NOT NULL AUTO_INCREMENT COMMENT '关联ID（主键）',
  `lwmpaperid` int NOT NULL COMMENT '试卷ID（关联试卷表）',
  `lwmquestionid` int NOT NULL COMMENT '试题ID（关联试题表）',
  PRIMARY KEY (`lwmid`),
  UNIQUE KEY `lwmuniquepaperquestion` (`lwmpaperid`,`lwmquestionid`) COMMENT '避免同一试题重复加入试卷',
  KEY `lwmquestionid` (`lwmquestionid`),
  CONSTRAINT `lwmpaperquestion_ibfk_1` FOREIGN KEY (`lwmpaperid`) REFERENCES `lwmexampaper` (`lwmpaperid`) ON DELETE CASCADE,
  CONSTRAINT `lwmpaperquestion_ibfk_2` FOREIGN KEY (`lwmquestionid`) REFERENCES `lwmexamquestion` (`lwmquestionid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=267 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='试卷试题关联表';

/*Data for the table `lwmpaperquestion` */

insert  into `lwmpaperquestion`(`lwmid`,`lwmpaperid`,`lwmquestionid`) values 
(207,36,28),
(208,36,29),
(209,36,30),
(210,36,31),
(211,37,28),
(212,37,29),
(213,37,30),
(214,37,31),
(222,38,1),
(221,38,3),
(220,38,5),
(219,38,15),
(218,38,16),
(217,38,24),
(216,38,25),
(215,38,26),
(223,39,27),
(224,39,31),
(225,40,28),
(226,40,29),
(227,40,30),
(228,40,31),
(229,41,27),
(230,41,28),
(231,41,29),
(232,41,30),
(233,41,31),
(253,42,28),
(254,42,29),
(255,42,30),
(256,42,31),
(251,43,28),
(252,43,29),
(249,45,3),
(250,45,5),
(247,45,15),
(248,45,16),
(262,46,16),
(263,46,24),
(264,46,26),
(265,47,28),
(266,47,29);

/*Table structure for table `lwmquestionknowledge` */

DROP TABLE IF EXISTS `lwmquestionknowledge`;

CREATE TABLE `lwmquestionknowledge` (
  `lwmqkid` int NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `lwmquestionid` int NOT NULL COMMENT '试题ID',
  `lwmkpid` int NOT NULL COMMENT '知识点ID',
  PRIMARY KEY (`lwmqkid`),
  UNIQUE KEY `uk_question_kp` (`lwmquestionid`,`lwmkpid`),
  KEY `idx_question` (`lwmquestionid`),
  KEY `idx_kp` (`lwmkpid`),
  CONSTRAINT `fk_qk_kp` FOREIGN KEY (`lwmkpid`) REFERENCES `lwmknowledgepoint` (`lwmkpid`) ON DELETE CASCADE,
  CONSTRAINT `fk_qk_question` FOREIGN KEY (`lwmquestionid`) REFERENCES `lwmexamquestion` (`lwmquestionid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='试题-知识点关联表';

/*Data for the table `lwmquestionknowledge` */

/*Table structure for table `lwmstudent` */

DROP TABLE IF EXISTS `lwmstudent`;

CREATE TABLE `lwmstudent` (
  `lwmstudentid` int NOT NULL AUTO_INCREMENT COMMENT '学生ID（主键）',
  `lwmstudentno` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '学号',
  `lwmstudentname` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '学生姓名',
  `lwmstudentpassword` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '学生密码（建议加密存储）',
  `lwmgender` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '未知' COMMENT '性别（男/女/未知）',
  `lwmgrade` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '年级（如2023级）',
  `lwmmajor` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '专业',
  `lwmclassname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '班级',
  PRIMARY KEY (`lwmstudentid`),
  UNIQUE KEY `lwmstudentno` (`lwmstudentno`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生信息表';

/*Data for the table `lwmstudent` */

insert  into `lwmstudent`(`lwmstudentid`,`lwmstudentno`,`lwmstudentname`,`lwmstudentpassword`,`lwmgender`,`lwmgrade`,`lwmmajor`,`lwmclassname`) values 
(19,'20230551003','李小龙','111111','男','2023级','计算机科学与技术','计算机科学与技术2班'),
(20,'20230551009','罗尉铭','111111','男','2024级','数据科学与大数据技术','计算机科学与技术1班'),
(21,'202305510034','zs','111','男','2022级','人工智能','计算机科学与技术1班'),
(22,'202305510036','qwe','222','男','2022级','数据科学与大数据技术','计算机科学与技术1班'),
(24,'202305510023','zs','111','男','2023级','信息管理与信息系统','软件工程2班'),
(25,'20240551001','小明','1001','男','2024级','数据科学与大数据技术','大数据1班'),
(26,'20200321002','李四','333','男','2021级','网络工程','网络1班'),
(27,'20230551001','zs','111','男','2023级','软件工程','计算机科学与技术1班'),
(29,'20240551009','王五','123','男','2024级','人工智能','人工智能1班'),
(30,'20240551010','九二','222','女','2024级','软件工程','软件工程1班'),
(31,'20230551004','小美','111','女','2022级','计算机科学与技术','计算机科学与技术2班');

/*Table structure for table `lwmstudentanswer` */

DROP TABLE IF EXISTS `lwmstudentanswer`;

CREATE TABLE `lwmstudentanswer` (
  `lwmanswerid` int NOT NULL AUTO_INCREMENT COMMENT '答题ID（主键）',
  `lwmrecordid` int NOT NULL COMMENT '考试记录ID（关联考试记录表）',
  `lwmquestionid` int NOT NULL COMMENT '试题ID（关联试题表）',
  `lwmstudentanswer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '学生作答内容',
  `lwmquestionscore` int DEFAULT '0' COMMENT '该题得分',
  `lwmstudentid` int NOT NULL COMMENT '学生学号',
  `lwmpaperid` int DEFAULT NULL COMMENT '试卷编号',
  PRIMARY KEY (`lwmanswerid`),
  KEY `lwmrecordid` (`lwmrecordid`),
  KEY `lwmquestionid` (`lwmquestionid`),
  CONSTRAINT `lwmstudentanswer_ibfk_1` FOREIGN KEY (`lwmrecordid`) REFERENCES `lwmexamrecord` (`lwmrecordid`) ON DELETE CASCADE,
  CONSTRAINT `lwmstudentanswer_ibfk_2` FOREIGN KEY (`lwmquestionid`) REFERENCES `lwmexamquestion` (`lwmquestionid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=186 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生答题详情表';

/*Data for the table `lwmstudentanswer` */

insert  into `lwmstudentanswer`(`lwmanswerid`,`lwmrecordid`,`lwmquestionid`,`lwmstudentanswer`,`lwmquestionscore`,`lwmstudentid`,`lwmpaperid`) values 
(114,28,28,'C',0,20,36),
(115,28,29,'A,B',0,20,36),
(116,28,30,'错',0,20,36),
(117,28,31,'11',0,20,36),
(136,31,27,'C',2,20,39),
(137,31,31,'12',5,20,39),
(142,33,28,'C',2,20,40),
(143,33,29,'A,B',2,20,40),
(144,33,30,'错',1,20,40),
(145,33,31,'123',4,20,40),
(171,43,15,'A',5,20,45),
(172,43,16,'C',2,20,45),
(173,43,3,'对',2,20,45),
(174,43,5,'123',4,20,45),
(175,44,24,'A',0,20,46),
(176,44,26,'A',4,20,46),
(177,44,16,'A',0,20,46),
(182,45,28,'A',0,20,42),
(183,45,29,'B',0,20,42),
(184,45,30,'对',0,20,42),
(185,45,31,'',0,20,42);

/*Table structure for table `lwmstudentcourseteacher` */

DROP TABLE IF EXISTS `lwmstudentcourseteacher`;

CREATE TABLE `lwmstudentcourseteacher` (
  `lwmsctid` int NOT NULL AUTO_INCREMENT COMMENT '关联ID主键',
  `lwmclassname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '学生班级',
  `lwmsubjectid` int NOT NULL COMMENT '课程ID',
  `lwmteacherid` int NOT NULL COMMENT '授课教师ID',
  `lwmsemester` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '学期',
  PRIMARY KEY (`lwmsctid`),
  UNIQUE KEY `uk_stu_sub_tea_sem` (`lwmsubjectid`,`lwmteacherid`,`lwmsemester`),
  KEY `idx_subjectid` (`lwmsubjectid`),
  KEY `idx_teacherid` (`lwmteacherid`),
  CONSTRAINT `fk_sct_subject` FOREIGN KEY (`lwmsubjectid`) REFERENCES `lwmexamsubject` (`lwmsubjectid`) ON DELETE CASCADE,
  CONSTRAINT `fk_sct_teacher` FOREIGN KEY (`lwmteacherid`) REFERENCES `lwmteacher` (`lwmteacherid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生选课-教师授课关联表';

/*Data for the table `lwmstudentcourseteacher` */

insert  into `lwmstudentcourseteacher`(`lwmsctid`,`lwmclassname`,`lwmsubjectid`,`lwmteacherid`,`lwmsemester`) values 
(1,'大数据1班',1,1,'2023-2024第一学期'),
(6,'大数据1班',1,2,'2023-2024第二学期'),
(12,'计算机科学与技术1班',1,1,'2022-2023第二学期'),
(13,'软件工程2班',6,2,'2021-2022第一学期'),
(16,'计算机科学与技术2班',1,1,'2022-2023第一学期'),
(19,'计算机科学与技术1班',5,2,'2021-2022第一学期'),
(22,'计算机科学与技术1班',4,1,'2021-2022第一学期');

/*Table structure for table `lwmteacher` */

DROP TABLE IF EXISTS `lwmteacher`;

CREATE TABLE `lwmteacher` (
  `lwmteacherid` int NOT NULL AUTO_INCREMENT COMMENT '教师ID（主键）',
  `lwmteacherno` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '教师工号',
  `lwmteachername` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '教师姓名',
  `lwmteacherpassword` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '教师密码（建议加密存储）',
  `lwmteachergender` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '未知' COMMENT '性别',
  `lwmteacherphone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '电话',
  PRIMARY KEY (`lwmteacherid`),
  UNIQUE KEY `lwmteacherno` (`lwmteacherno`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='教师信息表';

/*Data for the table `lwmteacher` */

insert  into `lwmteacher`(`lwmteacherid`,`lwmteacherno`,`lwmteachername`,`lwmteacherpassword`,`lwmteachergender`,`lwmteacherphone`) values 
(1,'211','罗尉铭','123','男','15823926107'),
(2,'123','夕熙','345','女','123456789'),
(5,'20001','吉吉','321','男','13827394838');

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
