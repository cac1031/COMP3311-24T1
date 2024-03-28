/*
COMP3311 - Wk7 Tut (Assertions, Triggers, Aggregates)

Admin:
• Quiz 4 due on Friday 29 March @ 11.59pm

Question Distribution:
• Q1-2 – Assertions
• Q3-5 – Triggers Theory
• Q6-8 – More Triggers
• Q9-12 – Triggers with Concrete Databases (9, 11)
• Q13-15 – Aggregates
*/
----------------------------------------------
-- 1,2 → 13,14 → 3,4,5 (Notes) → 6,7 → 9,11 --
----------------------------------------------

-- Q1. Consider a schema for an organisation
---------------------------------------------------------------------------
Employee(id:integer, name:text, works_in:integer, salary:integer, ...) 
Department(id:integer, name:text, manager:integer, ...)
---------------------------------------------------------------------------
-- Ensure manager must work in the Department they manage
create or replace assertion manager_works_in_department check
  not exists (
    select *
    from Employees e
      join Department d on (d.manager = e.id)
    where e.works_in != d.id
  );


create or replace assertion employee_manager_salary check
  not exists ( 
    -- Method 1
    -- query should be finding for employees who earn more than managers
    select *
    from Employees e
      join Department d on (e.works_in = d.id)
    where e.salary > (
      select salary
      from Employee
      where e.id = d.manager;
    )

    -- Method 2
    select *
    from Employees e
      join Department d on (e.works_in = d.id)
      join Employees m on (d.manager = m.id)
    where e.salary < m.salary;
  );

-- Q6.
create table R (
  a int, 
  b int, 
  c text, 
  primary key(a,b)
);

create table S (
  x int primary key, 
  y int
);

create table T (
  j int primary key, 
  k int references S(x)
);

-- a] primary key constraint on relation R
-- Primary Key: not null, unique
create or replace function R_pk_check() returns trigger
as $$
declare
...
begin
  -- not null
  if (new.a is null or new.b is null) then
    raise exception 'Primary key can''t be null';
  end if;

  if (TG_OP = 'update' and old.a = new.a and old.b = new.b) then
    return;
  end if;

  -- uniqueness
  select *
  from R
  where new.a = a and new.b = b;

  if (found) then
    raise exception 'Primary key already exists.';
  end if;

end;
$$ language plpgsql;

create or replace trigger R_pk_trigger
before insert or update
on R
for each row
execute procedure R_pk_check();


-- Q7. Difference
create trigger updateS1 after update on S
for each row execute procedure updateS();

create trigger updateS2 after update on S
for each statement execute procedure updateS();
-- Assume that S contains primary keys (1,2,3,4,5,6,7,8,9).
-- a] update S set y = y + 1 where x = 5;
/*
First trigger executes once
Second trigger also executes once
*/


-- b] update S set y = y + 1 where x > 5;
/*
First trigger executes four times as there are 4 rows being updated x(6,7,8,9)
Second trigger executes once because it is a statement level trigger
*/


-- Q9. 
Emp(empname:text, salary:integer, last_date:timestamp, last_usr:text)
-- ensure any time a row is inserted/updated, current user name and time are stamped into row
-- ensure employee's name is given & salary is positive

create or replace function emp_check() returns trigger
as $$
declare

begin
  if (new.empname is null) then
    raise exception 'Name cannot be null';
    return null;
  end if;

  if (new.salary <= 0) then
    raise exception 'Salary cannot be negative';
    return null;
  end if;

  new.last_date := now();
  new.last_usr := user();

  return new;

  end if;
end;
$$ language plpgsql;


create or replace trigger emp_trigger
before insert or update
on Emp
for each row
execute procedure emp_check();

-- Q11.
Shipments(id:integer, customer:integer, isbn:text, ship_date:timestamp)
Editions(isbn:text, title:text, publisher:integer, published:date,...)
Stock(isbn:text, numInStock:integer, numSold:integer)
Customer(id:integer, name:text,...)

create or replace function new_shipment() returns trigger
as $$
declare
  new_shipment_id integer := 0;
begin
  -- check for customer + isbn
  select *
  from Customer
  where id = new.customer;

  if (not found) then
    raise exception 'Invalid customer id';
  end if;

  select *
  from Editions
  where isbn = new.isbn;

  if (not found) then
    raise exception 'Invalid ISBN';
  end if;

  if (TG_OP = 'INSERT') then 
    update Stock
    set numInStock = numInStock - 1,
        numInSold = numInSold + 1
    where isbn = new.isbn;
  end if;

  if (TG_OP = 'UPDATE') then 
    update Stock
    set numInStock = numInStock + 1
    where isbn = old.isbn;

    update Stock
    set numInStock = numInStock - 1
    where isbn = new.isbn;
  end if;

  select max(id)
  into new_shipment_id
  from Shipments;

  new.id := new_shipment_id + 1;
  new.ship_date := now();

  return new;
end;
$$ language plpgsql;

create or replace trigger new_shipment_trigger
after insert or update
on Shipments
for each row 
execute procedure new_shipment();


-- Q14. avg aggregate
create type SumCount as (sum numeric, count integer);

create or replace function compute(state SumCount, value numeric)
returns SumCount as $$
begin
  if (value is null) then
    return state;
  end if;

  state.sum := state.sum + value;
  state.count := state.count + 1;
  return state;
end;
$$ language plpgsql;

create or replace function doAvg(state SumCount)
returns numeric as $$
  if (state.count = 0) then
    return 0;
  end if;

  return state.sum / state.count;
end;
$$ language plpgsql;

create or replace aggregate avg(numeric) (
  sfunc = compute,
  stype = SumCount,
  initcond = '(0,0)',
  finalfunc = doAvg
);
