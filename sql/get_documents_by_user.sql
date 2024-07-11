select id, description, is_public, unixepoch(updated_at) as updated_at
from documents
where user_id = $1
order by updated_at desc;
