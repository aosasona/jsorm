import gleam/erlang/os
import plunk

pub fn init() -> plunk.Instance {
  let assert Ok(key) = os.get_env("PLUNK_API_KEY")
  plunk.new(key)
}
