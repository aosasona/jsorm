import gleam/json
import wisp

pub fn ok(
  message message: String,
  data data: json.Json,
  code code: Int,
) -> wisp.Response {
  wisp.json_response(
    json.object([
      #("ok", json.bool(True)),
      #("message", json.string(message)),
      #("data", data),
    ])
      |> json.to_string,
    code,
  )
}

pub fn error(message message: String, code code: Int) -> wisp.Response {
  json.object([#("ok", json.bool(False)), #("error", json.string(message))])
  |> json.to_string
  |> wisp.json_response(code)
}

pub fn unauthorized() -> wisp.Response {
  error("Unauthorized", 401)
}

pub fn bad_request() -> wisp.Response {
  error("Bad Request", 400)
}

pub fn internal_server_error() -> wisp.Response {
  error("Internal Server Error", 500)
}
