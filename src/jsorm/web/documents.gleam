import gleam/dynamic/decode
import gleam/http
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import jsorm/components/palette
import jsorm/lib/auth
import jsorm/lib/response
import jsorm/models/document
import jsorm/web.{type Context}
import nakai/html
import wisp.{type Request, type Response}

type SaveRequest {
  SaveRequest(
    document_id: String,
    description: option.Option(String),
    content: String,
  )
}

type EditDetailsRequest {
  EditDetailsRequest(
    document_id: String,
    content: String,
    title: String,
    is_public: Int,
  )
}

fn edit_details_request_decoder() -> decode.Decoder(EditDetailsRequest) {
  use document_id <- decode.field("document_id", decode.string)
  use content <- decode.field("content", decode.string)
  use title <- decode.field("title", decode.string)
  use is_public <- decode.field("is_public", decode.int)
  decode.success(EditDetailsRequest(document_id:, content:, title:, is_public:))
}

fn auth(req, ctx: Context, next) {
  case auth.get_auth_status(req, ctx.db) {
    auth.LoggedIn(#(user, _)) -> next(user)
    _ -> response.unauthorized()
  }
}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  case req.method {
    http.Put -> save(req, ctx)
    _ -> wisp.method_not_allowed(allowed: [http.Put])
  }
}

pub fn edit_details(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, http.Put)
  use raw_data <- wisp.require_json(req)
  use user <- auth(req, ctx)

  use data: EditDetailsRequest <-
    fn(next: fn(EditDetailsRequest) -> Response) {
      case decode.run(raw_data, edit_details_request_decoder()) {
        Ok(data) -> next(data)
        Error(e) -> {
          echo e
          response.bad_request()
        }
      }
    }

  case
    document.update_details(
      ctx.db,
      user_id: user.id,
      content: data.content,
      document_id: data.document_id,
      description: data.title,
      is_public: data.is_public,
    )
  {
    Ok(doc) ->
      response.ok(
        message: "Saved!",
        data: json.object([
          #("document_id", json.string(doc.id)),
          #("title", json.nullable(from: doc.description, of: json.string)),
          #("is_public", json.bool(doc.is_public)),
        ]),
        code: 200,
      )
    Error(e) -> {
      echo e
      response.internal_server_error()
    }
  }
}

pub fn search(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, http.Post)
  use formdata <- wisp.require_form(req)
  use user <- auth(req, ctx)

  case list.key_find(formdata.values, "query") {
    Ok(q) ->
      case document.search(ctx.db, user_id: user.id, keyword: q) {
        Ok(docs) ->
          html.Fragment(palette.make_documents_list(docs, []))
          |> web.render(200)
        Error(e) -> {
          echo e
          response.internal_server_error()
        }
      }
    Error(e) -> {
      echo e
      response.bad_request()
    }
  }
}

pub fn save(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, http.Put)
  use raw_data <- wisp.require_json(req)
  use user <- auth(req, ctx)

  let save_request_decoder = {
    use document_id <- decode.field("document_id", decode.string)
    use description <- decode.field(
      "description",
      decode.optional(decode.string),
    )
    use content <- decode.field("content", decode.string)
    decode.success(SaveRequest(document_id:, description:, content:))
  }

  use data: SaveRequest <-
    fn(next: fn(SaveRequest) -> Response) {
      case decode.run(raw_data, save_request_decoder) {
        Ok(data) -> next(data)
        Error(e) -> {
          echo e
          response.bad_request()
        }
      }
    }

  case
    document.upsert(
      ctx.db,
      doc_id: Some(data.document_id),
      description: data.description,
      content: Some(data.content),
      tags: None,
      user_id: user.id,
      parent_id: None,
    )
  {
    Ok(doc) ->
      response.ok(
        message: "Saved!",
        data: json.object([
          #("document_id", json.string(doc.id)),
          #("content", json.string(data.content)),
          #("updated_at", json.string(doc.updated_at)),
        ]),
        code: 200,
      )
    Error(e) -> {
      echo e
      response.internal_server_error()
    }
  }
}
