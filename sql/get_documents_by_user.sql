select id, description, is_public, unixepoch(updated_at) as updated_at
from documents
where user_id = $1 or is_public = true
order by updated_at desc
;
