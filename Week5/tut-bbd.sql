/* Schema:
Beers(name:string, brewer:string, style: string) <-- note this is correct version following the dump file, tut schema is incorrect
Bars(name:string, address:string, license#:integer)
Drinkers(name:string, address:string, phone:string)
Likes(drinker:string, beer:string)
Sells(bar:string, beer:string, price:real)
Frequents(drinker:string, bar:string)
*/

/* Additional Questions
• How many beers does each brewer make
• Price of cheapest beer given a bar name
*/


/** Q7 - Q11 **/

-- Q7
create or replace function hotelsIn(_addr text)
returns text
as $$
declare
  hotel_string text := '';
begin
  select string_agg(name, E'\n')
  into hotel_string
  from Bars
  group by addr
  having addr = _addr; 

  return hotel_string;
end;
$$ language plpgsql;
-- Query: return me a text string of all hotels in 'The Rocks'

-- Q8
create or replace function hotelsIn2(_addr text)
returns text
as $$
declare
  hotel_string text := '';
begin
  select string_agg(name, ' ')
  into hotel_string
  from Bars
  group by addr
  having addr = _addr; 

  if (not found) then
    return 'There are no hotels in ' || _addr;
  else 
    return 'Hotels in ' || _addr || ': ' || hotel_string;
  end if;
end;
$$ language plpgsql;

-- Q9
-- Note that the sample output that this function produces differs from the tut example as the database has slightly different values
create or replace function happyHourPrice(_hotel text, _beer text, _discount real)
returns text
as $$
declare
  _new_price real := 0.0;
begin
  -- check if valid hotel
  perform *
  from bars
  where name = _hotel;

  if (not found) then
    return 'There is no hotel called ''' || _hotel || '''';
  end if;

  -- check if valid beer
  perform *
  from beers
  where name = _beer;

  if (not found) then
    return 'There is no beer called ''' || _beer || '''';
  end if;

  -- check if hotel sells beer
  select price
  into _new_price
  from sells
  where bar = _hotel and beer = _beer;

  if (not found) then 
    return 'The ' || _hotel || ' does not serve ' || _beer;
  else
    if (_new_price - _discount < 0) then
      return 'Price reduction is too large; ' || _beer || ' only costs ' || to_char(_new_price, '$9.99');
    else
      _new_price := _new_price - _discount;
      return 'Happy hour price for ' || _beer || ' at ' || _hotel || ' is ' || to_char(_new_price, '$9.99');
    end if;
  end if;
end;
$$ language plpgsql;

-- Q10
create or replace function hotelsIn3(_addr text)
returns setof Bars
as $$
declare
  res record;
begin
  for res in
    select * 
    from bars
    where addr = _addr
  loop
    return next res;
  end loop;
end;
$$ language plpgsql;