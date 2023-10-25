select *
from users
where email = $1
limit 1
;
