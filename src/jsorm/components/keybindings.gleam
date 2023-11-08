import gleam/json
import nakai/html

const ctrl = "Ctrl"

const alt = "Alt"

const shift = "Shift"

const meta = "Meta"

const enter = "Enter"

pub type Binding {
  Binding(description: String, combos: List(#(String, String)), action: String)
}

pub fn bindings() -> List(Binding) {
  [
    Binding(
      description: "Update preview without saving",
      combos: [#(ctrl, enter), #(meta, enter)],
      action: "update-preview",
    ),
    Binding(
      description: "Save document and update preview",
      combos: [#(ctrl, "s"), #(meta, "s")],
      action: "save-document",
    ),
    Binding(
      description: "Toggle left sidebar",
      combos: [#(ctrl, "k"), #(meta, "k")],
      action: "toggle-left-sidebar",
    ),
  ]
}

pub fn as_string(bindings: List(Binding)) -> String {
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

pub fn component() -> html.Node(t) {
  todo
}
