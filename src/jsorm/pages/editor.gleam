import jsorm/pages/layout.{header}
import jsorm/models/document.{Document}
import jsorm/components/button
import jsorm/components/tabler
import nakai/html.{Node}
import nakai/html/attrs.{class, id}

const section_class = "h-[50dvh] lg:h-full w-full bg-stone-800 p-3 "

fn editor_component(document: Document) -> Node(t) {
  html.div(
    [class("w-full h-full")],
    [
      html.textarea_text(
        [
          class(
            section_class <> "text-yellow-400 resize-none focus:outline-none",
          ),
          id("editor"),
        ],
        document.content,
      ),
    ],
  )
}

fn preview_component() -> Node(t) {
  html.div([class(section_class), id("preview")], [])
}

pub fn page(document: Document) -> Node(t) {
  html.Fragment([
    header("Editor"),
    html.Body(
      [],
      [
        html.nav(
          [
            class(
              "w-full flex items-center justify-between bg-stone-800 py-3 px-4 lg:px-6 border-b-2 border-b-stone-700",
            ),
          ],
          [
            html.button(
              [
                class("text-yellow-400 text-2xl lg:text-3xl"),
                id("sidebar-toggle"),
              ],
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
        html.main(
          [class("lg:h-screen lg:flex lg:flex-row gap-4 lg:gap-0")],
          [
            editor_component(document),
            html.div([class("h-full w-1.5 bg-stone-700")], []),
            preview_component(),
          ],
        ),
      ],
    ),
  ])
}
