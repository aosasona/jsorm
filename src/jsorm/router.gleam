import gleam/bool
import gleam/option.{None, Some}
import jsorm/pages
import jsorm/web.{type Context, Context, render}
import jsorm/web/auth
import jsorm/web/editor
import jsorm/web/documents
import jsorm/web/home
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use ctx <- web.extract_user(req, ctx)
  use <- default_responses(req, ctx)
  use <- wisp.rescue_crashes
  use <- wisp.serve_static(req, under: "/assets", from: ctx.dist_directory)

  case wisp.path_segments(req) {
    [] -> home.render_index(req, ctx)
    ["e"] | ["editor"] -> editor.render_editor(req, ctx, None)
    ["e", document_id] | ["editor", document_id] ->
      editor.render_editor(req, ctx, Some(document_id))
    ["documents"] -> documents.handle_request(req, ctx)
    ["documents", "search"] -> documents.search(req, ctx)
    ["documents", "details"] -> documents.edit_details(req, ctx)
    ["sign-in"] -> auth.sign_in(req, ctx)
    ["sign-in", "verify"] -> auth.verify_otp(req, ctx)
    ["sign-out"] -> auth.sign_out(req, ctx)
    _ -> wisp.not_found()
  }
}

fn default_responses(
  req: Request,
  ctx: Context,
  handle_request: fn() -> Response,
) -> Response {
  let res = handle_request()

  // Do not intercept redirects
  use <- bool.guard(when: res.status >= 300 && res.status < 400, return: res)
  use <- bool.guard(when: res.body != wisp.Empty, return: res)
  render(pages.error(ctx, req, res.status), res.status)
}
