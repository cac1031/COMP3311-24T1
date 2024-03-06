/************
* Q12 - Q23 *
************/

create table Suppliers (
  sid     integer primary key,
  sname   text,
  address text
);

create table Parts (
  pid     integer primary key,
  pname   text,
  colour  text
);

create table Catalog (
  sid     integer references Suppliers(sid),
  pid     integer references Parts(pid),
  cost    real,
  primary key (sid,pid)
);

-- Q12
-- Find the names of suppliers who supply some red part.
select s.sname
from Suppliers s
  join Catalog c on (c.sid = s.sid)
  join Parts p on (p.pid = c.pid)
where p.colour = 'red';

-- Q14
select s.sid
from Suppliers s
  join Catalog c on (c.sid = s.sid)
  join Parts p on (p.pid = c.pid)
where p.colour = 'red' or s.address = '221 Packer Street';

-- Q16
select sid
from Suppliers
where not exists (
  (select p.pid from Parts p)
  except 
  (select c.pid from Catalog c where (c.sid = sid))
);

select c.sid
from Catalog c
group by c.sid
having count(*) = (select count(*) from Parts);

-- Q22
create or replace view YosemiteSupplies as
select c.pid, c.cost
from Catalog c
  join Suppliers s on (s.sid = c.sid)
where s.sname = 'Yosemite Sham';

select pid
from YosemiteSupplies
where cost = (select max(cost) from YosemiteSupplies);

-- Q23
-- Find the pids of parts supplied by every supplier at a price less than 200 dollars (if any supplier either does not supply the part or charges more than 200 dollars for it, the part should not be selected).
select c.pid
from Catalog c
where c.cost < 200
group by c.pid
having count(*) = (select count(*) from Suppliers); 
