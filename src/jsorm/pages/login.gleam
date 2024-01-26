import gleam/string
import nakai/html.{div, form, h1_text}
import nakai/html/attrs.{
  autocomplete, autofocus, class, disabled, id, placeholder, type_, value,
}
import jsorm/components/input
import jsorm/components/button

pub fn form_component(email: String) {
  let email = string.lowercase(email)

  form(
    [
      attrs.Attr("hx-post", "/sign-in"),
      attrs.Attr("hx-disabled-elt", "#send-otp-btn"),
    ],
    [
      div([id("form-error")], []),
      input.component(
        input.Props(
          id: "email",
          name: "email",
          label: "Email address",
          variant: input.Email,
          attrs: [
            value(email),
            placeholder("john@example.com"),
            autocomplete("email"),
            attrs.Attr("required", ""),
          ],
        ),
      ),
      button.component(button.Props(
        text: "Continue",
        render_as: button.Button,
        variant: button.Primary,
        attrs: [type_("submit"), id("send-otp-btn")],
        class: "w-full mt-6",
      )),
    ],
  )
}

fn login_page(email: String) -> html.Node(a) {
  div(
    [class("h-[80dvh] lg:h-[85vh] flex flex-col items-center justify-center")],
    [
      div([class("w-full container max-w-sm md:max-w-md")], [
        h1_text([class("text-2xl font-bold mb-6")], "Sign in"),
        div(
          [
            id("#form-container"),
            attrs.Attr("hx-target", "this"),
            attrs.Attr("hx-target-error", "#form-error"),
          ],
          [form_component(email)],
        ),
      ]),
    ],
  )
}

pub fn otp_form_component(email: String) {
  let email = string.lowercase(email)

  html.Fragment([
    form([attrs.Attr("hx-post", "/sign-in/verify")], [
      div([class("mb-4")], [
        div([id("form-error")], []),
        input.component(
          input.Props(
            id: "email",
            name: "email",
            label: "Email address",
            variant: input.Email,
            attrs: [
              placeholder("john@example"),
              attrs.Attr("required", ""),
              value(email),
              class(
                "disabled:opacity-40 disabled:cursor-not-allowed disabled:select-none disabled:focus:ring-stone-600 disabled:focus:outline-none",
              ),
              attrs.readonly(),
            ],
          ),
        ),
      ]),
      input.component(
        input.Props(
          id: "otp",
          name: "otp",
          label: "One-time password",
          variant: input.Text,
          attrs: [
            placeholder("xxxxxx"),
            attrs.Attr("required", ""),
            autocomplete("one-time-code"),
            autofocus(),
            attrs.Attr("minlength", "6"),
            attrs.Attr("maxlength", "6"),
          ],
        ),
      ),
      button.component(button.Props(
        text: "Sign in",
        render_as: button.Button,
        variant: button.Primary,
        attrs: [attrs.type_("submit")],
        class: "w-full mt-8",
      )),
    ]),
    html.form(
      [
        attrs.Attr("hx-post", "/sign-in"),
        attrs.Attr("hx-disabled-elt", "#resend-otp-btn"),
      ],
      [
        input.component(
          input.Props(
            id: "email",
            name: "email",
            label: "Email address",
            variant: input.Hidden,
            attrs: [attrs.value(email)],
          ),
        ),
        button.component(button.Props(
          text: "Resend OTP",
          render_as: button.Button,
          variant: button.Ghost,
          attrs: [
            type_("submit"),
            id("resend-otp-btn"),
            attrs.Attr(
              "_",
              "init js setTimeout(() => { document.querySelector('#resend-otp-btn').removeAttribute('disabled') }, 60000)",
            ),
            disabled(),
          ],
          class: "w-full mt-4",
        )),
      ],
    ),
    html.a_text(
      [
        attrs.class("block text-sm text-yellow-400 underline text-center mt-4"),
        attrs.id("change-email-link"),
        attrs.Attr(
          "_",
          "init js document.querySelector('#change-email-link').href = '?email="
            <> email
            <> "&' + (new URLSearchParams(window.location.search))?.toString()?.replace('?', '')",
        ),
      ],
      "Wrong email address?",
    ),
  ])
}

pub fn page(default_email: String) -> html.Node(t) {
  login_page(
    default_email
    |> string.lowercase,
  )
}
