import gleam/erlang
import jsorm/database
import migrant

pub fn main() {
  let db = database.connect()

  let assert Ok(priv_directory) = erlang.priv_directory("jsorm")
  let _ = migrant.migrate(db, priv_directory <> "/migrations")

  Nil
}
