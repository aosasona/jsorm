import gleam/io
import jsorm/pages/editor
import jsorm/error
import jsorm/web.{type Context}
import jsorm/models/user.{type User}
import jsorm/models/document
import jsorm/lib/auth
import gleam/option.{type Option, None, Some}
import gleam/http
import sqlight
import wisp.{type Request, type Response}

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
        Ok(#(token, u)) -> #(Some(u), fn(res: Response) {
          res
          |> auth.set_auth_cookie(req, token.token)
        })
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

fn user_from_option(user: Option(User), next: fn(User) -> Response) -> Response {
  case user {
    Some(u) -> next(u)
    None -> wisp.internal_server_error()
  }
}

// If the document id is not present, generate a false one and redirect to it, otherwise proceed to render the editor
fn load_or_create_document(
  db: sqlight.Connection,
  user: User,
  document_id: Option(String),
  next: fn(Response) -> Response,
) -> Response {
  case document_id {
    Some(doc_id) -> {
      case document.find_by_id_and_user(db, doc_id, user.id) {
        Ok(doc) -> {
          case document.find_by_user(db, user.id) {
            Ok(docs) ->
              next(
                editor.page(doc, docs)
                |> web.render(200),
              )
            Error(e) -> {
              io.debug(e)
              wisp.internal_server_error()
            }
          }
        }

        // There is a bug here if the document exists but the user does not have access to it (e.g. it is private)
        Error(e) -> {
          case e {
            error.NotFoundError -> wisp.not_found()
            _ -> {
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
    None ->
      case document.find_by_user(db, user.id) {
        Ok(docs) ->
          document.new(user_id: user.id, parent_id: None)
          |> editor.page(docs)
          |> web.render(200)
          |> next
        Error(e) -> {
          io.debug(e)
          wisp.internal_server_error()
        }
      }
  }
}
