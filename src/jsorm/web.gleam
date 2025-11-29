import gleam/http/request
import gleam/list
import gleam/option.{type Option, Some}
import gleam/result
import gleam/string
import jsorm/lib/auth
import jsorm/lib/uri
import jsorm/models/user.{type User}
import nakai
import nakai/html.{type Node}
import plunk
import sqlight
import wisp.{type Request, type Response}

pub type Context {
  Context(
    secret: String,
    db: sqlight.Connection,
    plunk: plunk.Instance,
    dist_directory: String,
    session_token: Option(String),
    user: Option(User),
  )
}

pub fn render(page: Node, code: Int) {
  page
  |> nakai.to_string
  |> wisp.html_response(code)
}

pub fn extract_user(req: Request, ctx: Context, next: fn(Context) -> Response) {
  case auth.get_auth_status(req, ctx.db) {
    auth.LoggedIn(#(user, token)) ->
      next(Context(..ctx, session_token: Some(token), user: Some(user)))
    _ -> next(ctx)
  }
}

pub fn require_user(req: Request, ctx: Context, next: fn(Context) -> Response) {
  case ctx.session_token, ctx.user {
    Some(_), Some(_) -> next(ctx)
    _, _ -> wisp.redirect("/sign-in?redirect=" <> uri.encode(req.path))
  }
}

/// Make a query string from the current request, and append extra query params, optionally including the current path as a redirect.
/// This returns a string like "?redirect=/foo&bar=baz"
pub fn copy_query_params(
  req: Request,
  redirect include_redirect: Bool,
  include other_params: List(#(String, String)),
) {
  let base_params =
    request.get_query(req)
    |> result.unwrap(or: [])
    |> fn(params) { list.flatten([params, other_params]) }

  let redirect_path = case req.path {
    "/" -> "/editor"
    _ -> req.path
  }

  let params =
    case include_redirect {
      True -> {
        case list.key_find(base_params, "redirect") {
          Ok(_) -> base_params
          Error(_) ->
            list.flatten([base_params, [#("redirect", redirect_path)]])
        }
      }
      False -> list.filter(base_params, fn(pair) { pair.0 != "redirect" })
    }
    |> list.filter(fn(pair) { pair.1 != "" })

  let query =
    params
    |> list.map(fn(pair) { pair.0 <> "=" <> uri.encode(pair.1) })
    |> string.join("&")

  case query {
    "" -> ""
    _ -> "/?" <> query
  }
}
