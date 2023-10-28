import gleam/option.{Option, Some}
import jsorm/models/user.{User}
import jsorm/lib/auth
import jsorm/lib/uri
import nakai
import nakai/html.{Node}
import plunk
import sqlight
import wisp.{Request, Response}

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

pub fn render(page: Node(t), code: Int) {
  page
  |> nakai.to_string_builder
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
    _, _ -> wisp.redirect("/sign-in?r=" <> uri.encode(req.path))
  }
}
