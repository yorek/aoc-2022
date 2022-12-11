-- split the values in lines and calculate crt positione for each line at each cycle
drop table if exists #crt;
select 
    *,
    (cycle-1)/40 as [line],
    row_number() over (partition by (cycle-1)/40 order by cycle) - 1 as crt_pos
into
    #crt
from
    dbo.ch10_cycles
order by
    cycle;

select * from #crt order by cycle;
go

-- Set the displayed char if the sprite and the crt pos are compatible
drop table if exists #crt_lines;
select 
    *,
    iif(crt_pos between start_value - 1 and start_value + 1, '#', ' ') as [crt_char]
into    
    #crt_lines
from
    #crt
order by
    cycle;

select * from #crt_lines order by cycle;
go

-- aggregate
select 
    [line],
    string_agg(crt_char, '') within group (order by cycle) as crt_line
from 
    #crt_lines 
group by
    [line]


-- PZGPKPEB



