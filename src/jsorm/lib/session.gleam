import gleam/io
import jsorm/generated/sql
import jsorm/models/session
import jsorm/error.{SessionError}
import ids/ulid
import sqlight

pub const auth_cookie = "__session_token"

pub type SessionToken {
  SessionToken(token: String, issued_at: Int, user_id: Int)
}

fn generate_session_id() -> String {
  ulid.generate()
}

pub fn create_session(
  db: sqlight.Connection,
  user_id: Int,
) -> Result(SessionToken, error.Error) {
  let session_id = generate_session_id()

  case
    sql.insert_session_token(
      db,
      args: [sqlight.int(user_id), sqlight.text(session_id)],
      decoder: session.db_decoder(),
    )
  {
    Ok([session]) ->
      Ok(SessionToken(
        token: session.token,
        issued_at: session.issued_at,
        user_id: session.user_id,
      ))
    Ok(e) -> {
      io.debug(e)
      Error(SessionError("No session returned, but no error returned either."))
    }
    Error(e) -> Error(e)
  }
}
