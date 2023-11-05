import gleam/io
import jsorm/pages/editor
import jsorm/error
import jsorm/web
import jsorm/models/user
import jsorm/models/document
import jsorm/lib/auth
import jsorm/lib/response
import gleam/dynamic
import gleam/json
import gleam/option.{None, Some}
import gleam/http
import sqlight
import wisp

// This is a hack to get around the current messy syntax highlighting in my editor
type Context =
  web.Context

type User =
  user.User

type Option(a) =
  option.Option(a)

type Request =
  wisp.Request

type Response =
  wisp.Response

pub fn render_editor(
  req: Request,
  ctx: Context,
  document_id: Option(String),
) -> Response {
  use <- wisp.require_method(req, http.Get)

  let #(opt_user, set_cookie) = case ctx.user {
    Some(user) -> #(Some(user), fn(res: Response) { res })
    None -> {
      case auth.signin_as_guest(ctx.db) {
        Ok(#(token, u)) -> #(
          Some(u),
          fn(res: Response) {
            res
            |> auth.set_auth_cookie(req, token.token)
          },
        )
        Error(e) -> {
          io.debug(e)
          #(None, fn(res) { res })
        }
      }
    }
  }

  use user <- user_from_option(opt_user)
  use resp <- load_or_create_document(ctx.db, user, document_id)

  resp
  |> set_cookie
}

type SaveRequest {
  SaveRequest(document_id: String, content: String)
}

pub fn save(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, http.Put)
  use raw_data <- wisp.require_json(req)

  use user <-
    fn(next) {
      case auth.get_auth_status(req, ctx.db) {
        auth.LoggedIn(#(user, _)) -> next(user)
        _ -> {
          wisp.internal_server_error()
        }
      }
    }

  let decoder =
    dynamic.decode2(
      SaveRequest,
      dynamic.field("document_id", dynamic.string),
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
        ]),
        code: 200,
      )
    Error(e) -> {
      io.debug(e)
      response.internal_server_error()
    }
  }
}

fn user_from_option(user: Option(User), next: fn(User) -> Response) -> Response {
  case user {
    Some(u) -> next(u)
    None -> wisp.internal_server_error()
  }
}

// If the document id is not present, create one and redirect to it, otherwise proceed to render the editor
fn load_or_create_document(
  db: sqlight.Connection,
  user: User,
  document_id: Option(String),
  next: fn(Response) -> Response,
) -> Response {
  case document_id {
    Some(doc_id) -> {
      case document.find_by_id_and_user(db, doc_id, user.id) {
        Ok(doc) ->
          next(
            editor.page(doc)
            |> web.render(200),
          )
        Error(e) -> {
          wisp.log_error(case e {
            error.MatchError(msg) -> msg
            error.DatabaseError(e) -> e.message
            _ -> {
              io.debug(e)
              "Unknown error"
            }
          })
          wisp.internal_server_error()
        }
      }
    }
    None -> {
      case
        document.upsert(
          db,
          doc_id: None,
          content: None,
          tags: None,
          user_id: user.id,
          parent_id: None,
        )
      {
        Ok(doc) -> next(wisp.redirect("/e/" <> doc.id))
        Error(e) -> {
          wisp.log_error(case e {
            error.MatchError(msg) -> msg
            error.DatabaseError(e) -> e.message
            _ -> {
              io.debug(e)
              "Unknown error"
            }
          })
          wisp.internal_server_error()
        }
      }
    }
  }
}
