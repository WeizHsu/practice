-- DDL for create db and insert data
use DE_DEMO;

create schema if not exists fifty_ques;

create table fifty_ques.student(
  SId varchar(2),
  Sname varchar(20),
  Sage datetime,
  Ssex varchar(1))
  
create table fifty_ques.course(
  CId varchar(2),
  Cname varchar(20),
  TId varchar(2));
  
create table fifty_ques.teacher(
  TId varchar(2),
  Tname varchar(20));
  
drop table score;
create table fifty_ques.sc(
  SId varchar(2),
  CId varchar(2),
  score varchar(3));
  
insert into Student values('01' , '赵雷' , '1990-01-01' , '男');
insert into Student values('02' , '钱电' , '1990-12-21' , '男');
insert into Student values('03' , '孙风' , '1990-12-20' , '男');
insert into Student values('04' , '李云' , '1990-12-06' , '男');
insert into Student values('05' , '周梅' , '1991-12-01' , '女');
insert into Student values('06' , '吴兰' , '1992-01-01' , '女');
insert into Student values('07' , '郑竹' , '1989-01-01' , '女');
insert into Student values('09' , '张三' , '2017-12-20' , '女');
insert into Student values('10' , '李四' , '2017-12-25' , '女');
insert into Student values('11' , '李四' , '2012-06-06' , '女');
insert into Student values('12' , '赵六' , '2013-06-13' , '女');
insert into Student values('13' , '孙七' , '2014-06-01' , '女');

insert into Course values('01' , '语文' , '02');
insert into Course values('02' , '数学' , '01');
insert into Course values('03' , '英语' , '03');

insert into Teacher values('01' , '张三');
insert into Teacher values('02' , '李四');
insert into Teacher values('03' , '王五');

insert into SC values('01' , '01' , 80);
insert into SC values('01' , '02' , 90);
insert into SC values('01' , '03' , 99);
insert into SC values('02' , '01' , 70);
insert into SC values('02' , '02' , 60);
insert into SC values('02' , '03' , 80);
insert into SC values('03' , '01' , 80);
insert into SC values('03' , '02' , 80);
insert into SC values('03' , '03' , 80);
insert into SC values('04' , '01' , 50);
insert into SC values('04' , '02' , 30);
insert into SC values('04' , '03' , 20);
insert into SC values('05' , '01' , 76);
insert into SC values('05' , '02' , 87);
insert into SC values('06' , '01' , 31);
insert into SC values('06' , '03' , 34);
insert into SC values('07' , '02' , 89);
insert into SC values('07' , '03' , 98);

//1 查询" 01 "课程比" 02 "课程成绩高的学生的信息及课程分数
select c1.sid,sname,sage,ssex,c1.score as c1_score,  c2.score as c2_score
from (select sid,score from sc where cid = '01') c1
join (select sid,score from sc where cid = '02') c2 using(sid)
join student using(sid)
where c1.score > c2.score
    //1.1 查询同时存在" 01 "课程和" 02 "课程的情况
select *
from 
    (select * from sc where CId = '01') t1
join
    (select * from sc where CId = '02') t2
on t1.SId = t2.SId
    //1.2 查询存在" 01 "课程但可能不存在" 02 "课程的情况(不存在时显示为 null )
select *
from 
    (select * from sc where CId = '01') t1
left join
    (select * from sc where CId = '02') t2
on t1.SId = t2.SId
    //1.3 查询不存在" 01 "课程但存在" 02 "课程的情况
select *
from 
    (select * from sc where CId = '01') t1
right join
    (select * from sc where CId = '02') t2
on t1.SId = t2.SId
//2 查询平均成绩大于等于 60 分的同学的学生编号和学生姓名和平均成绩
select sc.sid,sname,avg(score) as average_score
from sc
join student s using(sid)
group by 1,2
having average_score >= 60
//3 查询在 SC 表存在成绩的学生信息
select distinct sc.sid,sname,sage,ssex
from sc
join student s using(sid)
//4 查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩(没成绩的显示为 null )
select s.sid,sname,count(cid) as total_enrol,sum(score) as total_score
from student s
left join sc using(sid)
group by 1,2
//4.1 查有成绩的学生信息
select sc.sid,s.sname, s.sage, s.ssex
from student s
join sc using(sid)
group by 1,2,3,4
//5 查询「李」姓老师的数量
select count(*)
from teacher
where tname like '李%'
//6 查询学过「张三」老师授课的同学的信息
select sc.sid,sname,sage,ssex
from sc
join student s using(sid)
join (  select cid
        from course
        join teacher using(tid)
        where tname = '张三') zsc using(cid)
//7 查询没有学全所有课程的同学的信息
select s.sid, sname, sage, ssex
from student s
left join ( select sid
            from sc
            group by 1
            having count(cid) = (select count(*) from course)) n using(sid)
where n.sid is null
//8 查询至少有一门课与学号为" 01 "的同学所学相同的同学的信息
select distinct sc.sid,sname,sage,ssex
from sc join student using(sid)
where cid in (select distinct cid from sc where sid = '01') 
    and 
      sid != '01'
//9 查询和" 01 "号的同学学习的课程 完全相同的其他同学的信息
select distinct sc.sid,sname,sage,ssex
from sc
join student using(sid)
where sc.sid not in (   select distinct tem.sid
                        from (  select distinct sid, c.cid
                                from sc
                                cross join (select distinct cid from sc where sid = '01') c order by sid) tem
                        left join sc on sc.sid=tem.sid and sc.cid = tem.cid 
                        where score is null)
and sc.sid != '01'

//10 查询没学过"张三"老师讲授的任一门课程的学生姓名
select distinct sname
from student
left join sc using(sid)
where cid not in (select cid from course join teacher using(tid) where tname = '张三')