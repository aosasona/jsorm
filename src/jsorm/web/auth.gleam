import jsorm/pages
import jsorm/web.{Context}
import jsorm/components/button
import jsorm/components/input
import jsorm/components/status_box
import jsorm/pages/layout
import jsorm/pages/login
import jsorm/models/user
import jsorm/lib/auth
import jsorm/lib/validator
import jsorm/lib/uri
import jsorm/mail
import ids/ulid
import gleam/io
import gleam/string
import gleam/result
import gleam/list
import gleam/http/request
import gleam/option.{None, Some}
import gleam/http.{Get, Post}
import plunk
import wisp.{Request, Response}
import nakai/html
import nakai/html/attrs
import sqlight

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

  let default_email =
    request.get_query(req)
    |> result.unwrap([])
    |> list.key_find("email")
    |> result.unwrap("")

  pages.login(default_email)
  |> layout.render(layout.Props(title: "Sign in", ctx: ctx))
  |> web.render(200)
}

// TODO: redirect to r query param if present
pub fn verify_otp(req: Request, _ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use _ <- wisp.require_form(req)

  html.Text("Hello, world!")
  |> web.render(200)
}

// TODO: make sure last OTP was sent at least 1 minute ago - ratelimiting
fn send_otp(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use formdata <- wisp.require_form(req)
  use email <- validate_email(formdata)
  use code <- try_send_otp(ctx.plunk, email)
  use user <- create_user_if_not_exists(ctx.db, email)
  use <- auth.save_otp(ctx.db, user.id, code)

  html.div(
    [],
    [
      status_box.component(status_box.Props(
        message: "Please check your email for the OTP",
        status: status_box.Success,
        class: "mb-6",
      )),
      html.form(
        [attrs.Attr("hx-post", "/sign-in/verify")],
        [
          html.div(
            [attrs.class("mb-6")],
            [
              input.component(input.Props(
                id: "email",
                name: "email",
                label: "Email address",
                variant: input.Email,
                attrs: [
                  attrs.placeholder("john@example"),
                  attrs.Attr("required", ""),
                  attrs.value(email),
                  attrs.disabled(),
                  attrs.readonly(),
                ],
              )),
              html.a_text(
                [
                  attrs.href("?email=" <> uri.encode(email)),
                  attrs.class(
                    "block text-sm text-yellow-400 underline text-right mt-2.5",
                  ),
                ],
                "Wrong email address?",
              ),
            ],
          ),
          input.component(input.Props(
            id: "otp",
            name: "otp",
            label: "One-time password",
            variant: input.Text,
            attrs: [
              attrs.placeholder("xxxxxx"),
              attrs.Attr("required", ""),
              attrs.autocomplete("one-time-code"),
              attrs.autofocus(),
              attrs.Attr("minlength", "6"),
              attrs.Attr("maxlength", "6"),
            ],
          )),
          button.component(button.Props(
            text: "Sign in",
            render_as: button.Button,
            variant: button.Primary,
            attrs: [attrs.type_("submit")],
            class: "w-full mt-6",
          )),
        ],
      ),
    ],
  )
  |> web.render(200)
}

fn try_send_otp(p: plunk.Instance, email: String, next: fn(String) -> Response) {
  let code =
    ulid.generate()
    |> string.slice(at_index: -6, length: 6)
    |> string.uppercase

  case mail.send_otp(p, email, code) {
    Ok(_) -> next(code)
    Error(err) -> {
      io.debug(err)
      html.div(
        [],
        [sign_in_error("Failed to send OTP, please try again later", email)],
      )
      |> web.render(400)
    }
  }
}

fn create_user_if_not_exists(
  db: sqlight.Connection,
  email: String,
  next: fn(user.User) -> Response,
) {
  case user.find_by_email(db, email) {
    Some(user) -> next(user)
    None -> {
      case user.create(db, string.lowercase(email)) {
        Ok(user) -> {
          next(user)
        }
        Error(err) -> {
          io.debug(err)
          html.div(
            [],
            [sign_in_error("Failed to send OTP, please try again later", email)],
          )
          |> web.render(400)
        }
      }
    }
  }
}

fn validate_email(formdata: wisp.FormData, next: fn(String) -> Response) {
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
            "",
          )
          |> web.render(400)
        #(False, _) -> next(email)
      }
    }
    Error(_) ->
      sign_in_error("Email address is required", "")
      |> web.render(400)
  }
}

fn sign_in_error(msg: String, email: String) {
  html.div(
    [],
    [
      status_box.component(status_box.Props(
        message: msg,
        status: status_box.Failure,
        class: "mb-4",
      )),
      login.form_component(email),
    ],
  )
}
