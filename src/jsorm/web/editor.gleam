import gleam/io
import jsorm/pages
import jsorm/error
import jsorm/web.{Context}
import jsorm/models/user.{User}
import jsorm/models/document.{Document}
import jsorm/lib/auth.{LoggedIn}
import jsorm/lib/session.{auth_cookie}
import gleam/http.{Get, Post}
import gleam/option.{None, Option, Some}
import nakai/html
import nakai/html/attrs
import sqlight
import wisp.{Request, Response}

pub fn render_editor(
  req: Request,
  ctx: Context,
  document_id: Option(String),
) -> Response {
  let #(opt_user, response_fn) = case auth.get_auth_status(req, ctx.db) {
    LoggedIn(user) -> #(Some(user), fn(res: Response) { res })
    _ -> {
      case auth.signin_as_guest(ctx.db) {
        Ok(#(token, u)) -> #(
          Some(u),
          fn(res: Response) {
            res
            |> wisp.set_cookie(
              req,
              auth_cookie,
              token.token,
              wisp.Signed,
              60 * 60 * 24 * 7,
            )
          },
        )
        Error(_) -> #(None, fn(res) { res })
      }
    }
  }

  use user <- user_from_option(opt_user)
  use _document <- load_or_create_document(ctx.db, user, document_id)

  // pass the document, request and context to the page to be rendered

  wisp.ok()
  |> response_fn
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
  next: fn(Document) -> Response,
) -> Response {
  case document_id {
    Some(doc_id) -> {
      case document.find_by_id_and_user(db, doc_id, user.id) {
        Ok(doc) -> next(doc)
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
        Ok(doc) -> wisp.redirect("/e/" <> doc.id)
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
