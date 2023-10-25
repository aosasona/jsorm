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
