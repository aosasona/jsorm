select token
from auth_tokens
where
    user_id = $1
    and (((julianday('now') - julianday(created_at))) * 86400) <= ttl_in_seconds
;
