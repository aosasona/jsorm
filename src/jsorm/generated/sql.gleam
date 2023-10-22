// THIS FILE IS GENERATED. DO NOT EDIT.
// Regenerate with `gleam run -m codegen`

import sqlight
import gleam/result
import gleam/dynamic
import jsorm/error.{Error}

pub type QueryResult(t) =
  Result(List(t), Error)

pub fn upsert_document(
  db: sqlight.Connection,
  arguments: List(sqlight.Value),
  decoder: dynamic.Decoder(a),
) -> QueryResult(a) {
  let query =
    "INSERT INTO documents
  (id, content, tags, user_id, parent_id)
VALUES
  ($1, $2, $3, $4)
ON CONFLICT (id) DO UPDATE
  -- We don't want to update the user_id or parent_id here EVER
  SET content = $2, tags = $3
RETURNING *;
"
  sqlight.query(query, db, arguments, decoder)
  |> result.map_error(error.DatabaseError)
}

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

pub fn insert_user(
  db: sqlight.Connection,
  arguments: List(sqlight.Value),
  decoder: dynamic.Decoder(a),
) -> QueryResult(a) {
  let query =
    "INSERT INTO users
  (email)
VALUES
  ($1)
ON CONFLICT (email) DO NOTHING
  RETURNING id;
"
  sqlight.query(query, db, arguments, decoder)
  |> result.map_error(error.DatabaseError)
}

pub fn insert_session_token(
  db: sqlight.Connection,
  arguments: List(sqlight.Value),
  decoder: dynamic.Decoder(a),
) -> QueryResult(a) {
  let query =
    "INSERT INTO session_tokens
  (user_id, token)
VALUES
  ($1, $2)
RETURNING *;
"
  sqlight.query(query, db, arguments, decoder)
  |> result.map_error(error.DatabaseError)
}
