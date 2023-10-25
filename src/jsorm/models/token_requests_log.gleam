import gleam/dynamic
import sqlight

pub type TokenType {
  AuthToken
  SessionToken
}

pub type TokenRequestLog {
  TokenRequestLog(id: Int, token_type: TokenType, timestamp: String)
}

fn token_type(
  dyn: dynamic.Dynamic,
) -> Result(TokenType, List(dynamic.DecodeError)) {
  case dynamic.string(dyn) {
    Ok("auth") -> Ok(AuthToken)
    Ok("session") -> Ok(SessionToken)
    Error(err) -> Error(err)
  }
}

fn token_request_db_decoder() -> dynamic.Decoder(TokenRequestLog) {
  dynamic.decode3(
    TokenRequestLog,
    dynamic.element(0, dynamic.int),
    dynamic.element(1, token_type),
    dynamic.element(2, dynamic.string),
  )
}

pub fn log_request(
  db: sqlight.Connection,
  user_id user_id: Int,
  token_type token_type: TokenType,
) -> Result(Int, sqlight.Error) {
  todo
}
