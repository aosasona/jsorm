import wisp.{Request, Response}
import jsorm/pages
import jsorm/web.{Context, render}
import jsorm/web/auth

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use <- wisp.serve_static(req, under: "/assets", from: ctx.dist_directory)

  case wisp.path_segments(req) {
    ["sign-in"] -> auth.sign_in(req, ctx)
    _ -> render(pages.error(404), 404)
  }
}
