import gleam/dynamic
import gleam/result
import jsorm/error
import sqlight

pub type TokenType {
  AuthToken
  SessionToken
}

pub type TokenRequestLog {
  TokenRequestLog(id: Int, token_type: TokenType, created_at: String)
}

fn to_string(t: TokenType) -> String {
  case t {
    AuthToken -> "auth"
    SessionToken -> "session"
  }
}

fn unwrap_single_item(res) {
  case res {
    Ok([id]) -> Ok(id)
    Ok(_) ->
      Error(error.CustomDBError(
        "Unexpected result from token_request_logs insert",
      ))
    Error(err) -> Error(err)
  }
}

pub fn create(
  db: sqlight.Connection,
  user_id user_id: Int,
  token_type token_type: TokenType,
) -> Result(Int, error.Error) {
  let query =
    "INSERT INTO token_request_logs (user_id, token_type, created_at) VALUES ($1, $2, strftime('%s', 'now')) RETURNING id"
  sqlight.query(
    query,
    db,
    [sqlight.int(user_id), sqlight.text(to_string(token_type))],
    dynamic.element(0, dynamic.int),
  )
  |> result.map_error(error.DatabaseError)
  |> unwrap_single_item
}

/// Get the amount of requests made in the last `duration` seconds by a particular user and the amount of time left for the next one (used for rate-limiting)
pub fn get_logs_in_duration(
  db: sqlight.Connection,
  user_id user_id: Int,
  seconds duration: Int,
) -> Result(Int, error.Error) {
  let query =
    "SELECT COUNT(*) as req_count FROM token_request_logs WHERE user_id = $1 AND created_at >= strftime('%s', 'now') - $2"

  sqlight.query(
    query,
    db,
    [sqlight.int(user_id), sqlight.int(duration)],
    dynamic.element(0, dynamic.int),
  )
  |> result.map_error(error.DatabaseError)
  |> unwrap_single_item
}
