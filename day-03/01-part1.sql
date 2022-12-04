/*
    Part 1
*/
-- Split the item list in the two compartements, and calculate the length of each list
drop table if exists #step1;
select 
    *,
    LEN(items) as itemcount,
    LEFT(items, LEN(items)/2) as comp1,
    RIGHT(items, LEN(items)/2) as comp2
into    
    #step1
from 
    ch03_input;
go

-- select * from #step1 order by id

-- create a numbers table
drop table if exists #n;
select top(100) row_number() over (order by a.object_id) as n into #n from sys.columns a cross join sys.columns b
go

-- create a row for each item in the list
drop table if exists #step2;
select 
    *,
    substring(items, n, 1) as item 
into
    #step2 
from 
    #step1 s  
cross join
    #n n
where 
    n.n <= s.itemcount
go

--select * from #step2 order by id

-- get which item is present in both compartements
drop table if exists #step3;
select distinct
    id, items, comp1, comp2, item,
    CHARINDEX(item, comp1, 1) as p1, 
    CHARINDEX(item, comp2, 1) as p2
into 
    #step3
from 
    #step2 
where 
    CHARINDEX(item, comp1, 1) != 0 
and 
    CHARINDEX(item, comp2, 1) != 0
order by id
go

--select * from #step3 order by id

-- calculate the priority for reach elf
drop table if exists #priorities;
select
    item,
    case 
        when item like '[a-z]' then ASCII(item) - ASCII('a') + 1
        when item like '[A-Z]' then ASCII(item) - ASCII('A') + 27
    end as priority,
    id,
    comp1,
    comp2
into
    #priorities
from
    #step3
order by
    item
go

-- select * from #priorities order by id

-- calculate the result
select sum(priority) from #priorities

-- answer: 7917
