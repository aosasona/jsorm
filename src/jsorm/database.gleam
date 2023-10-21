import gleam/result
import gleam/erlang/os
import sqlight

fn get_db_path() -> String {
  os.get_env("DB_PATH")
  |> result.unwrap("data.db")
}

pub fn connect() -> sqlight.Connection {
  let assert Ok(db) = sqlight.open("file:" <> get_db_path())
  let assert Ok(_) = sqlight.exec("PRAGMA foreign_keys = ON;", db)
  db
}
