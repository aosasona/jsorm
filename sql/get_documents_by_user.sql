select id, description
from documents
where user_id = $1 or is_public = true
order by updated_at desc
;
