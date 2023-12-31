import jsorm/pages
import jsorm/web.{type Context}
import jsorm/pages/layout
import gleam/http.{Get}
import wisp.{type Request, type Response}

pub fn render_index(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Get)
  pages.home()
  |> layout.render(layout.Props(
    title: "Jsorm - A minimal JSON explorer",
    ctx: ctx,
    req: req,
  ))
  |> web.render(200)
}
