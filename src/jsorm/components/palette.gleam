import birl
import jsorm/models/document.{type ListItem}
import jsorm/components/tabler
import gleam/list
import nakai/html.{type Node, button, div, input, p, p_text, span_text}
import nakai/html/attrs.{class, id, name, type_}

pub type Props {
  Props(documents: List(ListItem))
}

pub fn component(props: Props) -> Node(a) {
  let Props(_) = props

  div(
    [class("command-palette hidden"), id("command-palette")],
    [
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
            attrs.placeholder("Search..."),
            attrs.Attr("hx-post", "/documents/search"),
            attrs.Attr("hx-trigger", "input changed delay:250ms, query"),
            attrs.Attr("hx-target", "#documents-list"),
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
        [class("overflow-y-auto pb-10"), id("documents-list")],
        make_documents_list(props.documents, []),
      ),
    ],
  )
}

pub fn make_documents_list(
  items: List(ListItem),
  state: List(Node(_)),
) -> List(Node(_)) {
  case items {
    [doc, ..rest] -> {
      let markup =
        button(
          [
            class("command-palette-item"),
            type_("button"),
            id(doc.id),
            attrs.Attr(
              "onclick",
              "window.location.href = '/editor/" <> doc.id <> "'",
            ),
          ],
          [
            p(
              [],
              [
                case doc.is_public {
                  True -> html.Fragment([])
                  False -> tabler.icon(name: "lock", class: "mr-2 text-base")
                },
                span_text([], doc.description),
              ],
            ),
            p_text(
              [class("text-xs opacity-70")],
              "Last updated " <> {
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
