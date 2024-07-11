import birl
import gleam/dynamic
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option, Some}
import ids/nanoid
import jsorm/error.{type Error}
import jsorm/generated/sql
import sqlight.{type Connection}

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
    birl.utc_now()
    |> birl.to_naive

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

pub type ListItem {
  ListItem(
    id: String,
    description: String,
    is_public: Bool,
    last_updated_at: Int,
  )
}

pub fn search(
  db: Connection,
  user_id user_id: Int,
  keyword keyword: String,
) -> Result(List(ListItem), Error) {
  case
    sql.search_documents(
      db,
      [sqlight.int(user_id), sqlight.text(keyword)],
      dynamic.decode4(
        ListItem,
        dynamic.element(0, dynamic.string),
        dynamic.element(1, dynamic.string),
        dynamic.element(2, sqlight.decode_bool),
        dynamic.element(3, dynamic.int),
      ),
    )
  {
    Ok([]) -> Ok([])
    Ok(docs) -> Ok(docs)
    Error(e) -> Error(e)
  }
}

pub fn find_by_user(
  db: Connection,
  user_id: Int,
) -> Result(List(ListItem), Error) {
  case
    sql.get_documents_by_user(
      db,
      [sqlight.int(user_id)],
      dynamic.decode4(
        ListItem,
        dynamic.element(0, dynamic.string),
        dynamic.element(1, dynamic.string),
        dynamic.element(2, sqlight.decode_bool),
        dynamic.element(3, dynamic.int),
      ),
    )
  {
    Ok([]) -> Ok([])
    Ok(docs) -> Ok(docs)
    Error(e) -> Error(e)
  }
}

pub fn update_details(
  db: Connection,
  user_id user_id: Int,
  document_id document_id: String,
  description description: String,
  is_public is_public: Int,
) -> Result(Document, Error) {
  case
    sql.update_document_details(
      db,
      [
        sqlight.text(description),
        sqlight.int(is_public),
        sqlight.text(document_id),
        sqlight.int(user_id),
      ],
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

pub fn find_by_id_and_user(
  db: Connection,
  document_id doc_id: String,
  user_id user_id: Int,
) -> Result(Document, Error) {
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
  db: Connection,
  doc_id doc_id: Option(String),
  content content: Option(String),
  description description: Option(String),
  tags tags: Option(List(String)),
  user_id user_id: Int,
  parent_id parent_id: Option(String),
) -> Result(Document, Error) {
  let doc_id = option.unwrap(doc_id, nanoid.generate())
  let description =
    option.unwrap(
      description,
      "Untitled "
        <> {
        birl.utc_now()
        |> birl.to_naive
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
