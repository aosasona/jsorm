import jsorm/pages/layout
import jsorm/models/document
import jsorm/components/button as btn
import jsorm/components/tabler
import nakai/html.{
  aside, button, div, h2_text, main, nav, section, textarea_text,
}
import nakai/html/attrs.{class, id}

// This is a hack to get around the current messy syntax highlighting in my editor
type Document =
  document.Document

type Node(t) =
  html.Node(t)

fn editor_component(document: Document) -> Node(t) {
  section(
    [class("w-full h-[50vh] md:h-auto")],
    [
      textarea_text(
        [
          class(
            "h-full w-full text-yellow-400 bg-stone-900 resize-none focus:outline-none p-4",
          ),
          id("editor"),
        ],
        document.content,
      ),
    ],
  )
}

fn preview_component() -> html.Node(t) {
  section([class("w-full h-[50vh] md:h-auto p-4"), id("preview")], [])
}

fn header_component() -> html.Node(t) {
  html.header(
    [],
    [
      nav(
        [
          class(
            "w-full flex items-center justify-between py-3 px-4 lg:px-6 border-b-2 border-b-stone-800",
          ),
        ],
        [
          button(
            [
              class("text-yellow-400 text-2xl transition-all"),
              id("sidebar-toggle"),
              attrs.Attr("data-status", "closed"),
            ],
            [tabler.icon(name: "layout-sidebar-left-expand", class: "")],
          ),
          btn.component(btn.Props(
            text: "Save",
            class: "",
            render_as: btn.Button,
            variant: btn.Primary,
            attrs: [],
          )),
        ],
      ),
    ],
  )
}

fn sidebar_component() -> html.Node(t) {
  aside(
    [id("sidebar"), class("sidebar sidebar-closed ")],
    [div([class("w-full")], [h2_text([], "Key Bindings")])],
  )
}

pub fn page(document: Document) -> Node(t) {
  html.Fragment([
    layout.header("Editor"),
    html.Body(
      [class("md:h-screen flex overflow-hidden")],
      [
        sidebar_component(),
        main(
          [class("h-full flex-grow md:flex md:flex-col")],
          [
            header_component(),
            main(
              [class("h-full md:flex md:flex-1 gap-4 md:gap-0")],
              [
                editor_component(document),
                div(
                  [
                    class(
                      "w-full h-1 md:w-1.5 md:h-full md:block bg-stone-800 hover:cursor-col-resize",
                    ),
                    id("editor-divider"),
                  ],
                  [],
                ),
                preview_component(),
              ],
            ),
          ],
        ),
      ],
    ),
  ])
}
