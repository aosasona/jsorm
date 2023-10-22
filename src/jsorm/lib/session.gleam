import gleam/io
import gleam/result.{try}
import jsorm/generated/sql
import jsorm/models/session
import jsorm/models/user
import jsorm/error.{SessionError}
import ids/ulid
import sqlight

pub const auth_cookie = "__session_token"

fn generate_session_id() -> String {
  ulid.generate()
}

fn create_guest_user(db: sqlight.Connection) -> Result(user.User, error.Error) {
  case sql.insert_user(db, args: [sqlight.null()], decoder: user.db_decoder()) {
    Ok([user]) -> Ok(user)
    Ok(e) -> {
      io.debug(e)
      Error(SessionError("No user returned, but no error returned either."))
    }
    Error(e) -> Error(e)
  }
}

pub fn create_guest_session(
  db: sqlight.Connection,
) -> Result(String, error.Error) {
  use user <- try(create_guest_user(db))
  let session_id = generate_session_id()

  case
    sql.insert_session_token(
      db,
      args: [sqlight.int(user.id), sqlight.text(session_id)],
      decoder: session.db_decoder(),
    )
  {
    Ok([session]) -> Ok(session.token)
    Ok(e) -> {
      io.debug(e)
      Error(SessionError("No session returned, but no error returned either."))
    }
    Error(e) -> Error(e)
  }
}
