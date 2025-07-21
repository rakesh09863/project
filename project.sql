/*creating tables of students*/
CREATE TABLE STUDENTS(student_id VARCHAR2(10) PRIMARY KEY,name varchar2(20),department varchar2(3),admission_year number);

insert into students values ('219E1A0501','Rakesh','cse',2021);
insert into students values('219E1A0502','Shilpa','cse',2021);
insert into students values('219E1A0503','Raja','cse',2021);
insert into students values('219E1A0504','guru','cse',2021);
insert into students values('219E1A0505','ravi','cse',2021);
insert into students values ('219E1A0506','summi','cse',2021);

insert into students values ('219E1A0401','ek','eee',2021);
insert into students values('219E1A0402','vignesh','eee',2021);
insert into students values('219E1A0403','gayi','eee',2021);
insert into students values('219E1A0404','subbu','eee',2021);
insert into students values('219E1A0405','yashwash','eee',2021);
insert into students values ('219E1A0406','babitha','eee',2021);

select * from students;
-----------------------------------------------------------------------

create table Courses(course_id VARCHAR2(10) PRIMARY KEY,course_name VARCHAR2(10) UNIQUE,credits number);

insert into courses values ('py101','python',4);
insert into courses values ('jv101','java',4);
insert into courses values ('c101','c',3);
insert into courses values ('h101','html',2);
insert into courses values ('cs101','css',3);
insert into courses values ('sq101','sql',2);

select * from courses;
-------------------------------------------------------------------------
create table semesters(semester_id VARCHAR2(10) primary key,semester_name varchar2(50),year number);

insert into semesters values('I','semester 1',2021);
insert into semesters values('II','semester 2',2021);

select * from semesters;

-------------------------------------------------------------------------
CREATE TABLE GradePoints(grade CHAR(2) PRIMARY KEY,points  NUMBER);
    
INSERT INTO GradePoints VALUES ('A', 10);
INSERT INTO GradePoints VALUES ('B', 8);
INSERT INTO GradePoints VALUES ('C', 6);
INSERT INTO GradePoints VALUES ('D', 4);
INSERT INTO GradePoints VALUES ('E', 2);
INSERT INTO GradePoints VALUES ('F', 0);

select * from gradepoints;
--------------------------------------------------------------------------
create table Grades(
grade_id number primary key,
student_id VARCHAR2(10) REFERENCES Students(student_id),
course_id VARCHAR2(10) REFERENCES Courses(course_id),
semester_id VARCHAR2(10) REFERENCES Semesters(semester_id),
marks number check(marks between 1 and 100),
grade char(2) REFERENCES Gradepoints(grade));


select * from grades;
-----------------------------------------------
/* createing tigger to two tables grades and gradepoints*/

CREATE OR REPLACE TRIGGER UPDATE_gradepoints
BEFORE INSERT OR UPDATE ON grades
FOR EACH ROW
BEGIN
IF :NEW.marks >=85 THEN
   :NEW.grade := 'A';
   ELSIF :NEW.marks >=75 THEN
   :NEW.grade := 'B';
   ELSIF :NEW.marks >=65 THEN
   :NEW.grade := 'C';
   ELSIF :NEW.marks >=55 THEN
   :NEW.grade := 'D';
   ELSIF :NEW.marks >=45 then
   :NEW.grade := 'E';
   ELSE 
   :NEW.grade := 'F';
   END IF;
   END;
   /
     /*insert the values into table grades*/
   ------------------------------------
INSERT INTO Grades(grade_id,student_id,course_id,semester_id,marks) VALUES (1, '219E1A0501', 'py101', 'I', 90);
INSERT INTO Grades(grade_id,student_id,course_id,semester_id,marks) VALUES (2, '219E1A0502', 'jv101', 'I', 84);
INSERT INTO Grades(grade_id,student_id,course_id,semester_id,marks) VALUES (3, '219E1A0503', 'c101', 'I', 70);
INSERT INTO Grades(grade_id,student_id,course_id,semester_id,marks) VALUES (4, '219E1A0504', 'h101', 'I', 60);
INSERT INTO Grades(grade_id,student_id,course_id,semester_id,marks) VALUES (5, '219E1A0505', 'cs101', 'I', 50);
INSERT INTO Grades(grade_id,student_id,course_id,semester_id,marks) VALUES (6, '219E1A0506', 'sq101', 'I', 40);

INSERT INTO Grades(grade_id,student_id,course_id,semester_id,marks) VALUES (7, '219E1A0401', 'py101', 'II', 90);
INSERT INTO Grades(grade_id,student_id,course_id,semester_id,marks) VALUES (8, '219E1A0402', 'jv101', 'II', 84);
INSERT INTO Grades(grade_id,student_id,course_id,semester_id,marks) VALUES (9, '219E1A0403', 'c101', 'II', 70);
INSERT INTO Grades(grade_id,student_id,course_id,semester_id,marks) VALUES (10, '219E1A0404', 'h101', 'II', 60);
INSERT INTO Grades(grade_id,student_id,course_id,semester_id,marks) VALUES (11, '219E1A0405', 'cs101', 'II', 50);
INSERT INTO Grades(grade_id,student_id,course_id,semester_id,marks) VALUES (12, '219E1A0406', 'sq101', 'II', 40);
--------------------------------------------------------------------------
/* creating view of studentsgpa*/

create view students_gpa as
select g.student_id,s.name,se.semester_name,round(sum(c.credits*gp.points)/sum(c.credits),2) as gpa,g.grade from students s,grades g,semesters se,courses c,gradepoints gp
where g.student_id=s.student_id and c.course_id=g.course_id and se.semester_id=g.semester_id and g.grade=gp.grade group by g.student_id,s.name,se.semester_name,g.grade;
----------------------------------------------------------------------------------------------------------------------------------------------------------------
select * from students_gpa;
desc gradepoints;
desc grades;
----------------------------------------------------------------------------------
/* finding rank based on gpa*/

select g.student_id,
s.name,
se.semester_name,
round(sum(c.credits*gp.points)/sum(c.credits),2) as gpa,
rank() over (PARTITION by se.semester_name order by round(sum(c.credits*gp.points)/sum(c.credits),2) desc) as rank from students s,
grades g,
semesters se,
gradepoints gp,courses c
where g.student_id=s.student_id
and g.course_id=c.course_id 
and g.semester_id=se.semester_id 
and g.grade=gp.grade 
group by g.student_id,s.name,se.semester_name;
----------------------------------------------------------
/* finding pass or fail based in gpa*/

select g.student_id,
s.name,
g.marks,
round(sum(c.credits * gp.points)/sum(c.credits)) as gpa,
case 
when round(sum(c.credits * gp.points)/sum(c.credits))>=6 then 'pass'
else
'fail'
end as pass_fail
from students s,courses c,gradepoints gp,grades g 
where s.student_id=g.student_id and c.course_id=g.course_id and gp.grade=g.grade group by g.student_id,s.name,g.marks;
---------------------------------


