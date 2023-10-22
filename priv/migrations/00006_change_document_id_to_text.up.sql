DROP TABLE IF EXISTS documents;

CREATE TABLE documents (
  id TEXT PRIMARY KEY NOT NULL,
  content TEXT NOT NULL DEFAULT '{}' CHECK (json_valid(content)),
  tags TEXT NOT NULL DEFAULT '[]' CHECK (json_valid(tags)),
  created_at INTEGER NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at INTEGER NOT NULL DEFAULT CURRENT_TIMESTAMP,

  user_id INTEGER NOT NULL,
  parent_id TEXT,
  FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  FOREIGN KEY (parent_id) REFERENCES documents (id) ON DELETE CASCADE
)
