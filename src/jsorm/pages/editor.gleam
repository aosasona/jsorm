import jsorm/pages/layout
import jsorm/models/document.{type Document}
import jsorm/components/button as btn
import jsorm/components/input
import jsorm/components/tabler
import jsorm/components/palette.{Props as PaletteProps}
import jsorm/components/keybindings.{bindings}
import gleam/option
import nakai/html.{
  type Node, aside, button, div, form, main, nav, section, textarea_text,
}
import nakai/html/attrs.{class, id}

fn editor_component(document: Document) -> Node(t) {
  section(
    [class("w-full h-[50vh] md:h-auto")],
    [
      textarea_text(
        [
          class(
            "h-full w-full text-yellow-400 bg-stone-900 resize-none focus:outline-none p-4 lg:px-6",
          ),
          id("editor"),
          attrs.Attr("data-document-id", document.id),
          attrs.Attr(
            "data-description",
            option.unwrap(document.description, ""),
          ),
        ],
        document.content,
      ),
    ],
  )
}

fn preview_component() -> html.Node(t) {
  section(
    [
      class("w-full h-[50vh] md:h-auto p-4 lg:p-6 pb-6 overflow-y-auto"),
      id("preview"),
    ],
    [],
  )
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
          div(
            [class("flex items-center gap-x-4")],
            [
              button(
                [
                  class("text-yellow-400 text-2xl transition-all"),
                  id("sidebar-toggle"),
                  attrs.Attr("data-status", "closed"),
                ],
                [tabler.icon(name: "layout-sidebar-left-expand", class: "")],
              ),
              button(
                [
                  class("text-yellow-400 text-2xl transition-all lg:hidden"),
                  id("palette-toggle"),
                ],
                [tabler.icon(name: "command", class: "")],
              ),
            ],
          ),
          div(
            [class("flex items-center gap-x-2")],
            [
              btn.component(btn.Props(
                text: "Save",
                class: "",
                render_as: btn.Button,
                variant: btn.Primary,
                attrs: [id("save-document-btn")],
              )),
              btn.component(btn.Props(
                text: "Sign out",
                render_as: btn.Link,
                variant: btn.Ghost,
                attrs: [attrs.href("/sign-out")],
                class: "",
              )),
            ],
          ),
        ],
      ),
    ],
  )
}

fn sidebar_component(document: Document) -> html.Node(t) {
  aside(
    [id("sidebar"), class("sidebar sidebar-closed")],
    [
      div(
        [class("flex flex-col h-full")],
        [
          form(
            [class("px-1 py-3"), id("edit-details-form")],
            // attrs.Attr("onsubmit", ""),
            [
              html.h2_text(
                [class("font-bold text-lg text-yellow-400 mt-1 mb-4")],
                "Edit details",
              ),
              input.component(input.Props(
                id: "document-description",
                name: "title",
                label: "Title",
                variant: input.Text,
                attrs: [
                  attrs.value(
                    document.description
                    |> option.unwrap(or: ""),
                  ),
                ],
              )),
              div(
                [class("flex items-center mt-4")],
                [
                  html.input([
                    attrs.name("is_public"),
                    id("is-public"),
                    class("outline-none focus:outline-yellow-400"),
                    attrs.type_("checkbox"),
                    case document.is_public {
                      True -> attrs.checked()
                      False -> attrs.Attr("", "")
                    },
                  ]),
                  html.label_text(
                    [attrs.for("is-public"), class("ml-2 inline-block")],
                    "Allow public access",
                  ),
                ],
              ),
              btn.component(btn.Props(
                text: "Save",
                render_as: btn.Button,
                variant: btn.Primary,
                class: "w-full mt-6",
                attrs: [attrs.type_("submit")],
              )),
            ],
          ),
          div(
            [class("mt-auto self-start py-3")],
            [
              html.button(
                [
                  attrs.type_("button"),
                  attrs.Attr(
                    "_",
                    "on click toggle .hidden on #keyboard-shortcuts",
                  ),
                ],
                [
                  tabler.icon(
                    name: "keyboard",
                    class: "text-yellow-400 text-2xl transition-all p-2 aspect-square hover:bg-stone-900 rounded-lg",
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  )
}

pub fn page(document: Document, documents: List(document.ListItem)) -> Node(t) {
  html.Fragment([
    layout.header(option.unwrap(document.description, "Editor")),
    html.Body(
      [class("md:h-screen flex overflow-hidden")],
      [
        sidebar_component(document),
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
        div(
          [id("keymaps"), class("hidden")],
          [html.Text(keybindings.as_json(bindings()))],
        ),
        keybindings.component(),
        palette.component(PaletteProps(documents: documents)),
      ],
    ),
  ])
}
