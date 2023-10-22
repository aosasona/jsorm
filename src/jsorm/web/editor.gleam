import jsorm/pages
import jsorm/web.{Context}
import jsorm/lib/auth.{InvalidToken, LoggedIn, LoggedOut}
import gleam/http.{Get, Post}
import gleam/option.{None, Option, Some}
import wisp.{Request, Response}
import nakai/html
import nakai/html/attrs

pub fn render_editor(
  req: Request,
  ctx: Context,
  document_id: Option(String),
) -> Response {
  todo
  // case auth.get_auth_status(req, ctx) {
  //
  // }
}
