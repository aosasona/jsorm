INSERT INTO session_tokens
  (user_id, token)
VALUES
  ($1, $2)
RETURNING *;
