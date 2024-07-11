import gleam/bool
import gleam/option
import jsorm/components/button
import jsorm/web.{type Context}
import nakai/attr.{class}
import nakai/html.{div, h1_text, img, p_text}

pub fn page(ctx: Context) -> html.Node {
  div(
    [
      class(
        "w-full lg:min-h-[80vh] container mx-auto lg:grid lg:grid-cols-2 lg:items-center lg:gap-6 px-7 lg:px-2 lg:mt-0",
      ),
    ],
    [
      div([class("mt-40 lg:mt-0")], [
        h1_text(
          [
            class(
              "text-center lg:text-left text-5xl lg:text-7xl font-black leading-tight max-w-2xl mx-auto lg:mx-0",
            ),
          ],
          "A minimal JSON explorer",
        ),
        button.component(button.Props(
          text: {
            use <- bool.guard(option.is_none(ctx.user), "Continue as guest")
            "Launch"
          },
          render_as: button.Link,
          variant: button.Primary,
          attrs: [attr.href("/editor")],
          class: "block w-max mx-auto lg:mx-0 mt-6 lg:mt-8",
        )),
        p_text(
          [
            class(
              "bg-yellow-400/10 border border-yellow-400 text-xs text-yellow-400 mt-5 max-w-lg leading-normal px-4 py-2 rounded-lg",
            ),
          ],
          "You are currently not signed in, you can still use the app as a guest. If you want to save your work for later, please sign in.",
        ),
      ]),
      div([class("mt-10 mb-16 lg:my-0 rounded-lg overflow-hidden")], [
        img([attr.src("/assets/images/mockup.png")]),
      ]),
    ],
  )
}
