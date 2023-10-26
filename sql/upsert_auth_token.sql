INSERT INTO auth_tokens
  (token, user_id, ttl_in_seconds)
VALUES
  ($1, $2, 120)
ON CONFLICT (user_id) DO UPDATE
  SET token = $1, ttl_in_seconds = 120, created_at = datetime()
RETURNING token;
