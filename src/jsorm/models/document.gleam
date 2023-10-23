import gleam/dynamic

pub type Document {
  Document(
    id: Int,
    content: String,
    tags: String,
    created_at: Int,
    updated_at: Int,
    user_id: Int,
    parent_id: Int,
  )
}

pub fn db_decoder() -> dynamic.Decoder(Document) {
  dynamic.decode7(
    Document,
    dynamic.element(0, dynamic.int),
    dynamic.element(1, dynamic.string),
    dynamic.element(2, dynamic.string),
    dynamic.element(3, dynamic.int),
    dynamic.element(4, dynamic.int),
    dynamic.element(5, dynamic.int),
    dynamic.element(6, dynamic.int),
  )
}

pub fn json_decoder() -> dynamic.Decoder(Document) {
  dynamic.decode7(
    Document,
    dynamic.field("id", dynamic.int),
    dynamic.field("content", dynamic.string),
    dynamic.field("tags", dynamic.string),
    dynamic.field("created_at", dynamic.int),
    dynamic.field("updated_at", dynamic.int),
    dynamic.field("user_id", dynamic.int),
    dynamic.field("issued_at", dynamic.int),
  )
}
