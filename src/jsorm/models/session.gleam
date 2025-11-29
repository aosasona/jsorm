import gleam/dynamic/decode

pub type Session {
  Session(id: Int, user_id: Int, token: String, issued_at: Int)
}

pub fn db_decoder() -> decode.Decoder(Session) {
  use id <- decode.field(0, decode.int)
  use user_id <- decode.field(1, decode.int)
  use token <- decode.field(2, decode.string)
  use issued_at <- decode.field(3, decode.int)

  decode.success(Session(id, user_id, token, issued_at))
}

pub fn json_decoder() -> decode.Decoder(Session) {
  use id <- decode.field("id", decode.int)
  use user_id <- decode.field("user_id", decode.int)
  use token <- decode.field("token", decode.string)
  use issued_at <- decode.field("issued_at", decode.int)
  decode.success(Session(id, user_id, token, issued_at))
}
