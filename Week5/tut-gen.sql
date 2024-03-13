/** Q1 - Q6 **/

-- Q1
create or replace function sqr(n integer)
returns integer
as $$
begin
  return n * n;
end;
$$ language plpgsql;

-- Q2
create or replace function spread(phrase text)
returns text
as $$
declare
  res text := '';
begin
  for i in 1..length(phrase) loop
    res := res || substring(phrase, i, 1) || ' ';
  end loop;
  return res;
end;
$$ language plpgsql;

-- Q3
create or replace function seq(n integer)
returns setof integer
as $$
begin
  for i in 1..n loop
    return next i;
  end loop;
end;
$$ language plpgsql;
