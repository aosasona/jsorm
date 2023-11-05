import jsorm/components/button
import nakai/html
import nakai/html/attrs.{class}

// TODO: add screenshot here
pub fn page() -> html.Node(t) {
  html.div(
    [class("w-full min-h-[60vh] container mx-auto")],
    [
      html.h1(
        [class("text-4xl font-bold text-center")],
        [
          html.h1_text(
            [
              class(
                "text-center text-5xl lg:text-7xl font-bold max-w-2xl mx-auto mt-64 mb-12",
              ),
            ],
            "A minimal JSON explorer",
          ),
          button.component(button.Props(
            text: "Launch explorer",
            render_as: button.Link,
            variant: button.Primary,
            attrs: [attrs.href("/editor")],
            class: "block w-max mx-auto",
          )),
        ],
      ),
    ],
  )
}
