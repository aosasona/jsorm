import jsorm/components/palette
import jsorm/lib/response
import jsorm/models/document
import jsorm/lib/auth
import jsorm/web.{type Context}
import gleam/dynamic
import gleam/io
import gleam/option.{None, Some}
import gleam/json
import gleam/list
import gleam/http
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
  EditDetailsRequest(document_id: String, title: String, is_public: Bool)
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
  use <- wisp.require_method(req, http.Patch)
  use raw_data <- wisp.require_json(req)
  use user <- auth(req, ctx)

  let decoder =
    dynamic.decode3(
      EditDetailsRequest,
      dynamic.field("document_id", dynamic.string),
      dynamic.field("title", dynamic.string),
      dynamic.field("is_public", dynamic.bool),
    )

  use data <-
    fn(next) {
      case decoder(raw_data) {
        Ok(data) -> next(data)
        Error(e) -> {
          io.debug(e)
          response.bad_request()
        }
      }
    }

  case
    document.update_details(
      ctx.db,
      user_id: user.id,
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
      io.debug(e)
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
          io.debug(e)
          response.internal_server_error()
        }
      }
    Error(e) -> {
      io.debug(e)
      response.bad_request()
    }
  }
}

pub fn save(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, http.Put)
  use raw_data <- wisp.require_json(req)
  use user <- auth(req, ctx)

  let decoder =
    dynamic.decode3(
      SaveRequest,
      dynamic.field("document_id", dynamic.string),
      dynamic.field("description", dynamic.optional(dynamic.string)),
      dynamic.field("content", dynamic.string),
    )

  use data <-
    fn(next) {
      case decoder(raw_data) {
        Ok(data) -> next(data)
        Error(e) -> {
          io.debug(e)
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
      io.debug(e)
      response.internal_server_error()
    }
  }
}
