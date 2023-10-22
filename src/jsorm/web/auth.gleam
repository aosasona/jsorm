import jsorm/pages
import jsorm/web.{Context}
import gleam/http.{Get, Post}
import wisp.{Request, Response}

pub fn sign_in(req: Request, ctx: Context) -> Response {
  case req.method {
    Get -> render_signin(req)
    Post -> handle_signin(req, ctx)
    _ ->
      pages.error(405)
      |> web.render(200)
  }
}

fn render_signin(req: Request) -> Response {
  use <- wisp.require_method(req, Get)
  pages.login()
  |> web.render(200)
}

fn handle_signin(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)

  todo
}
