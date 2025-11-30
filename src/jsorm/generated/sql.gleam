// THIS FILE IS GENERATED. DO NOT EDIT.
// Regenerate with `gleam run -m sqlgen`

import sqlight
import gleam/result
import gleam/dynamic/decode
import jsorm/error.{type Error}

pub type QueryResult(t) =
  Result(List(t), Error)

pub fn get_user_by_email(
  db: sqlight.Connection,
  args arguments: List(sqlight.Value),
  decoder decoder: decode.Decoder(a),
) -> QueryResult(a) {
  let query =
    "select *
from users
where email = $1
limit 1
;
"
  sqlight.query(query, db, arguments, decoder)
  |> result.map_error(error.DatabaseError)
}

pub fn upsert_document(
  db: sqlight.Connection,
  args arguments: List(sqlight.Value),
  decoder decoder: decode.Decoder(a),
) -> QueryResult(a) {
  let query =
    "INSERT INTO documents
  (id, content, description, tags, user_id, parent_id)
VALUES
  ($1, $2, $3, $4, $5, $6)
ON CONFLICT (id) DO UPDATE
  SET content = $2, description = $3, tags = $4, updated_at = datetime()
RETURNING *;
"
  sqlight.query(query, db, arguments, decoder)
  |> result.map_error(error.DatabaseError)
}

pub fn search_documents(
  db: sqlight.Connection,
  args arguments: List(sqlight.Value),
  decoder decoder: decode.Decoder(a),
) -> QueryResult(a) {
  let query =
    "select id, description, is_public, unixepoch(updated_at) as updated_at
from documents
where user_id = $1 and description like '%' || $2 || '%'
order by updated_at desc
;
"
  sqlight.query(query, db, arguments, decoder)
  |> result.map_error(error.DatabaseError)
}

pub fn get_auth_token_by_user_id(
  db: sqlight.Connection,
  args arguments: List(sqlight.Value),
  decoder decoder: decode.Decoder(a),
) -> QueryResult(a) {
  let query =
    "select token
from auth_tokens
where
    user_id = $1
    and (((julianday('now') - julianday(created_at))) * 86400) <= ttl_in_seconds
;
"
  sqlight.query(query, db, arguments, decoder)
  |> result.map_error(error.DatabaseError)
}

pub fn upsert_auth_token(
  db: sqlight.Connection,
  args arguments: List(sqlight.Value),
  decoder decoder: decode.Decoder(a),
) -> QueryResult(a) {
  let query =
    "INSERT INTO auth_tokens
  (token, user_id, ttl_in_seconds)
VALUES
  ($1, $2, 120)
ON CONFLICT (user_id) DO UPDATE
  SET token = $1, ttl_in_seconds = 120, created_at = datetime()
RETURNING token;
"
  sqlight.query(query, db, arguments, decoder)
  |> result.map_error(error.DatabaseError)
}

pub fn insert_user(
  db: sqlight.Connection,
  args arguments: List(sqlight.Value),
  decoder decoder: decode.Decoder(a),
) -> QueryResult(a) {
  let query =
    "INSERT INTO users
  (email)
VALUES
  ($1)
ON CONFLICT (email) DO NOTHING
  RETURNING *;
"
  sqlight.query(query, db, arguments, decoder)
  |> result.map_error(error.DatabaseError)
}

pub fn get_document_by_id(
  db: sqlight.Connection,
  args arguments: List(sqlight.Value),
  decoder decoder: decode.Decoder(a),
) -> QueryResult(a) {
  let query =
    "select *
from documents
where id = $1 and (user_id = $2 or is_public = 1);
"
  sqlight.query(query, db, arguments, decoder)
  |> result.map_error(error.DatabaseError)
}

pub fn insert_session_token(
  db: sqlight.Connection,
  args arguments: List(sqlight.Value),
  decoder decoder: decode.Decoder(a),
) -> QueryResult(a) {
  let query =
    "INSERT INTO session_tokens
  (user_id, token)
VALUES
  ($1, $2)
RETURNING id, user_id, token, unixepoch(issued_at) as issued_at;
"
  sqlight.query(query, db, arguments, decoder)
  |> result.map_error(error.DatabaseError)
}

pub fn delete_session_token(
  db: sqlight.Connection,
  args arguments: List(sqlight.Value),
  decoder decoder: decode.Decoder(a),
) -> QueryResult(a) {
  let query =
    "delete from session_tokens
where token = $1
returning id
;
"
  sqlight.query(query, db, arguments, decoder)
  |> result.map_error(error.DatabaseError)
}

pub fn update_document_details(
  db: sqlight.Connection,
  args arguments: List(sqlight.Value),
  decoder decoder: decode.Decoder(a),
) -> QueryResult(a) {
  let query =
    "update documents set description = $1, is_public = $2
where id = $3 and user_id = $4
returning *
"
  sqlight.query(query, db, arguments, decoder)
  |> result.map_error(error.DatabaseError)
}

pub fn get_session_user(
  db: sqlight.Connection,
  args arguments: List(sqlight.Value),
  decoder decoder: decode.Decoder(a),
) -> QueryResult(a) {
  let query =
    "select u.*
from session_tokens t
left join users u on u.id = t.user_id
where unixepoch(datetime()) - unixepoch(t.issued_at) < 604800 and t.token = $1
limit 1
;
"
  sqlight.query(query, db, arguments, decoder)
  |> result.map_error(error.DatabaseError)
}

pub fn get_documents_by_user(
  db: sqlight.Connection,
  args arguments: List(sqlight.Value),
  decoder decoder: decode.Decoder(a),
) -> QueryResult(a) {
  let query =
    "select id, description, is_public, unixepoch(updated_at) as updated_at
from documents
where user_id = $1
order by updated_at desc;
"
  sqlight.query(query, db, arguments, decoder)
  |> result.map_error(error.DatabaseError)
}
