import nakai/html.{Node}
import nakai/html/attrs
import jsorm/components
import jsorm/components/button.{Props as ButtonProps}

pub fn render(child: Node(t), title: String) -> Node(t) {
  let title = case title {
    "" -> "Jsorm"
    _ -> title
  }

  html.Fragment([
    html.Head([
      html.meta([attrs.charset("utf-8")]),
      html.meta([
        attrs.name("viewport"),
        attrs.content("width=device-width, initial-scale=1"),
      ]),
      html.title(title),
      html.link([attrs.rel("stylesheet"), attrs.href("/assets/css/styles.css")]),
      html.link([
        attrs.rel("stylesheet"),
        attrs.href(
          "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css",
        ),
      ]),
    ]),
    html.Body(
      [],
      [
        html.nav(
          [
            attrs.class(
              "w-full flex justify-between items-center border-b border-b-stone-800 py-3 lg:py-5 px-4 lg:px-6",
            ),
          ],
          [
            html.a_text(
              [
                attrs.class("text-yellow-400 font-bold text-xl px-2 py-1"),
                attrs.href("/"),
              ],
              "jsorm",
            ),
            button.component(
              label: "Login",
              render_as: button.Link,
              variant: button.Primary,
              attrs: [attrs.href("/login")],
            ),
          ],
        ),
        child,
      ],
    ),
    html.footer(
      [attrs.class("w-full")],
      [
        html.div(
          [attrs.class("text-center text-xs py-8")],
          [
            html.Text("Built by "),
            html.a_text(
              [
                attrs.href("https://trulyao.dev"),
                attrs.rel("noopener noreferrer"),
                attrs.target("_blank"),
                attrs.class("underline text-yellow-400"),
              ],
              "Ayodeji",
            ),
          ],
        ),
      ],
    ),
  ])
}
