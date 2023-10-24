import jsorm/pages
import jsorm/web.{Context}
import jsorm/components/status_box
import jsorm/pages/layout
import jsorm/pages/login
import jsorm/lib/auth
import jsorm/lib/validator
import jsorm/mail
import ids/ulid
import gleam/io
import gleam/string
import gleam/result
import gleam/list
import gleam/option.{None, Some}
import gleam/http.{Get, Post}
import wisp.{Request, Response}
import nakai/html

pub fn sign_in(req: Request, ctx: Context) -> Response {
  case req.method {
    Get -> render_signin(req, ctx)
    Post -> send_otp(req, ctx)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

pub fn sign_out(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Get)

  case ctx.session_token {
    Some(token) -> {
      let _ = auth.remove_session_token(ctx.db, token)
      wisp.redirect("/")
    }
    None -> wisp.redirect("/")
  }
}

fn render_signin(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Get)
  pages.login()
  |> layout.render(layout.Props(title: "Sign in", ctx: ctx))
  |> web.render(200)
}

// TODO: redirect to r query param if present
fn verify_otp(req: Request, _ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use _ <- wisp.require_form(req)

  html.Text("Hello, world!")
  |> web.render(200)
}

// TODO: Send OTP to user and render OTP verification page (+ hidden email form field)
fn send_otp(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use formdata <- wisp.require_form(req)

  let code =
    ulid.generate()
    |> string.slice(at_index: -6, length: 6)

  use email <- fn(next: fn(String) -> Response) {
    case list.key_find(formdata.values, "email") {
      Ok(email) -> {
        case
          validator.validate_field(email, [validator.Required, validator.Email])
        {
          #(True, errors) ->
            sign_in_error(
              "Email address " <> {
                list.first(errors)
                |> result.unwrap("must be valid")
              },
            )
            |> web.render(400)
          #(False, _) -> next(email)
        }
      }
      Error(_) ->
        sign_in_error("Email address is required")
        |> web.render(400)
    }
  }()

  use <- fn(next: fn() -> Response) {
    case mail.send_otp(ctx.plunk, email, code) {
      Ok(_) -> next()
      Error(err) -> {
        io.debug(err)

        html.div(
          [],
          [
            sign_in_error("Failed to send OTP, please try again later"),
            login.form_component(),
          ],
        )
        |> web.render(400)
      }
    }
  }()

  html.Text("Hello, world!")
  |> web.render(200)
}

fn sign_in_error(msg: String) {
  html.div(
    [],
    [
      status_box.component(status_box.Props(
        message: msg,
        status: status_box.Failure,
        class: "mb-4",
      )),
      login.form_component(),
    ],
  )
}
