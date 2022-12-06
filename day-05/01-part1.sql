drop table if exists #t;
select * into #t from ch05_input_stacks;

declare @id int=1, @from int, @to int, @crates int;

drop table if exists #steps;
create table #steps
(
    step_id int not null,
    [crates] int not null,
    [from] int not null,
    [to] int not null,
    [moved] varchar(100) not null,
    [stack_from_before] varchar(100) not null,
    [stack_to_before] varchar(100) not null,
    [stack_from_after] varchar(100) not null,
    [stack_to_after] varchar(100) not null
);

declare @move varchar(100), 
@stack_from_before varchar(100), @stack_to_before varchar(100),
@stack_from_after varchar(100), @stack_to_after varchar(100);

while (1=1)
begin
    select top(1) @from = [from], @to = [to], @crates = [crates] from dbo.ch05_input_steps where id = @id;
    if (@@rowcount=0) break;

    select 
        @stack_from_before = (select top(1) stack from #t where id = @from),
        @stack_to_before = (select top(1) stack from #t where id = @to)
    
    set @move = (select top(1) right(stack, @crates) from #t where id = @from)
    
    select 
        @stack_from_after = left(@stack_from_before, len(@stack_from_before)-len(@move)),
        @stack_to_after = @stack_to_before + reverse(@move)

    insert into #steps values (@id, @crates, @from, @to, @move, @stack_from_before, @stack_to_before, @stack_from_after, @stack_to_after)

    update #t set stack = @stack_from_after where id = @from
    update #t set stack = @stack_to_after where id = @to

    set @id += 1;
end

select string_agg(right(stack,1), '') from #t option(maxdop 1)

-- SHMSDGZVC

select *, right(stack,1) from #t

select * from #steps
