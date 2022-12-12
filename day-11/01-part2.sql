set nocount on;
set xact_abort on;

drop table if exists #input_monkeys;
select  
    *
into
    #input_monkeys
from (values
        (0, 'old', '*', '19', 17, 4, 7),
        (1, 'old', '*', '11', 3, 3, 2),
        (2, 'old', '+', '6', 19, 0, 4),
        (3, 'old', '+', '5', 7, 2, 0),
        (4, 'old', '+', '7', 2, 7, 5),
        (5, 'old', '*', 'old', 5, 1, 6),
        (6, 'old', '+', '2', 11, 3, 1),
        (7, 'old', '+', '3', 13, 5, 6)
    ) T (monkey, op1, op, op2, test, [true], [false])
go

--select * from dbo.#input_monkeys
go

drop table if exists #input_values;
with cte as
(
    select * from (values
    (0, '[72, 64, 51, 57, 93, 97, 68]'),
    (1, '[62]'),
    (2, '[57, 94, 69, 79, 72]'),
    (3, '[80, 64, 92, 93, 64, 56]'),
    (4, '[70, 88, 95, 99, 78, 72, 65, 94]'),
    (5, '[57, 95, 81, 61]'),
    (6, '[79, 99]'),
    (7, '[68, 98, 62]')
    ) T(monkey, items)
)
select
    monkey,
    cast([value] as decimal(38,0)) as item
into
    #input_values
from
    cte
cross apply openjson (items)
go

--select * from dbo.#input_values
go

-- Prepare a table to contain rounds data
drop table if exists #round;
select 
    0 as [added_in_round], -- when the item was added
    0 as round,
    *
into
    #round
from 
    #input_values
;

--select * from #round;
go

-- create index to support performances
create clustered index ixc on #round(round, monkey);
go

declare @m int = 0, @r int = 0;
while (@r < 10000 ) -- Run for 10000 rounds
begin
    print @r
    set @m = 0;
    while (@m < 8) -- Process each one of the 8 monkeys on its own, in sequence
    begin
        drop table if exists #temp;

        ;with cte as
        (
            -- calculate the values used in the operation for calculating the new worry level
            select 
                cast(iif(op1 = 'old', item, null) as decimal(38,0)) as op1_final,
                cast(iif(op2 = 'old', item, op2) as decimal(38,0)) as op2_final,
                r.[round],
                r.item,
                m.*
            from
                #round r
            inner join
                #input_monkeys m on r.monkey = m.monkey
            where
                m.monkey = @m and round = @r
        ),
        cte2 as
        (
            -- calculate the worry level using updated algorithm
            select
                (cast(case op 
                    when '*' then cast(op1_final as decimal(38,10)) * cast(op2_final as decimal(38,10)) 
                    when '+' then cast(op1_final as decimal(38,10)) + cast(op2_final as decimal(38,10)) 
                end as decimal(38,10)) % 9699690) as worry_level, -- switch to use LCM of divisors and module operation to avoid overflows
                *
            from
                cte
        ),
        cte3 as 
        (
            -- run the division test and assignt he item to the monkey based on the test result
            select        
                case when worry_level % test = 0 then [true] else [false] end as dest_monkey,
                *
            from
                cte2
        )    
        -- determine if the assigned monkey can handle the item right in this round or the next
        select
            case when dest_monkey <= monkey then round + 1 else round end as next_round,
            *
        into
            #temp
        from
            cte3;

        --select * from #temp;

        -- prepare data for next round
        insert into #round         
            ([added_in_round], round, monkey, item)
        select 
            round as [added_in_round], next_round, dest_monkey, worry_level
        from 
            #temp ;
        
        set @m += 1; -- process next monkey
    end
    set @r += 1; -- process next round
end

--select * from #round where round = 9999 order by monkey
go

-- get the two most active monkeys
;with cte as
(
    select 
        monkey, count(*) as total
    from
        #round
    where
        round < 10000
    group by
        monkey
)
select * from cte order by  total desc

-- calculate the solution
select cast(161523 as bigint) * cast(160567 as bigint)

-- 25935263541