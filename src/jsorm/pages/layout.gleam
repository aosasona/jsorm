import nakai/html
import nakai/html/attrs
import jsorm/components/button
import jsorm/components/tabler
import jsorm/components/link
import jsorm/web.{type Context}
import gleam/option.{None, Some}
import wisp

pub type Props {
  Props(title: String, ctx: Context, req: wisp.Request)
}

const description = "A minimal JSON explorer"

const meta_image = "/assets/images/meta.png"

const website_url = "https://jsorm.wyte.space"

pub fn header(title: String) -> html.Node(t) {
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
    html.link([
      attrs.rel("stylesheet"),
      attrs.href(
        "https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css",
      ),
    ]),
    html.link([attrs.rel("stylesheet"), attrs.href("/assets/css/styles.css")]),
    html.Element("script", [attrs.src("/assets/js/htmx.min.js")], []),
    html.Element("script", [attrs.src("/assets/js/ext/response-targets.js")], [],
    ),
    html.Element(
      "script",
      [attrs.src("https://unpkg.com/hyperscript.org@0.9.12")],
      [],
    ),
    html.Element(
      "script",
      [attrs.src("/assets/js/app.js"), attrs.type_("module"), attrs.defer()],
      [],
    ),
    html.title(title),
  ])
}

fn nav(ctx: Context, request: wisp.Request) -> html.Node(t) {
  let query = web.copy_query_params(request, redirect: True, include: [])

  let auth_btn = case ctx.user {
    Some(_) ->
      button.component(button.Props(
        text: "Sign out",
        render_as: button.Link,
        variant: button.Ghost,
        attrs: [attrs.href("/sign-out")],
        class: "mr-5",
      ))
    None ->
      button.component(button.Props(
        text: "Sign in",
        render_as: button.Link,
        variant: button.Primary,
        attrs: [attrs.href("/sign-in" <> query)],
        class: "mr-5",
      ))
  }

  html.nav(
    [
      attrs.class(
        "w-full fixed top-0 left-0 right-0 bg-stone-900/70 backdrop-blur-lg flex justify-between items-center border-b border-b-stone-800 py-4 lg:py-5 px-5 lg:px-8",
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
      html.div([attrs.class("flex items-center")], [
        auth_btn,
        html.a(
          [
            attrs.href("https://github.com/aosasona/jsorm"),
            attrs.target("_blank"),
          ],
          [tabler.icon("brand-github", "text-yellow-400 text-xl")],
        ),
      ]),
    ],
  )
}

pub fn footer() -> html.Node(t) {
  html.footer([attrs.class("w-full")], [
    html.div([attrs.class("text-center text-xs py-8")], [
      html.Text("Built by "),
      link.component(
        "Ayodeji",
        link.Props(href: "https://trulyao.dev", new_tab: True),
      ),
    ]),
  ])
}

pub fn render(child: html.Node(t), props: Props) -> html.Node(t) {
  let title = case props.title {
    "" -> "Jsorm"
    title -> title
  }

  html.Fragment([
    header(title),
    html.Body(
      [attrs.class("mt-[9vh]"), attrs.Attr("hx-ext", "response-targets")],
      [nav(props.ctx, props.req), child],
    ),
    footer(),
  ])
}
