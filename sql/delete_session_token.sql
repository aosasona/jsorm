delete from session_tokens
where token = $1
returning id
;
