import jsorm/pages
import jsorm/web.{Context}
import jsorm/models/user.{User}
import jsorm/lib/auth.{LoggedIn}
import jsorm/lib/session.{auth_cookie}
import gleam/http.{Get, Post}
import gleam/option.{None, Option, Some}
import nakai/html
import nakai/html/attrs
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
  use document_id <- redirect_without_document_id(user, document_id)

  wisp.ok()
  |> response_fn
}

fn user_from_option(user: Option(User), next: fn(User) -> Response) -> Response {
  case user {
    Some(u) -> next(u)
    None -> wisp.redirect("/signin")
  }
}

// If the document id is not present, create one and redirect to it, otherwise proceed to render the editor
fn redirect_without_document_id(
  user: User,
  document_id: Option(String),
  next: fn(String) -> Response,
) -> Response {
  case document_id {
    Some(doc_id) -> next(doc_id)
    None -> wisp.redirect("/documents")
  }
}
