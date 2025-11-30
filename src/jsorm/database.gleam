import dot_env/env
import sqlight

fn get_db_path() -> String {
  env.get_string_or("DB_PATH", "data.db")
}

pub fn connect() -> sqlight.Connection {
  let assert Ok(db) = sqlight.open("file:" <> get_db_path())
  let assert Ok(_) = sqlight.exec("PRAGMA foreign_keys = ON;", db)
  db
}
