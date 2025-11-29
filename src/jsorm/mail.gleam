import dot_env/env
import gleam/hackney
import gleam/json
import gleam/result
import plunk
import plunk/event.{Event}
import plunk/types

pub type MailError {
  HackneyError(hackney.Error)
  PlunkError(types.PlunkError)
}

pub const signin_request_event = "signin-request"

pub fn init() -> plunk.Instance {
  let key = case env.get_string("PLUNK_API_KEY") {
    Ok(k) -> k
    Error(e) -> panic as { "PLUNK_API_KEY environment variable not set: " <> e }
  }

  plunk.new(key)
}

pub fn send_otp(
  instance: plunk.Instance,
  email email: String,
  code code: String,
) -> Result(_, MailError) {
  let resp =
    instance
    |> event.track(
      Event(email: email, event: signin_request_event, data: [
        #("code", json.string(code)),
      ]),
    )
    |> hackney.send

  case resp {
    Ok(res) ->
      event.decode(res)
      |> result.map_error(PlunkError)
    Error(e) -> Error(HackneyError(e))
  }
}
