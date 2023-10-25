import jsorm/generated/sql
import gleam/option.{Option}
import gleam/dynamic
import gleam/list
import gleam/int
import jsorm/error
import ids/nanoid
import sqlight

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
    Ok([doc]) -> Ok(doc)
    Ok(d) ->
      Error(error.MatchError(
        "Expected exactly one document, got " <> int.to_string(list.length(d)),
      ))
    Error(err) -> Error(err)
  }
}

pub fn create(
  db: sqlight.Connection,
  user_id: Int,
  parent_id: Option(String),
) -> Result(Document, error.Error) {
  let doc_id = nanoid.generate()
  case
    sql.upsert_document(
      db,
      [
        sqlight.text(doc_id),
        sqlight.text("{}"),
        sqlight.text("[]"),
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
