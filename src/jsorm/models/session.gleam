import gleam/dynamic

pub type Session {
  Session(id: Int, user_id: Int, token: String, issued_at: Int)
}

pub fn db_decoder() -> dynamic.Decoder(Session) {
  dynamic.decode4(
    Session,
    dynamic.element(0, dynamic.int),
    dynamic.element(1, dynamic.int),
    dynamic.element(2, dynamic.string),
    dynamic.element(3, dynamic.int),
  )
}

pub fn json_decoder() -> dynamic.Decoder(Session) {
  dynamic.decode4(
    Session,
    dynamic.field("id", dynamic.int),
    dynamic.field("user_id", dynamic.int),
    dynamic.field("token", dynamic.string),
    dynamic.field("issued_at", dynamic.int),
  )
}
