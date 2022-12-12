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

-- drop table if exists #input_monkeys;
-- select  
--     *
-- into
--     #input_monkeys
-- from (values
--         (0, 'old', '*', '19', 23, 2, 3),
--         (1, 'old', '+', '6', 19, 2, 0),
--         (2, 'old', '*', 'old', 13, 1, 3),
--         (3, 'old', '+', '3', 17, 0, 1)
--     ) T (monkey, op1, op, op2, test, [true], [false])
-- go

-- --select * from dbo.#input_monkeys

-- drop table if exists #input_values;
-- select  
--       monkey,
--     cast([item] as bigint) as item
-- into
--     #input_values
-- from (values
--         (0, 79),
--         (0, 98),
--         (1, 54), 
--         (1, 65), 
--         (1, 75), 
--         (1, 74), 
--         (2, 79),
--         (2, 60),
--         (2, 97),
--         (3, 74)) T (monkey, item)
-- go


--select * from dbo.#input_values
go

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

create clustered index ixc on #round(round, monkey);

--select * from #round;
declare @m int = 0, @r int = 0;

while (@r < 10000 )
begin
    print @r
    set @m = 0;
    while (@m < 8)
    begin
        drop table if exists #temp;

        ;with cte as
        (
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
            select
                (cast(case op 
                    when '*' then cast(op1_final as decimal(38,10)) * cast(op2_final as decimal(38,10)) 
                    when '+' then cast(op1_final as decimal(38,10)) + cast(op2_final as decimal(38,10)) 
                end as decimal(38,10)) % 9699690) as worry_level,
                *
            from
                cte
        ),
        cte3 as 
        (
            select        
                case when worry_level % test = 0 then [true] else [false] end as dest_monkey,
                *
            from
                cte2
        )    
        select
            case when dest_monkey <= monkey then round + 1 else round end as next_round,
            *
        into
            #temp
        from
            cte3;

        --select * from #temp;

        insert into #round         
            ([added_in_round], round, monkey, item)
        select 
            round as [added_in_round], next_round, dest_monkey, worry_level
        from 
            #temp ;
        
        set @m += 1;
    end
    set @r += 1;
end

-- select * from #round 
-- where round = 0
-- order by monkey
-- go

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

select cast(161523 as bigint) * cast(160567 as bigint)

-- 25935263541