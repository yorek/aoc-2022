/*
    Part 2
*/

-- create group of three elves, based on their position in the list
drop table if exists #step1;
select 
    *,
    LEN(items) as itemcount,
    sum(case when (id % 3) != 1 then 0 else 1 end) over (order by id) as group_id
into    
    #step1
from 
    ch03_input;
go

-- select * from #step1

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

--select * from #step2 where id = 1 order by n

-- find which item is in all three elves rucksacks
drop table if exists #step3;
with cte as
(
    -- take the distinct items present in a rucksack
    select distinct id, group_id, item from #step2 
)
select
    group_id,
    item
into
    #step3
from
    cte
group by 
    group_id, item
having
    count(*) = 3 -- if there are three items for this group, then the item but be present in all three rucksacks
order by
    group_id
go

--select * from #step3

/*
    alternative solution
*/
drop table if exists #step3;
select distinct
    a.id as group_id,
    a.item as item
into
    #step3
from 
    #step2 a 
inner join
    #step2 b on a.id + 1 = b.id and a.item = b.item
inner join
    #step2 c on b.id + 1 = c.id and b.item = c.item
where
    a.id % 3 = 1
order by a.id
go

--select * from #step3

-- calculate the priority for reach elf
drop table if exists #priorities;
select
    group_id,
    item,
    case 
        when item like '[a-z]' then ASCII(item) - ASCII('a') + 1
        when item like '[A-Z]' then ASCII(item) - ASCII('A') + 27
    end as priority
into
    #priorities
from
    #step3
order by
    group_id
go

-- select * from #priorities order by group_id

-- calculate the result
select sum(priority) from #priorities

-- answer: 2585
