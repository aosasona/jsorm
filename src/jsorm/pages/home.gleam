import jsorm/components/button
import nakai/attr.{class}
import nakai/html.{div, h1_text, img}

pub fn page() -> html.Node {
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
          text: "Launch",
          render_as: button.Link,
          variant: button.Primary,
          attrs: [attr.href("/editor")],
          class: "block w-max mx-auto lg:mx-0 mt-6 lg:mt-8",
        )),
      ]),
      div([class("mt-10 mb-16 lg:my-0 rounded-lg overflow-hidden")], [
        img([attr.src("/assets/images/mockup.png")]),
      ]),
    ],
  )
}
