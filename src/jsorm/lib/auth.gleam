import gleam/option.{type Option, None, Some}
import gleam/dynamic
import gleam/result.{try}
import jsorm/error
import jsorm/models/user
import jsorm/models/auth_token
import jsorm/lib/session.{type SessionToken, auth_cookie}
import jsorm/generated/sql
import sqlight
import wisp.{type Request, type Response}

pub type AuthStatus {
  /// The token is not present in the request at all
  LoggedOut
  /// The token is present, active and has a valid user associated with it
  LoggedIn(#(user.User, String))
  /// The token is present but is invalid
  InvalidToken
}

pub fn set_auth_cookie(res: Response, req: Request, token: String) -> Response {
  wisp.set_cookie(res, req, auth_cookie, token, wisp.Signed, 60 * 60 * 24 * 7)
}

pub fn get_auth_status(req: Request, db: sqlight.Connection) -> AuthStatus {
  let cookie = wisp.get_cookie(req, auth_cookie, wisp.Signed)

  case cookie {
    Ok(session_token) ->
      case verify_token(db, session_token) {
        Some(user) -> LoggedIn(#(user, session_token))
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

pub fn remove_session_token(
  db: sqlight.Connection,
  token: String,
) -> Result(_, error.Error) {
  sql.delete_session_token(db, args: [sqlight.text(token)], decoder: dynamic.int,
  )
}

pub fn signin_as_user(
  db: sqlight.Connection,
  user_id: Int,
) -> Result(SessionToken, error.Error) {
  use token <- try(session.create_session(db, user_id))
  Ok(token)
}

pub fn signin_as_guest(
  db: sqlight.Connection,
) -> Result(#(SessionToken, user.User), error.Error) {
  use user <- try(user.create_guest_user(db))
  use token <- try(session.create_session(db, user.id))

  Ok(#(token, user))
}

pub fn save_otp(
  db: sqlight.Connection,
  user_id: Int,
  otp: String,
  next: fn() -> Response,
) -> Response {
  case auth_token.save_token(db, otp, user_id) {
    Ok(_) -> next()
    Error(_) -> wisp.internal_server_error()
  }
}
