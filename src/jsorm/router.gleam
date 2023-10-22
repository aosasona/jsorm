import gleam/bool
import wisp.{Request, Response}
import jsorm/pages
import jsorm/web.{Context, render}
import jsorm/web/auth
import jsorm/web/editor

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use <- wisp.log_request(req)
  use <- default_responses
  use <- wisp.rescue_crashes
  use <- wisp.serve_static(req, under: "/assets", from: ctx.dist_directory)

  case wisp.path_segments(req) {
    [] | ["editor"] -> editor.render_editor(req, ctx)
    ["sign-in"] -> auth.sign_in(req, ctx)
    _ -> wisp.not_found()
  }
}

fn default_responses(handle_request: fn() -> Response) -> Response {
  let res = handle_request()

  use <- bool.guard(when: res.body != wisp.Empty, return: res)

  render(pages.error(res.status), res.status)
}
