import jsorm/pages
import jsorm/web.{Context}
import gleam/http.{Get, Post}
import wisp.{Request, Response}
import nakai/html

pub fn sign_in(req: Request, ctx: Context) -> Response {
  case req.method {
    Get -> render_signin(req)
    Post -> handle_signin(req, ctx)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

fn render_signin(req: Request) -> Response {
  use <- wisp.require_method(req, Get)
  pages.login()
  |> web.render(200)
}

fn handle_signin(req: Request, _ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use _ <- wisp.require_form(req)

  html.Text("Hello, world!")
  |> web.render(200)
}
