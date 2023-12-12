import gleam/json
import gleam/list
import jsorm/components/tabler
import nakai/html.{type Node, div, h1_text}
import nakai/html/attrs.{class, id}

const ctrl = "Ctrl"

const alt = "Alt"

//
// const shift = "Shift"

const meta = "Meta"

const enter = "Enter"

pub type Binding {
  Binding(description: String, combos: List(#(String, String)), action: String)
}

pub fn bindings() -> List(Binding) {
  [
    Binding(
      description: "New document",
      combos: [#(ctrl, "n")],
      action: "new-document",
    ),
    Binding(
      description: "Save document and update preview",
      combos: [#(ctrl, "s"), #(meta, "s")],
      action: "save-document",
    ),
    Binding(
      description: "Update preview without saving",
      combos: [#(ctrl, enter), #(meta, enter)],
      action: "update-preview",
    ),
    Binding(
      description: "Toggle command palette",
      combos: [#(ctrl, "k"), #(meta, "k")],
      action: "toggle-command-palette",
    ),
    Binding(
      description: "Toggle left sidebar",
      combos: [#(ctrl, "h"), #(meta, "h")],
      action: "toggle-left-sidebar",
    ),
  ]
}

pub fn as_json(bindings: List(Binding)) -> String {
  json.array(
    from: bindings,
    of: fn(binding) {
      json.object([
        #("description", json.string(binding.description)),
        #(
          "combos",
          json.array(
            from: binding.combos,
            of: fn(combo) {
              json.array(from: [combo.0, combo.1], of: json.string)
            },
          ),
        ),
        #("action", json.string(binding.action)),
      ])
    },
  )
  |> json.to_string
}

fn combos_to_markup(
  combos: List(#(String, String)),
  state: List(Node(a)),
) -> Node(a) {
  case combos {
    [#(leader, secondary), ..rest] -> {
      let primary = case leader {
        "Meta" -> tabler.icon(name: "command", class: "")
        _ -> html.Text(leader)
      }

      combos_to_markup(
        rest,
        list.append(
          state,
          [
            div(
              [
                class(
                  "bg-stone-800 text-stone-200 px-2 py-1 rounded inline-block",
                ),
              ],
              [html.p([], [primary, html.Text(" + "), html.Text(secondary)])],
            ),
          ],
        ),
      )
    }
    [] -> div([class("flex items-center gap-2")], state)
  }
}

fn make_list(bindings: List(Binding), state: List(Node(t))) -> List(Node(t)) {
  case bindings {
    [binding, ..others] -> {
      let item =
        div(
          [],
          [
            html.h3_text([class("mb-1")], binding.description),
            div([], [combos_to_markup(binding.combos, [])]),
          ],
        )

      let state = list.append(state, [item])
      make_list(others, state)
    }
    [] -> state
  }
}

pub fn component() -> html.Node(t) {
  div(
    [
      class(
        "md:w-[325px] fixed bottom-5 right-5 bg-yellow-400 text-stone-900 px-4 pt-3 pb-4 z-[99999] rounded-lg drop-shadow-lg select-none hidden",
      ),
      attrs.Attr(
        "_",
        "on load if localStorage.hasSeenKBList is null then remove .hidden from me",
      ),
      id("keyboard-shortcuts"),
    ],
    [
      div(
        [class("flex items-center justify-between pb-2.5")],
        [
          h1_text([class("text-lg font-bold")], "Keyboard shortcuts"),
          html.button(
            [
              attrs.Attr(
                "_",
                "on click set localStorage.hasSeenKBList to false then toggle .hidden on #keyboard-shortcuts",
              ),
            ],
            [tabler.icon(name: "x", class: "text-xl")],
          ),
        ],
      ),
      div(
        [class("max-h-[60vh] overflow-y-auto flex flex-col gap-y-3")],
        make_list(bindings(), []),
      ),
    ],
  )
}
