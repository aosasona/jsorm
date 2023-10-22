import nakai/html.{Node}
import nakai/html/attrs
import jsorm/components/button
import jsorm/components/link
import jsorm/lib/auth
import jsorm/web.{Context}
import wisp.{Request}

pub type Props {
  Props(title: String, request: Request, ctx: Context)
}

const description = "A minimal JSON explorer & formatter"

const meta_image = "/assets/images/meta.png"

const website_url = "https://jsorm.wyte.space"

fn header(title: String) -> Node(t) {
  html.Head([
    html.meta([attrs.charset("utf-8")]),
    html.meta([
      attrs.name("viewport"),
      attrs.content("width=device-width, initial-scale=1"),
    ]),
    html.meta([attrs.name("theme-color"), attrs.content("#1C1918")]),
    html.link([attrs.rel("icon"), attrs.href("/assets/images/favicon.png")]),
    // OG tags
    html.meta([attrs.property("og:title"), attrs.content(title)]),
    html.meta([attrs.property("og:description"), attrs.content(description)]),
    html.meta([
      attrs.property("og:image"),
      attrs.type_("image/x-icon"),
      attrs.content(meta_image),
    ]),
    html.meta([attrs.property("og:url"), attrs.content(website_url)]),
    html.meta([attrs.property("og:type"), attrs.content("website")]),
    html.meta([
      attrs.property("twitter:card"),
      attrs.content("summary_large_image"),
    ]),
    html.meta([attrs.property("twitter:creator"), attrs.content("@trulyao")]),
    html.meta([
      attrs.property("twitter:title"),
      attrs.content("Jsorm by Wytespace"),
    ]),
    html.meta([
      attrs.property("twitter:description"),
      attrs.content(description),
    ]),
    html.meta([attrs.property("twitter:image"), attrs.content(meta_image)]),
    html.meta([attrs.property("twitter:url"), attrs.content(website_url)]),
    // styles and scripts
    html.link([attrs.rel("stylesheet"), attrs.href("/assets/css/styles.css")]),
    html.link([
      attrs.rel("stylesheet"),
      attrs.href(
        "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css",
      ),
    ]),
    html.Element("script", [attrs.src("https://unpkg.com/htmx.org@1.9.6")], []),
    html.title(title),
  ])
}

fn nav(req: Request, ctx: Context) -> Node(t) {
  let auth_btn = case auth.get_auth_status(req, ctx.db) {
    auth.LoggedOut | auth.InvalidToken ->
      button.component(button.Props(
        text: "Sign in",
        render_as: button.Link,
        variant: button.Primary,
        attrs: [attrs.href("/sign-in")],
        class: "",
      ))
    auth.LoggedIn(_) -> html.Nothing
  }

  html.nav(
    [
      attrs.class(
        "w-full flex justify-between items-center border-b border-b-stone-800 py-4 lg:py-5 px-4 lg:px-6",
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
      html.div(
        [attrs.class("flex items-center")],
        [
          auth_btn,
          html.a(
            [
              attrs.href("https://github.com/aosasona/jsorm"),
              attrs.target("_blank"),
            ],
            [
              html.i_text(
                [
                  attrs.class(
                    "fa-brands fa-github text-3xl text-yellow-400 ml-5",
                  ),
                ],
                "",
              ),
            ],
          ),
        ],
      ),
    ],
  )
}

fn footer() -> Node(t) {
  html.footer(
    [attrs.class("w-full")],
    [
      html.div(
        [attrs.class("text-center text-xs py-8")],
        [
          html.Text("Built by "),
          link.component(
            "Ayodeji",
            link.Props(href: "https://trulyao.dev", new_tab: True),
          ),
        ],
      ),
    ],
  )
}

pub fn render(child: Node(t), props: Props) -> Node(t) {
  let title = case props.title {
    "" -> "Jsorm"
    title -> title
  }

  html.Fragment([
    header(title),
    html.Body([], [nav(props.request, props.ctx), child]),
    footer(),
  ])
}
