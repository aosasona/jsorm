import gleam/io
import jsorm/pages/editor
import jsorm/error
import jsorm/web
import jsorm/models/user
import jsorm/models/document
import jsorm/lib/auth
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

pub fn save(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, http.Post)
  todo
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
      case document.create(db, user.id, None) {
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
