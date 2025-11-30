import gleam/bool
import gleam/http
import gleam/option.{type Option, None, Some}
import gleam/result
import jsorm/error
import jsorm/lib/auth
import jsorm/models/document
import jsorm/models/user.{type User}
import jsorm/pages/editor
import jsorm/web.{type Context}
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
          echo e
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
          let docs_result = document.find_by_user(db, user.id)

          use <- bool.lazy_guard(
            when: result.is_error(docs_result),
            return: fn() {
              echo result.unwrap_error(docs_result, error.NotFoundError)
              wisp.internal_server_error()
            },
          )

          docs_result
          |> result.unwrap([])
          |> editor.page(user, doc, _)
          |> web.render(200)
          |> next
        }

        Error(error.NotFoundError) -> wisp.not_found()

        Error(error.MatchError(msg)) -> {
          wisp.log_error("Error loading document: " <> msg)
          wisp.internal_server_error()
        }

        Error(error.DatabaseError(e)) -> {
          wisp.log_error("Database error loading document: " <> e.message)
          wisp.internal_server_error()
        }

        // There is a bug here if the document exists but the user does not have access to it (e.g. it is private)
        Error(e) -> {
          echo e
          wisp.log_error("Unknown error loading document")
          wisp.internal_server_error()
        }
      }
    }

    None -> {
      let docs_result = document.find_by_user(db, user.id)

      use <- bool.lazy_guard(when: result.is_error(docs_result), return: fn() {
        echo result.unwrap_error(docs_result, error.NotFoundError)
        wisp.internal_server_error()
      })

      let docs = docs_result |> result.unwrap([])

      document.new(user_id: user.id, parent_id: None)
      |> editor.page(user, _, docs)
      |> web.render(200)
      |> next
    }
  }
}
