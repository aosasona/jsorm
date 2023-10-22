import nakai/html
import nakai/html/attrs
import jsorm/pages/layout
import jsorm/components/input
import jsorm/components/button

pub fn login_form() {
  html.form(
    [
      attrs.Attr("hx-post", "/sign-in"),
      attrs.Attr("hx-target", "this"),
      attrs.Attr("hx-swap", "outerHTML"),
    ],
    [
      input.component(input.Props(
        id: "email",
        name: "email",
        label: "Email address",
        variant: input.Email,
        attrs: [attrs.placeholder("john@example.com")],
      )),
      button.component(button.Props(
        text: "Continue",
        render_as: button.Button,
        variant: button.Primary,
        attrs: [attrs.type_("submit")],
        class: "w-full mt-6",
      )),
    ],
  )
}

fn login_page() -> html.Node(a) {
  html.div(
    [
      attrs.class(
        "h-[80dvh] lg:h-[85vh] flex flex-col items-center justify-center",
      ),
    ],
    [
      html.div(
        [attrs.class("w-full max-w-xs md:max-w-sm")],
        [
          html.h1_text([attrs.class("text-2xl font-bold mb-2")], "Sign in"),
          html.p_text(
            [attrs.class("text-stone-500 text-sm mb-8")],
            "Enter your email address and we'll send you a one-time password to sign in.",
          ),
          login_form(),
        ],
      ),
    ],
  )
}

pub fn page() -> html.Node(t) {
  login_page()
  |> layout.render(title: "Login")
}
