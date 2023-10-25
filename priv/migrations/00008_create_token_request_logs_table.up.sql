CREATE TABLE IF NOT EXISTS token_request_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  token_type TEXT NOT NULL, -- 'auth' or 'session'
  timestamp INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users (id)
);
