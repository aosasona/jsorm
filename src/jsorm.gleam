import dot_env as dot
import dot_env/env
import gleam/erlang/process
import gleam/option.{None}
import jsorm/database
import jsorm/mail
import jsorm/router
import jsorm/web.{Context}
import migrant
import mist
import wisp
import wisp/wisp_mist

pub fn main() {
  dot.new()
  |> dot.set_path(".env")
  |> dot.set_debug(False)
  |> dot.load

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
      session_token: None,
      user: None,
    )

  let assert Ok(_) =
    router.handle_request(_, ctx)
    |> wisp_mist.handler(ctx.secret)
    |> mist.new
    |> mist.bind("0.0.0.0")
    |> mist.port(get_port())
    |> mist.start

  process.sleep_forever()
}

fn get_port() -> Int {
  env.get_int_or("PORT", 8080)
}

fn get_app_secret() -> String {
  env.get_string_or("APP_SECRET", "")
}
