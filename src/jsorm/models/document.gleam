import birl
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option, Some}
import jsorm/error.{type Error}
import jsorm/generated/sql
import jsorm/lib/nanoid
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

pub fn db_decoder() -> decode.Decoder(Document) {
  use id <- decode.field(0, decode.string)
  use content <- decode.field(1, decode.string)
  use tags <- decode.field(2, decode.string)
  use created_at <- decode.field(3, decode.string)
  use updated_at <- decode.field(4, decode.string)
  use user_id <- decode.field(5, decode.int)
  use parent_id <- decode.field(6, decode.optional(decode.string))
  use is_public <- decode.field(7, sqlight.decode_bool())
  use description <- decode.field(8, decode.optional(decode.string))

  decode.success(Document(
    id:,
    content:,
    tags:,
    created_at:,
    updated_at:,
    user_id:,
    parent_id:,
    is_public:,
    description:,
  ))
}

pub fn json_decoder() -> decode.Decoder(Document) {
  use id <- decode.field("id", decode.string)
  use content <- decode.field("content", decode.string)
  use tags <- decode.field("tags", decode.string)
  use created_at <- decode.field("created_at", decode.string)
  use updated_at <- decode.field("updated_at", decode.string)
  use user_id <- decode.field("user_id", decode.int)
  use parent_id <- decode.field("parent_id", decode.optional(decode.string))
  use is_public <- decode.field("is_public", sqlight.decode_bool())
  use description <- decode.field("description", decode.optional(decode.string))

  decode.success(Document(
    id:,
    content:,
    tags:,
    created_at:,
    updated_at:,
    user_id:,
    parent_id:,
    is_public:,
    description:,
  ))
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

fn list_item_decoder() -> decode.Decoder(ListItem) {
  use id <- decode.field(0, decode.string)
  use description <- decode.field(1, decode.string)
  use is_public <- decode.field(2, sqlight.decode_bool())
  use last_updated_at <- decode.field(3, decode.int)
  decode.success(ListItem(id:, description:, is_public:, last_updated_at:))
}

pub fn search(
  db: Connection,
  user_id user_id: Int,
  keyword keyword: String,
) -> Result(List(ListItem), Error) {
  let rows =
    sql.search_documents(
      db,
      [sqlight.int(user_id), sqlight.text(keyword)],
      list_item_decoder(),
    )

  case rows {
    Ok([]) -> Ok([])
    Ok(docs) -> Ok(docs)
    Error(e) -> Error(e)
  }
}

pub fn find_by_user(
  db: Connection,
  user_id: Int,
) -> Result(List(ListItem), Error) {
  let rows =
    sql.get_documents_by_user(db, [sqlight.int(user_id)], list_item_decoder())

  case rows {
    Ok([]) -> Ok([])
    Ok(docs) -> Ok(docs)
    Error(e) -> Error(e)
  }
}

pub fn update_details(
  db: Connection,
  user_id user_id: Int,
  content content: String,
  document_id document_id: String,
  description description: String,
  is_public is_public: Int,
) -> Result(Document, Error) {
  let rows =
    sql.upsert_document(
      db,
      [
        sqlight.text(document_id),
        sqlight.text(content),
        sqlight.text(description),
        sqlight.int(is_public),
        sqlight.int(user_id),
      ],
      db_decoder(),
    )

  case rows {
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
