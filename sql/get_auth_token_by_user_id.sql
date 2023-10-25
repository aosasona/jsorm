select token, ttl_in_seconds, unixepoch(issued_at) as issued_at
from auth_tokens
where user_id = $1
;
