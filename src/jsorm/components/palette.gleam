import birl
import gleam/list
import jsorm/components/tabler
import jsorm/models/document.{type ListItem}
import nakai/attr.{class, id, name, type_}
import nakai/html.{type Node, button, div, input, p, p_text, span_text}

pub type Props {
  Props(documents: List(ListItem), username: String)
}

pub fn component(props: Props) -> Node {
  div([class("command-palette hidden"), id("command-palette")], [
    div(
      [
        class(
          "w-full flex items-center bg-stone-900 border-b border-b-stone-800 gap-x-2",
        ),
      ],
      [
        input([
          type_("search"),
          name("query"),
          class(
            "flex-1 bg-stone-900 text-base text-stone-200 placeholder-stone-500 outline-none focus:outline-none px-5 py-3.5",
          ),
          attr.placeholder("Search..."),
          attr.Attr("hx-post", "/documents/search"),
          attr.Attr("hx-trigger", "input changed delay:250ms, query"),
          attr.Attr("hx-target", "#documents-list"),
        ]),
        button(
          [
            class(
              "w-14 text-yellow-400 text-2xl transition-all lg:hidden aspect-square",
            ),
            id("palette-toggle-inner"),
          ],
          [tabler.icon(name: "x", class: "")],
        ),
      ],
    ),
    div(
      [class("h-full overflow-y-auto"), id("documents-list")],
      make_documents_list(props.documents, []),
    ),
    // Signed in indicator
    div(
      [
        class(
          "w-full border-t border-t-stone-800 flex gap-2 items-center justify-center py-2.5 px-4",
        ),
      ],
      [
        div([class("bg-green-400 w-2.5 aspect-square rounded-full")], []),
        p([class("text-xs text-stone-500")], [
          span_text([], "Signed in as "),
          span_text([class("font-bold text-yellow-400")], props.username),
        ]),
      ],
    ),
  ])
}

pub fn make_documents_list(
  items: List(ListItem),
  state: List(Node),
) -> List(Node) {
  case items {
    [doc, ..rest] -> {
      let markup =
        button(
          [
            class("command-palette-item"),
            type_("button"),
            id(doc.id),
            attr.Attr(
              "onclick",
              "window.location.href = '/editor/" <> doc.id <> "'",
            ),
          ],
          [
            p([], [
              case doc.is_public {
                True -> html.Fragment([])
                False -> tabler.icon(name: "lock", class: "mr-2 text-base")
              },
              span_text([], doc.description),
            ]),
            p_text(
              [class("text-xs opacity-70")],
              "Last updated "
                <> {
                doc.last_updated_at
                |> birl.from_unix
                |> birl.legible_difference(birl.now(), _)
              },
            ),
          ],
        )

      make_documents_list(rest, list.concat([state, [markup]]))
    }
    [] -> state
  }
}
