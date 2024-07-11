import gleam/bit_array
import gleam/bool
import gleam/crypto
import gleam/http.{Get, Post}
import gleam/http/request
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import ids/ulid
import jsorm/components/status_box as status
import jsorm/lib/auth
import jsorm/lib/validator
import jsorm/mail
import jsorm/models/auth_token
import jsorm/models/token_requests_log
import jsorm/models/user
import jsorm/pages
import jsorm/pages/layout
import jsorm/pages/login
import jsorm/web.{type Context}
import nakai/attr as attrs
import nakai/html
import plunk
import sqlight
import wisp.{type Request, type Response}

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
    |> string.lowercase

  pages.login(default_email)
  |> layout.render(layout.Props(title: "Sign in", ctx: ctx, req: req))
  |> web.render(200)
}

pub fn verify_otp(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use formdata <- wisp.require_form(req)
  use email <- validate_email(formdata)

  let otp =
    list.key_find(formdata.values, "otp")
    |> result.unwrap("")

  // While, in theory, this will not cause issues since it will never be equal to the expected OTP, it saves us from doing the work below by just returning early
  // I have used a variable here because the default formatting is annoying and puts the `==` on a new line
  let empty_otp = otp == ""
  use <- bool.guard(
    when: empty_otp,
    return: render_error("Invalid one-time password, please try again", 400),
  )

  let uid = case user.find_by_email(ctx.db, email) {
    Some(user) -> user.id
    None -> 0
  }

  // Same as above, this will never be equal to the expected OTP (since we will most likely get an error) but it saves us from doing the work below by just returning early
  let empty_uid = uid == 0
  use <- bool.guard(
    when: empty_uid,
    return: render_error("No user found with that email address", 400),
  )

  let token_result = auth_token.find_by_user(ctx.db, uid)
  use <- bool.guard(when: result.is_error(token_result), return: {
    render_error("Something went wrong, please try again", 500)
  })

  let expected_otp =
    token_result
    |> result.unwrap("")
    |> bit_array.from_string

  // This will ideally never occur since we are checking for the presence of the Error result above already but, just in case
  let is_empty_otp = bit_array.byte_size(expected_otp) == 0
  use <- bool.guard(
    when: is_empty_otp,
    return: render_error("Something went wrong, please try again", 500),
  )

  // preventing timing attacks by using secure_compare instead of a direct (==) comparison
  let user_otp = bit_array.from_string(otp)
  use <- bool.guard(
    when: crypto.secure_compare(expected_otp, user_otp)
      |> bool.negate,
    return: "Invalid one-time password, please try again or request a new one"
      |> render_error(400),
  )

  case auth.signin_as_user(ctx.db, uid) {
    Ok(session_token) -> {
      html.div(
        [
          attrs.Attr(
            "_",
            "init js window.location.replace((new URL(window.location.href)).searchParams.get('redirect') || '/editor')",
          ),
        ],
        [html.p_text([], "redirecting..")],
      )
      |> web.render(200)
      |> auth.set_auth_cookie(req, session_token.token)
    }
    Error(e) -> {
      io.println("signin as user")
      io.debug(e)
      render_error("Something went wrong, please try again", 500)
    }
  }
}

fn send_otp(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use formdata <- wisp.require_form(req)
  use email <- validate_email(formdata)
  use user <- create_user_if_not_exists(ctx.db, email)
  use <- rate_limit(ctx.db, Throttle, user.id)
  use <- rate_limit(ctx.db, HardLimit, user.id)
  use code <- try_send_otp(ctx.plunk, email)
  use <- auth.save_otp(ctx.db, user.id, code)
  use <- log_token_request(ctx.db, user.id)

  html.div([], [
    status.component(status.Props(
      message: "Please check your email for the OTP",
      status: status.Success,
      class: "mb-6",
    )),
    login.otp_form_component(email),
  ])
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
      render_error("Something went wrong, please try again", 500)
    }
  }
}

fn rate_limit(
  db: sqlight.Connection,
  ratelimit_type r_type: RatelimitType,
  user_id user_id: Int,
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
      "You can only make "
      <> int.to_string(max)
      <> " request every "
      <> int.to_string(seconds)
      <> " seconds"
    HardLimit ->
      "You can only make "
      <> int.to_string(max)
      <> " requests every "
      <> int.to_string(seconds / 60 / 60)
      <> " hours"
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
          render_error(err_msg, 429)
        }
        _ -> next()
      }
    }
    Error(e) -> {
      io.debug(e)
      render_error("Something went wrong, please try again", 500)
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
      io.print_error("Failed to send OTP")
      io.debug(err)
      render_error("Failed to send OTP, please try again later", 500)
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
      case user.create(db, email) {
        Ok(user) -> {
          next(user)
        }
        Error(err) -> {
          io.debug(err)
          render_error("Failed to send OTP, please try again later", 500)
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
          render_error(
            "Email address "
              <> {
              list.first(errors)
              |> result.unwrap("must be valid")
            },
            400,
          )
        #(False, _) -> next(string.lowercase(email))
      }
    }
    Error(_) -> render_error("Email address is required", 400)
  }
}

fn render_error(msg: String, code: Int) {
  status.component(status.Props(
    message: msg,
    status: status.Failure,
    class: "mb-4",
  ))
  |> web.render(code)
}
