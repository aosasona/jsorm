import gleam/dynamic/decode
import gleam/option.{type Option, None, Some}
import gleam/result.{try}
import jsorm/error
import jsorm/generated/sql
import jsorm/lib/session.{type SessionToken, auth_cookie}
import jsorm/models/auth_token
import jsorm/models/user
import sqlight
import wisp.{type Request, type Response}

// 12 hours
const auth_cookie_duration_12_hours = 43_200

// 180 days; 6 months
const auth_cookie_duration_180_days = 15_552_000

pub type AuthStatus {
  /// The token is not present in the request at all
  LoggedOut
  /// The token is present, active and has a valid user associated with it
  LoggedIn(#(user.User, String))
  /// The token is present but is invalid
  InvalidToken
}

pub type DurationPreset {
  /// This is the default duration for the auth cookie, see `auth_cookie_duration_12_hours`
  Default
  /// This is the extended duration for the auth cookie, see `auth_cookie_duration_180_days`
  Extended
}

pub type SetAuthCookieOptions {
  SetAuthCookieOptions(
    /// The request object to set the cookie on
    request: Request,
    /// The session token to set in the cookie
    token: SessionToken,
    /// The duration of the cookie
    duration: DurationPreset,
  )
}

pub fn set_auth_cookie(res: Response, options: SetAuthCookieOptions) -> Response {
  let duration = case options.duration {
    Default -> auth_cookie_duration_12_hours
    Extended -> auth_cookie_duration_180_days
  }
  wisp.set_cookie(
    res,
    options.request,
    auth_cookie,
    options.token.token,
    wisp.Signed,
    duration,
  )
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
  sql.delete_session_token(db, args: [sqlight.text(token)], decoder: decode.int)
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

@external(erlang, "jsorm_ffi", "generate_otp")
pub fn generate_otp() -> String
