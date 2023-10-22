import gleam/bool
import gleam/option.{None, Some}
import jsorm/pages
import jsorm/web.{Context, render}
import jsorm/web/auth
import jsorm/web/editor
import wisp.{Request, Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use <- wisp.log_request(req)
  use <- default_responses(req, ctx)
  use <- wisp.rescue_crashes
  use <- wisp.serve_static(req, under: "/assets", from: ctx.dist_directory)

  case wisp.path_segments(req) {
    [] | ["editor"] -> editor.render_editor(req, ctx, None)
    ["editor", document_id] -> editor.render_editor(req, ctx, Some(document_id))
    ["sign-in"] -> auth.sign_in(req, ctx)
    _ -> wisp.not_found()
  }
}

fn default_responses(
  req: Request,
  ctx: Context,
  handle_request: fn() -> Response,
) -> Response {
  let res = handle_request()

  use <- bool.guard(when: res.body != wisp.Empty, return: res)

  render(pages.error(req, ctx, res.status), res.status)
}
