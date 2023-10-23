import nakai/html.{Node}
import nakai/html/attrs.{class}

pub fn page() -> Node(t) {
  html.div(
    [class("max-w-xl mx-auto")],
    [
      html.h1(
        [class("text-4xl font-bold text-center")],
        [html.Text("Hello, world!")],
      ),
    ],
  )
}
