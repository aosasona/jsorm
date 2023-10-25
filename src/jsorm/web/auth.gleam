import jsorm/pages
import jsorm/web.{Context}
import jsorm/components/button
import jsorm/components/input
import jsorm/components/status_box
import jsorm/pages/layout
import jsorm/pages/login
import jsorm/models/user
import jsorm/models/token_requests_log
import jsorm/lib/auth
import jsorm/lib/validator
import jsorm/lib/uri
import jsorm/mail
import ids/ulid
import gleam/io
import gleam/string
import gleam/int
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

type RatelimitType {
  Throttle
  HardLimit
}

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

fn send_otp(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use formdata <- wisp.require_form(req)
  use email <- validate_email(formdata)
  use user <- create_user_if_not_exists(ctx.db, email)
  use <- rate_limit(ctx.db, Throttle, user.id, email)
  use <- rate_limit(ctx.db, HardLimit, user.id, email)
  use code <- try_send_otp(ctx.plunk, email)
  use <- auth.save_otp(ctx.db, user.id, code)
  use <- log_token_request(ctx.db, user.id)

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
            [attrs.class("mb-4")],
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
            class: "w-full mt-8",
          )),
        ],
      ),
      html.form(
        [
          attrs.Attr("hx-post", "/sign-in"),
          attrs.Attr("hx-disabled-elt", "#resend-otp-btn"),
        ],
        [
          input.component(input.Props(
            id: "email",
            name: "email",
            label: "Email address",
            variant: input.Hidden,
            attrs: [attrs.value(email)],
          )),
          button.component(button.Props(
            text: "Resend OTP",
            render_as: button.Button,
            variant: button.Ghost,
            attrs: [
              attrs.type_("submit"),
              attrs.id("resend-otp-btn"),
              attrs.Attr(
                "_",
                "init js setTimeout(() => { document.querySelector('#resend-otp-btn').removeAttribute('disabled') }, 65000)",
              ),
              attrs.disabled(),
            ],
            class: "w-full mt-4",
          )),
        ],
      ),
      html.a_text(
        [
          attrs.href("?email=" <> uri.encode(email)),
          attrs.class(
            "block text-sm text-yellow-400 underline text-center mt-4",
          ),
        ],
        "Wrong email address?",
      ),
    ],
  )
  |> web.render(200)
}

fn log_token_request(
  db: sqlight.Connection,
  user_id: Int,
  next: fn() -> Response,
) -> Response {
  case token_requests_log.create(db, user_id, token_requests_log.AuthToken) {
    Ok(_) -> next()
    Error(e) -> {
      io.debug(e)
      sign_in_error("Something went wrong, please try again", "")
      |> web.render(200)
    }
  }
}

fn rate_limit(
  db: sqlight.Connection,
  ratelimit_type r_type: RatelimitType,
  user_id user_id: Int,
  email email: String,
  next next: fn() -> Response,
) -> Response {
  let max = case r_type {
    Throttle -> 1
    HardLimit -> 5
  }

  let seconds = case r_type {
    Throttle -> 60
    HardLimit -> 60 * 60 * 6
  }

  let err_msg = case r_type {
    Throttle ->
      "You can only make " <> int.to_string(max) <> " request every " <> int.to_string(
        seconds,
      ) <> " seconds"
    HardLimit ->
      "You can only make " <> int.to_string(max) <> " requests every " <> int.to_string(
        seconds / 60 / 60,
      ) <> " hours"
  }

  case
    token_requests_log.get_logs_in_duration(
      db,
      user_id: user_id,
      seconds: seconds,
    )
  {
    Ok(req_counts) -> {
      case req_counts {
        req_counts if req_counts >= max -> {
          sign_in_error(err_msg, email)
          |> web.render(200)
        }
        _ -> next()
      }
    }
    Error(e) -> {
      io.debug(e)
      sign_in_error("Something went wrong, please try again", email)
      |> web.render(200)
    }
  }
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
      |> web.render(200)
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
          |> web.render(200)
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
          |> web.render(200)
        #(False, _) -> next(email)
      }
    }
    Error(_) ->
      sign_in_error("Email address is required", "")
      |> web.render(200)
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
