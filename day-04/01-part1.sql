select
    count(*) 
from 
    ch04_input
where
    (pair1_b >= pair2_b and pair1_e <= pair2_e) -- CONTAINS
or
    (pair2_b >= pair1_b and pair2_e <= pair1_e) -- CONTAINS

-- 584