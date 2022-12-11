-- Decode all the commands
drop table if exists #commands;
with cte as
(
    select 
        charindex(' ', [commandline]) as space_pos,
        len(commandline) as commandline_len,
        * 
    from 
        dbo.ch10_input
), 
cte2 as (
    select
        ordinal,
        commandline,
        iif(space_pos=0, commandline, left(commandline, space_pos)) as command,
        cast(iif(space_pos=0, null, right(commandline, commandline_len - space_pos + 1)) as int) as [value]
    from
        cte
), 
cte3 as
(
    select    
        *,
        cast(iif(command='noop',1,2) as int) as [cycles]  
    from    
        cte2
)
select
    *
into
    #commands
from
    cte3
go

select * from #commands;
go

-- details the start and end cycle - and related values - for each command
drop table if exists #command_details;
with cte as (
    select
        *,
        sum(cycles) over (order by ordinal) as end_cycle,
        isnull(sum([value]) over (order by ordinal), 0) + 1 as end_value
    from
        #commands
),
cte2 as
(
    select     
        ordinal,
        commandline,
        command,
        [value] as command_value,
        [cycles] as command_cycles,
        lag(end_cycle, 1, 0) over (order by ordinal) as start_cycle,
        end_cycle,
        lag(end_value, 1, 1) over (order by ordinal) as start_value,
        end_value
    from 
        cte
)
select
    *
into
    #command_details
from
    cte2
;

select * from #command_details order by ordinal;
go

-- create a table of numbers
drop table if exists #numbers;
select top(100000) row_number() over (order by a.object_id) as n into #numbers from sys.columns a, sys.columns b;
go

-- expand the data so that there is exactly one row per cycle
drop table if exists #cycles_exploded;
select
    ordinal,
    commandline,
    command,
    command_value,
    command_cycles,
    start_cycle,
    end_cycle, 
    n as [cycle],
    start_value,
    end_value
into
    #cycles_exploded 
from
    #command_details cd
inner join
    #numbers n on n-1 >= cd.start_cycle and n <= cd.end_cycle
order by n;

-- Calculate signal strength
select 
    *,
    [cycle] * [start_value] as [signal_strength]
from
    #cycles_exploded
-- where 
--       cycle in (20, 60, 100, 140, 180, 220)
order by
    cycle

-- Find result
select 
    sum([cycle] * [start_value]) as [signal_strength]
from
    #cycles_exploded
where 
    cycle in (20, 60, 100, 140, 180, 220)

-- 13680

-- Prepare for Part 2
drop table if exists  dbo.ch10_cycles;
select * into dbo.ch10_cycles from #cycles_exploded 

