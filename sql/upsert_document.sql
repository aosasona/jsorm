INSERT INTO documents
  (id, content, description, tags, user_id, parent_id)
VALUES
  ($1, $2, $3, $4, $5, $6)
ON CONFLICT (id) DO UPDATE
  SET content = $2, description = $3, tags = $4, updated_at = datetime()
RETURNING *;
