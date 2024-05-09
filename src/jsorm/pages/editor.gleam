import gleam/option
import jsorm/components/button as btn
import jsorm/components/input
import jsorm/components/keybindings.{bindings}
import jsorm/components/palette.{Props as PaletteProps}
import jsorm/components/tabler
import jsorm/models/document.{type Document}
import jsorm/pages/layout
import nakai/attr.{class, id}
import nakai/html.{
  type Node, aside, button, div, form, main, nav, section, textarea_text,
}

fn editor_component(document: Document) -> Node {
  section([class("w-full h-[50vh] md:h-auto")], [
    textarea_text(
      [
        class(
          "h-full w-full text-yellow-400 bg-stone-900 resize-none whitespace-pre-wrap focus:outline-none px-5 pt-4 lg:px-6 pb-16 md:pb-36",
        ),
        id("editor"),
        attr.Attr("data-document-id", document.id),
        attr.Attr("data-description", option.unwrap(document.description, "")),
      ],
      document.content,
    ),
  ])
}

fn preview_component() -> html.Node {
  section(
    [
      class(
        "w-full h-[50vh] md:h-auto px-5 pt-4 lg:px-6 pb-32 md:pb-36 overflow-y-auto border-l border-l-stone-800",
      ),
      id("preview"),
    ],
    [],
  )
}

fn header_component() -> html.Node {
  html.header([], [
    nav(
      [
        class(
          "w-full flex items-center justify-between py-3 px-4 lg:px-6 border-b-2 border-b-stone-800",
        ),
      ],
      [
        div([class("flex items-center gap-x-4")], [
          button(
            [
              class("text-yellow-400 text-2xl transition-all"),
              id("sidebar-toggle"),
              attr.title("Toggle sidebar"),
              attr.Attr("data-status", "closed"),
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
        ]),
        div([class("flex items-center gap-x-2")], [
          btn.component(
            btn.Props(
              text: "Save",
              class: "",
              render_as: btn.Button,
              variant: btn.Primary,
              attrs: [id("save-document-btn")],
            ),
          ),
          btn.component(btn.Props(
            text: "Sign out",
            render_as: btn.Link,
            variant: btn.Ghost,
            attrs: [attr.href("/sign-out")],
            class: "",
          )),
        ]),
      ],
    ),
  ])
}

fn sidebar_component(document: Document) -> html.Node {
  aside([id("sidebar"), class("sidebar sidebar-closed")], [
    div([class("flex flex-col h-full")], [
      form(
        [class("px-1 py-3"), id("edit-details-form"), attr.Attr("onsubmit", "")],
        [
          html.h2_text(
            [class("font-bold text-lg text-yellow-400 mt-1 mb-4")],
            "Edit details",
          ),
          input.component(
            input.Props(
              id: "document-description",
              name: "title",
              label: "Title",
              variant: input.Text,
              attrs: [
                attr.value(
                  document.description
                  |> option.unwrap(or: ""),
                ),
              ],
            ),
          ),
          div([class("flex items-center mt-4")], [
            html.input([
              attr.name("is_public"),
              id("is-public"),
              class("outline-none focus:outline-yellow-400"),
              attr.type_("checkbox"),
              case document.is_public {
                True -> attr.checked()
                False -> attr.Attr("", "")
              },
            ]),
            html.label_text(
              [attr.for("is-public"), class("ml-2 inline-block")],
              "Allow public access",
            ),
          ]),
          btn.component(
            btn.Props(
              text: "Save",
              render_as: btn.Button,
              variant: btn.Primary,
              class: "w-full mt-6",
              attrs: [attr.type_("submit")],
            ),
          ),
        ],
      ),
      div([class("mt-auto self-start flex items-center gap-x-2 py-3")], [
        html.button(
          [
            attr.title("Keyboard shortcuts"),
            attr.type_("button"),
            attr.Attr("_", "on click toggle .hidden on #keyboard-shortcuts"),
          ],
          [
            tabler.icon(
              name: "keyboard",
              class: "text-yellow-400 text-2xl transition-all p-2 aspect-square hover:bg-stone-900 rounded-lg",
            ),
          ],
        ),
        html.a(
          [
            attr.href("/editor"),
            attr.title("Create new document"),
            class(
              "text-yellow-400 text-xl transition-all p-2 aspect-square hover:bg-stone-900 rounded-lg",
            ),
          ],
          [tabler.icon(name: "plus", class: "")],
        ),
      ]),
    ]),
  ])
}

pub fn page(document: Document, documents: List(document.ListItem)) -> Node {
  html.Fragment([
    layout.header(option.unwrap(document.description, "Editor")),
    html.Body([class("md:h-screen flex overflow-hidden")], [
      sidebar_component(document),
      main([class("h-full w-full flex-grow md:flex md:flex-col")], [
        header_component(),
        main(
          [
            class(
              "h-full w-full grid grid-cols-2 md:grid-cols-2 gap-4 md:gap-0",
            ),
          ],
          [editor_component(document), preview_component()],
        ),
      ]),
      div([id("keymaps"), class("hidden")], [
        html.Text(keybindings.as_json(bindings())),
      ]),
      keybindings.component(),
      palette.component(PaletteProps(documents: documents)),
    ]),
  ])
}
