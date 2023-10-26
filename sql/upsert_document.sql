INSERT INTO documents
  (id, content, tags, user_id, parent_id)
VALUES
  ($1, $2, $3, $4, $5)
ON CONFLICT (id) DO UPDATE
  SET content = $2, tags = $3, updated_at = datetime()
RETURNING *;
