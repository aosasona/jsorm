INSERT INTO users
  (email)
VALUES
  ($1)
ON CONFLICT (email) DO NOTHING
  RETURNING *;
