import jsorm/pages
import jsorm/web.{Context}
import jsorm/pages/layout
import gleam/http.{Get}
import wisp.{Request, Response}

pub fn render_index(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Get)
  pages.login()
  |> layout.render(layout.Props(title: "Sign in", request: req, ctx: ctx))
  |> web.render(200)
}
