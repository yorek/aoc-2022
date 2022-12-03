-- Part 1

drop table if exists [#rounds];
with cte_decode as
(
    select 
        * 
    from 
        (values
            ('A', 'Rock', 1),
            ('Y', 'Paper', 2),
            ('B', 'Paper', 2),
            ('X', 'Rock', 1),
            ('C', 'Scissors', 3),
            ('Z', 'Scissors', 3)
        ) decode(code, [shape], [value])
)
select 
    eg.*,
    d1.shape as opponent_shape,
    d2.shape as player_shape,
    d1.[value] as opponent_value,
    d2.[value] as player_value
into
    [#rounds]
from 
    dbo.ch02_input as eg
inner join
    cte_decode d1 on eg.opponent = d1.code
inner join
    cte_decode d2 on eg.player = d2.code
;

drop table if exists [#results];
select 
    *,
    case 
        when opponent_shape = player_shape then 3 -- Tie
        when opponent_shape = 'Rock' and player_shape = 'Paper' then 6 -- Won
        when opponent_shape = 'Rock' and player_shape = 'Scissors' then 0  -- Lost
        when opponent_shape = 'Paper' and player_shape = 'Rock' then 0 -- Lost
        when opponent_shape = 'Paper' and player_shape = 'Scissors' then 6  -- Won
        when opponent_shape = 'Scissors' and player_shape = 'Paper' then 0 -- Lost
        when opponent_shape = 'Scissors' and player_shape = 'Rock' then 6 -- Won
    end as outcome
into
    #results
from 
    #rounds;

--select *, player_value + outcome as round_total from #results

-- Part 1 Result
select sum(player_value + outcome) from #results

-- 13052
