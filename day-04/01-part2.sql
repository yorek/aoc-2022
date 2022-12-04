select
    count(*)
from 
    ch04_input a
where
    (pair1_b <= pair2_e and pair2_b <= pair1_e) -- OVERLAPS

-- 933