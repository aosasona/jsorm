import gleam/option.{None, Option, Some}
import jsorm/generated/sql
import jsorm/models/user
import jsorm/lib/session.{auth_cookie}
import sqlight
import wisp.{Request}

pub type AuthStatus {
  /// The token is not present in the request at all
  LoggedOut
  /// The token is present, active and has a valid user associated with it
  LoggedIn(user.User)
  /// The token is present but is invalid
  InvalidToken
}

pub fn get_auth_status(req: Request, db: sqlight.Connection) -> AuthStatus {
  let cookie = wisp.get_cookie(req, auth_cookie, wisp.Signed)

  case cookie {
    Ok(session_token) ->
      case verify_token(db, session_token) {
        Some(user) -> LoggedIn(user)
        None -> InvalidToken
      }
    Error(_) -> LoggedOut
  }
}

pub fn verify_token(db: sqlight.Connection, token: String) -> Option(user.User) {
  case
    sql.get_session_user(
      db,
      args: [sqlight.text(token)],
      decoder: user.db_decoder(),
    )
  {
    Ok([user]) -> Some(user)
    Ok(_) -> None
    Error(_) -> None
  }
}

pub fn create_guest_session() {
  todo
}
