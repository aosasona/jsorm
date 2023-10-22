import nakai/html
import nakai/html/attrs
import jsorm/pages/layout
import jsorm/components/input
import jsorm/components/button

pub fn page() -> html.Node(t) {
  html.div(
    [
      attrs.class(
        "h-[80dvh] md:h-[90vh] flex flex-col items-center justify-center",
      ),
    ],
    [
      html.div(
        [attrs.class("w-full max-w-xs md:max-w-sm")],
        [
          html.form(
            [],
            [
              html.h1_text([attrs.class("text-2xl font-bold mb-2")], "Sign in"),
              html.p_text(
                [attrs.class("text-stone-500 text-sm mb-8")],
                "Enter your email address and we'll send you a one-time password to sign in.",
              ),
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
          ),
        ],
      ),
    ],
  )
  |> layout.render(title: "Login")
}
