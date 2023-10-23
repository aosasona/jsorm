import gleam/io
import gleam/option.{Option}
import jsorm/error.{SessionError}
import jsorm/generated/sql
import gleam/dynamic
import sqlight

pub type User {
  User(id: Int, email: Option(String), created_at: Int, updated_at: Int)
}

pub fn db_decoder() -> dynamic.Decoder(User) {
  dynamic.decode4(
    User,
    dynamic.element(0, dynamic.int),
    dynamic.element(1, dynamic.optional(dynamic.string)),
    dynamic.element(2, dynamic.int),
    dynamic.element(3, dynamic.int),
  )
}

pub fn json_decoder() -> dynamic.Decoder(User) {
  dynamic.decode4(
    User,
    dynamic.field("id", dynamic.int),
    dynamic.field("email", dynamic.optional(dynamic.string)),
    dynamic.field("created_at", dynamic.int),
    dynamic.field("updated_at", dynamic.int),
  )
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
