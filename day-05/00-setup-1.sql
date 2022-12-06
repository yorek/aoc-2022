declare @input_s varchar(max) = 'G,W,L,J,B,R,T,D
C,W,S
M,T,Z,R
V,P,S,H,C,T,D
Z,D,L,T,P,G
D,C,Q,J,Z,R,B,F
R,T,F,M,J,D,B,S
M,V,T,B,R,H,L
V,S,D,P,Q';

drop table if exists #s;
select
    identity(int, 1, 1) as id,
    replace([value], char(13), '') as stacks
into 
    #s
from
    string_split(@input_s, char(10))
option (maxdop 1);

drop table if exists dbo.ch05_input_stacks;
select 
    identity(int, 1, 1) as id,
    reverse(replace(stacks, ',', '')) as stack
into
    dbo.ch05_input_stacks
from #s
    option (maxdop 1);

drop table if exists dbo.ch05_input_stacks_b;

select
    identity(int, 1, 1) as id, 
    cast(id as int) as stack_id,
    [value] as crate 
into
    dbo.ch05_input_stacks_b
from 
    #s
cross apply
    string_split(stacks,',')
option (maxdop 1);

select * from dbo.ch05_input_stacks_b;




