INSERT INTO documents (id, content, description, is_public, user_id)
VALUES ($1, $2, $3, $4, $5)
ON CONFLICT(id) DO UPDATE SET
    content     = excluded.content,
    description = excluded.description,
    is_public   = excluded.is_public,
    updated_at  = CURRENT_TIMESTAMP
RETURNING *;
