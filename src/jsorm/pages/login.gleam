import jsorm/lib/uri
import nakai/html
import nakai/html/attrs
import jsorm/components/input
import jsorm/components/button

pub fn form_component(email: String) {
  html.form(
    [
      attrs.Attr("hx-post", "/sign-in"),
      attrs.Attr("hx-disabled-elt", "#send-otp-btn"),
    ],
    [
      input.component(input.Props(
        id: "email",
        name: "email",
        label: "Email address",
        variant: input.Email,
        attrs: [
          attrs.value(email),
          attrs.placeholder("john@example.com"),
          attrs.autocomplete("email"),
          attrs.Attr("required", ""),
        ],
      )),
      button.component(button.Props(
        text: "Continue",
        render_as: button.Button,
        variant: button.Primary,
        attrs: [attrs.type_("submit"), attrs.id("send-otp-btn")],
        class: "w-full mt-6",
      )),
    ],
  )
}

fn login_page(email: String) -> html.Node(a) {
  html.div(
    [
      attrs.class(
        "h-[80dvh] lg:h-[85vh] flex flex-col items-center justify-center",
      ),
    ],
    [
      html.div(
        [attrs.class("w-full container max-w-sm md:max-w-md")],
        [
          html.h1_text([attrs.class("text-2xl font-bold mb-6")], "Sign in"),
          html.div(
            [
              attrs.id("#form-container"),
              attrs.Attr("hx-target", "this"),
              attrs.Attr("hx-swap", "innerHTML"),
            ],
            [form_component(email)],
          ),
        ],
      ),
    ],
  )
}

pub fn page(default_email: String) -> html.Node(t) {
  login_page(default_email)
}

pub fn otp_form_component(email: String) {
  html.Fragment([
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
                attrs.class(
                  "disabled:opacity-40 disabled:cursor-not-allowed disabled:select-none disabled:focus:ring-stone-600 disabled:focus:outline-none",
                ),
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
              "init js setTimeout(() => { document.querySelector('#resend-otp-btn').removeAttribute('disabled') }, 60000)",
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
        attrs.class("block text-sm text-yellow-400 underline text-center mt-4"),
      ],
      "Wrong email address?",
    ),
  ])
}
