import birl/time
import jsorm/generated/sql
import gleam/option.{Some}
import gleam/dynamic
import gleam/list
import gleam/int
import gleam/json
import jsorm/error
import ids/nanoid
import sqlight

type Option(a) =
  option.Option(a)

pub type Document {
  Document(
    id: String,
    content: String,
    tags: String,
    created_at: String,
    updated_at: String,
    user_id: Int,
    parent_id: Option(String),
    is_public: Bool,
    description: Option(String),
  )
}

pub fn db_decoder() -> dynamic.Decoder(Document) {
  dynamic.decode9(
    Document,
    dynamic.element(0, dynamic.string),
    dynamic.element(1, dynamic.string),
    dynamic.element(2, dynamic.string),
    dynamic.element(3, dynamic.string),
    dynamic.element(4, dynamic.string),
    dynamic.element(5, dynamic.int),
    dynamic.element(6, dynamic.optional(dynamic.string)),
    dynamic.element(7, sqlight.decode_bool),
    dynamic.element(8, dynamic.optional(dynamic.string)),
  )
}

pub fn json_decoder() -> dynamic.Decoder(Document) {
  dynamic.decode9(
    Document,
    dynamic.field("id", dynamic.string),
    dynamic.field("content", dynamic.string),
    dynamic.field("tags", dynamic.string),
    dynamic.field("created_at", dynamic.string),
    dynamic.field("updated_at", dynamic.string),
    dynamic.field("user_id", dynamic.int),
    dynamic.field("parent_id", dynamic.optional(dynamic.string)),
    dynamic.field("is_public", sqlight.decode_bool),
    dynamic.field("description", dynamic.optional(dynamic.string)),
  )
}

pub fn new(
  user_id user_id: Int,
  parent_id parent_id: Option(String),
) -> Document {
  let doc_id = nanoid.generate()

  let now =
    time.utc_now()
    |> time.to_naive

  Document(
    id: doc_id,
    content: "{}",
    tags: "[]",
    description: Some("Untitled " <> now),
    is_public: False,
    user_id: user_id,
    parent_id: parent_id,
    created_at: now,
    updated_at: now,
  )
}

pub fn find_by_id_and_user(
  db: sqlight.Connection,
  document_id doc_id: String,
  user_id user_id: Int,
) -> Result(Document, error.Error) {
  case
    sql.get_document_by_id(
      db,
      [sqlight.text(doc_id), sqlight.int(user_id)],
      db_decoder(),
    )
  {
    Ok([]) -> Error(error.NotFoundError)
    Ok([doc]) -> Ok(doc)
    Ok(d) ->
      Error(error.MatchError(
        "Expected exactly one document, got " <> int.to_string(list.length(d)),
      ))
    Error(err) -> Error(err)
  }
}

/// Create a new document or update the document and its tags if it already exists.
pub fn upsert(
  db: sqlight.Connection,
  doc_id doc_id: Option(String),
  content content: Option(String),
  description description: Option(String),
  tags tags: Option(List(String)),
  user_id user_id: Int,
  parent_id parent_id: Option(String),
) -> Result(Document, error.Error) {
  let doc_id = option.unwrap(doc_id, nanoid.generate())
  let description =
    option.unwrap(
      description,
      "Untitled " <> {
        time.utc_now()
        |> time.to_naive
      },
    )

  case
    sql.upsert_document(
      db,
      [
        sqlight.text(doc_id),
        sqlight.text(option.unwrap(content, "{}")),
        sqlight.text(description),
        sqlight.text(
          option.unwrap(tags, [])
          |> json.array(json.string)
          |> json.to_string,
        ),
        sqlight.int(user_id),
        sqlight.nullable(sqlight.text, parent_id),
      ],
      db_decoder(),
    )
  {
    Ok([doc]) -> Ok(doc)
    Ok(d) ->
      Error(error.MatchError(
        "Expected exactly one document, got " <> int.to_string(list.length(d)),
      ))
    Error(err) -> Error(err)
  }
}
