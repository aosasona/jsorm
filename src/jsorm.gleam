import gleam/erlang/process
import gleam/erlang/os
import gleam/result
import gleam/int
import jsorm/database
import jsorm/mail
import jsorm/router.{Context}
import migrant
import mist
import wisp

pub fn main() {
  wisp.configure_logger()

  let db = database.connect()
  let assert Ok(priv_directory) = wisp.priv_directory("jsorm")
  let assert Ok(_) = migrant.migrate(db, priv_directory <> "/migrations")
  let plunk_instance = mail.init()

  let ctx =
    Context(
      db: db,
      plunk: plunk_instance,
      secret: get_app_secret(),
      dist_directory: priv_directory <> "/static/dist",
    )

  let assert Ok(_) =
    router.handle_request(_, ctx)
    |> wisp.mist_handler(ctx.secret)
    |> mist.new
    |> mist.port(get_port())
    |> mist.start_http

  process.sleep_forever()
}

fn get_port() -> Int {
  os.get_env("PORT")
  |> result.then(int.parse)
  |> result.unwrap(8080)
}

fn get_app_secret() -> String {
  os.get_env("APP_SECRET")
  |> result.unwrap("")
}
