import gleam/io
import gleam/option.{type Option, None, Some}
import jsorm/error.{SessionError}
import jsorm/generated/sql
import gleam/dynamic
import sqlight

pub type User {
  User(id: Int, email: Option(String), created_at: String, updated_at: String)
}

pub fn db_decoder() -> dynamic.Decoder(User) {
  dynamic.decode4(
    User,
    dynamic.element(0, dynamic.int),
    dynamic.element(1, dynamic.optional(dynamic.string)),
    dynamic.element(2, dynamic.string),
    dynamic.element(3, dynamic.string),
  )
}

pub fn json_decoder() -> dynamic.Decoder(User) {
  dynamic.decode4(
    User,
    dynamic.field("id", dynamic.int),
    dynamic.field("email", dynamic.optional(dynamic.string)),
    dynamic.field("created_at", dynamic.string),
    dynamic.field("updated_at", dynamic.string),
  )
}

pub fn find_by_email(db: sqlight.Connection, email: String) -> Option(User) {
  case
    sql.get_user_by_email(db, args: [sqlight.text(email)], decoder: db_decoder(),
    )
  {
    Ok([user]) -> Some(user)
    Ok([]) -> None
    Ok(e) -> {
      io.debug(e)
      None
    }
    Error(e) -> {
      io.debug(e)
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
      io.debug(e)
      Error(SessionError("No user returned, but no error returned either."))
    }
    Error(e) -> Error(e)
  }
}

pub fn create_guest_user(db: sqlight.Connection) -> Result(User, error.Error) {
  case sql.insert_user(db, args: [sqlight.null()], decoder: db_decoder()) {
    Ok([user]) -> Ok(user)
    Ok(e) -> {
      io.debug(e)
      Error(SessionError("No user returned, but no error returned either."))
    }
    Error(e) -> Error(e)
  }
}
