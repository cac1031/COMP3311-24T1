-- Q2a
/*
Teacher(staff#, semester, teaches)
Subject(subjcode)

Teacher(staff#)
Subject(subjcode)
Teaches(semester, teacher, subject)

Teacher(staff#)
Subject(subjcode, semester, teaches)
*/

-- Q3
/*
== ER == 
P(id#, a)
R(id#, b)
S(id#, c)
T(id#, d)

== OO ==
P(id#, a)
R(id#, b, a)
S(id#, c, a)
T(id#, d, a)

== Single Table Method ==
P(id#, a, b, c, d)
*/

-- Q4
/*
== ER == 
P(id#, a)
R(id#, b)
S(id#, c)
T(id#, d)

== OO ==
P(id#, a)
R(id#, b, a)
S(id#, c, a)
T(id#, d, a)

== Single Table Method ==
P(id#, a, b, c, d, subclass)
*/

-- Q5a
create table R(
  id integer primary key,
  name text,
  address text,
  d_o_b date
);

create table S(
  name text,
  address text,
  primary key(name, address),
  d_o_b date
);

-- Q12
create table Subjects(
  subjectId serial primary key,
  ...
);

create table Lecturers(
  lecturerId serial primary key,
  ...
);

create table Teaches(
  subject_id integer references Subjects(subjectId),
  lecturer_id integer references Lecturers(lecturerId),
  primary key(subject_id, lecturer_id)
);

create table Faculties(
  facultyId integer primary key,
  isDean boolean,
  ...
);

create table Schools(
  schoolId serial primary key,
  foreign key member integer references Faculties(facultyId),
  ...
);
