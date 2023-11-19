update documents set description = $1, is_public = $2
where id = $3 and user_id = $4
returning *
