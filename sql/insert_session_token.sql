INSERT INTO session_tokens
  (user_id, token)
VALUES
  ($1, $2)
RETURNING id, user_id, token, unixepoch(issued_at) as issued_at;
