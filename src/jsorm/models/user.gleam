import gleam/dynamic/decode
import gleam/option.{type Option, None, Some}
import jsorm/error.{SessionError}
import jsorm/generated/sql
import sqlight

pub type User {
  User(id: Int, email: Option(String), created_at: String, updated_at: String)
}

pub fn db_decoder() -> decode.Decoder(User) {
  use id <- decode.field(0, decode.int)
  use email <- decode.field(1, decode.optional(decode.string))
  use created_at <- decode.field(2, decode.string)
  use updated_at <- decode.field(3, decode.string)

  decode.success(User(id:, email:, created_at:, updated_at:))
}

pub fn json_decoder() -> decode.Decoder(User) {
  use id <- decode.field("id", decode.int)
  use email <- decode.field("email", decode.optional(decode.string))
  use created_at <- decode.field("created_at", decode.string)
  use updated_at <- decode.field("updated_at", decode.string)

  decode.success(User(id:, email:, created_at:, updated_at:))
}

pub fn find_by_email(db: sqlight.Connection, email: String) -> Option(User) {
  let rows =
    sql.get_user_by_email(
      db,
      args: [sqlight.text(email)],
      decoder: db_decoder(),
    )

  case rows {
    Ok([user]) -> Some(user)
    Ok([]) -> None
    Ok(d) -> {
      echo d
      None
    }
    Error(e) -> {
      echo e
      None
    }
  }
}

pub fn create(
  db: sqlight.Connection,
  email: String,
) -> Result(User, error.Error) {
  case sql.insert_user(db, args: [sqlight.text(email)], decoder: db_decoder()) {
    Ok([user]) -> Ok(user)
    Ok(e) -> {
      echo e
      Error(SessionError("No user returned, but no error returned either."))
    }
    Error(e) -> Error(e)
  }
}

pub fn create_guest_user(db: sqlight.Connection) -> Result(User, error.Error) {
  case sql.insert_user(db, args: [sqlight.null()], decoder: db_decoder()) {
    Ok([user]) -> Ok(user)
    Ok(e) -> {
      echo e
      Error(SessionError("No user returned, but no error returned either."))
    }
    Error(e) -> Error(e)
  }
}
