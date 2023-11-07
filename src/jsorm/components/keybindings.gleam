import gleam/json
import nakai/html

pub type Binding {
  Binding(name: String, hotkeys: List(#(String, String)))
}

pub fn bindings() -> List(Binding) {
  todo
}

pub fn component() -> html.Node(t) {
  todo
}
