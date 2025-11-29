import gleam/dynamic/decode
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

pub fn db_decoder() -> decode.Decoder(AuthToken) {
  use id <- decode.field(0, decode.string)
  use user_id <- decode.field(1, decode.int)
  use token <- decode.field(2, decode.string)
  use ttl_in_seconds <- decode.field(3, decode.int)
  use created_at <- decode.field(4, decode.string)
  decode.success(AuthToken(id:, user_id:, token:, ttl_in_seconds:, created_at:))
}

pub fn json_decoder() -> decode.Decoder(AuthToken) {
  use id <- decode.field("id", decode.string)
  use user_id <- decode.field("user_id", decode.int)
  use token <- decode.field("token", decode.string)
  use ttl_in_seconds <- decode.field("ttl_in_seconds", decode.int)
  use created_at <- decode.field("created_at", decode.string)

  decode.success(AuthToken(id:, user_id:, token:, ttl_in_seconds:, created_at:))
}

pub fn save_token(
  db: sqlight.Connection,
  token token: String,
  user_id user_id: Int,
) -> Result(String, _) {
  let rows =
    sql.upsert_auth_token(
      db,
      [sqlight.text(token), sqlight.int(user_id)],
      decode.at([0], decode.string),
    )

  case rows {
    Ok([token]) -> Ok(token)
    Ok(d) ->
      Error(error.MatchError(
        "Expected exactly one document, got " <> int.to_string(list.length(d)),
      ))
    Error(err) -> Error(err)
  }
}

pub fn find_by_user(db: sqlight.Connection, user_id: Int) -> Result(String, _) {
  let rows =
    sql.get_auth_token_by_user_id(
      db,
      [sqlight.int(user_id)],
      decode.at([0], decode.string),
    )
  case rows {
    Ok([token]) -> Ok(token)
    Ok(d) ->
      Error(error.MatchError(
        "Expected exactly one document, got " <> int.to_string(list.length(d)),
      ))
    Error(err) -> Error(err)
  }
}
