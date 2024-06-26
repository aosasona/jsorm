import gleam/dynamic
import gleam/int
import gleam/list
import jsorm/error
import jsorm/generated/sql
import sqlight

pub type AuthToken {
  AuthToken(
    id: String,
    user_id: Int,
    token: String,
    ttl_in_seconds: Int,
    created_at: String,
  )
}

pub type FindTokenResult {
  FindTokenResult(token: String, ttl_in_seconds: Int, created_at: Int)
}

pub fn db_decoder() -> dynamic.Decoder(AuthToken) {
  dynamic.decode5(
    AuthToken,
    dynamic.element(0, dynamic.string),
    dynamic.element(1, dynamic.int),
    dynamic.element(2, dynamic.string),
    dynamic.element(3, dynamic.int),
    dynamic.element(4, dynamic.string),
  )
}

pub fn json_decoder() -> dynamic.Decoder(AuthToken) {
  dynamic.decode5(
    AuthToken,
    dynamic.field("id", dynamic.string),
    dynamic.field("user_id", dynamic.int),
    dynamic.field("token", dynamic.string),
    dynamic.field("ttl_in_seconds", dynamic.int),
    dynamic.field("created_at", dynamic.string),
  )
}

pub fn save_token(
  db: sqlight.Connection,
  token token: String,
  user_id user_id: Int,
) -> Result(String, _) {
  case
    sql.upsert_auth_token(
      db,
      [sqlight.text(token), sqlight.int(user_id)],
      dynamic.element(0, dynamic.string),
    )
  {
    Ok([token]) -> Ok(token)
    Ok(d) ->
      Error(error.MatchError(
        "Expected exactly one document, got " <> int.to_string(list.length(d)),
      ))
    Error(err) -> Error(err)
  }
}

pub fn find_by_user(db: sqlight.Connection, user_id: Int) -> Result(String, _) {
  case
    sql.get_auth_token_by_user_id(
      db,
      [sqlight.int(user_id)],
      dynamic.element(0, dynamic.string),
    )
  {
    Ok([token]) -> Ok(token)
    Ok(d) | Ok([] as d) ->
      Error(error.MatchError(
        "Expected exactly one document, got " <> int.to_string(list.length(d)),
      ))
    Error(err) -> Error(err)
  }
}
