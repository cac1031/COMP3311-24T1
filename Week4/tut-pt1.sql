/***********
* Q1 - Q11 *
***********/

-- Q2
update Employees
set salary = salary * 0.8
where age < 25;

-- Q3
update Employees
set salary = salary * 1.1
where eid in (
  select e.eid
  from Employees e
    join WorksIn w on (e.eid = w.eid)
    join Departments d on (w.did = d.did)
  where d.dname = 'Sales'
  );

-- Q4
create table Departments (
  did     integer,
  dname   text,
  budget  real,
  manager integer references Employees(eid) not null,
  primary key (did)
);

-- Q5
create table Employees (
  eid     integer,
  ename   text,
  age     integer,
  salary  real check (salary > 15000),
  primary key (eid)
);

-- Q6
create table WorksIn (
  eid     integer references Employees(eid),
  did     integer references Departments(did),
  percent real,
  primary key (eid,did),
  constraint FullTimeCheck check (
   1.00 >= (
    select sum(w.percent)
    from WorksIn w
    where (w.eid = eid)
   )
  );
);

-- Q7
create table Departments (
  did     integer,
  dname   text,
  budget  real,
  manager integer references Employees(eid),
  primary key (did)
  constraint ManagerCheck check (
    1.00 = (
      select w.percent
      from WorksIn w
      where w.eid = manager 
    )
  )
);
