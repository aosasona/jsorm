import sqlight
import plunk
import wisp.{Request, Response}
import nakai
import nakai/html.{Node}
import jsorm/pages

pub type Context {
  Context(
    secret: String,
    db: sqlight.Connection,
    plunk: plunk.Instance,
    dist_directory: String,
  )
}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use <- wisp.serve_static(req, under: "/assets", from: ctx.dist_directory)

  case wisp.path_segments(req) {
    ["sign-in"] -> render(pages.login(), 200)
    _ -> render(pages.error(404), 404)
  }
}

fn render(page: Node(t), code: Int) {
  page
  |> nakai.to_string_builder
  |> wisp.html_response(code)
}
