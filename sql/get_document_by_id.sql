select *
from documents
where id = $1 and (user_id = $2 or is_public = true)
;
