INSERT INTO documents
  (id, content, tags, user_id, parent_id)
VALUES
  ($1, $2, $3, $4)
ON CONFLICT (id) DO UPDATE
  -- We don't want to update the user_id or parent_id here EVER
  SET content = $2, tags = $3
RETURNING *;
