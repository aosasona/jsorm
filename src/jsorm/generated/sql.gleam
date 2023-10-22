// THIS FILE IS GENERATED. DO NOT EDIT.
// Regenerate with `gleam run -m codegen`

import sqlight
import gleam/result
import gleam/dynamic
import jsorm/error.{Error}

pub type QueryResult(t) =
  Result(List(t), Error)

pub fn upsert_auth_token(
  db: sqlight.Connection,
  arguments: List(sqlight.Value),
  decoder: dynamic.Decoder(a),
) -> QueryResult(a) {
  let query =
    "INSERT INTO auth_tokens
  (token, user_id, ttl_in_seconds)
VALUES
  ($1, $2, 120)
ON CONFLICT (user_id) DO UPDATE
  SET token = $1, ttl_in_seconds = 120
RETURNING token;
"
  sqlight.query(query, db, arguments, decoder)
  |> result.map_error(error.DatabaseError)
}
