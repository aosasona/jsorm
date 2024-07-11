import gleam/http.{Get}
import jsorm/pages
import jsorm/pages/layout
import jsorm/web.{type Context}
import wisp.{type Request, type Response}

pub fn render_index(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Get)
  pages.home(ctx)
  |> layout.render(layout.Props(
    title: "Jsorm - A minimal JSON explorer",
    ctx: ctx,
    req: req,
  ))
  |> web.render(200)
}
