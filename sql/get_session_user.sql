select u.*
from session_tokens t
left join users u on u.id = t.user_id
where unixepoch(datetime()) - unixepoch(t.issued_at) < 604800 and t.token = $1
limit 1
;
