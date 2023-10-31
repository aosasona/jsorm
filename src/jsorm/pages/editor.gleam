import jsorm/pages/layout.{header}
import jsorm/models/document.{Document}
import jsorm/components/button
import jsorm/components/tabler
import nakai/html.{Node}
import nakai/html/attrs.{class, id}

fn editor_component(document: Document) -> Node(t) {
  html.div(
    [class("w-full h-[50vh] md:h-auto")],
    [
      html.textarea_text(
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

fn preview_component() -> Node(t) {
  html.div([class("w-full h-[50vh] md:h-auto p-4"), id("preview")], [])
}

pub fn page(document: Document) -> Node(t) {
  html.Fragment([
    header("Editor"),
    html.Body(
      [class("md:h-screen md:flex md:flex-col overflow-hidden")],
      [
        html.header(
          [],
          [
            html.nav(
              [
                class(
                  "w-full flex items-center justify-between py-3 px-4 lg:px-6 border-b-2 border-b-stone-800",
                ),
              ],
              [
                html.button(
                  [class("text-yellow-400 text-2xl"), id("sidebar-toggle")],
                  [tabler.icon(name: "layout-sidebar-left-expand", class: "")],
                ),
                button.component(button.Props(
                  text: "Save",
                  class: "",
                  render_as: button.Button,
                  variant: button.Primary,
                  attrs: [],
                )),
              ],
            ),
          ],
        ),
        html.main(
          [class("h-full md:flex md:flex-1 gap-4 md:gap-0")],
          [
            editor_component(document),
            html.div(
              [
                class(
                  "w-1.5 hidden md:block bg-stone-800 hover:cursor-col-resize",
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
  ])
}
