import gleam/string
import nakai/html.{type Node}
import nakai/html/attrs

pub fn icon(name icon_name: String, class class: String) -> Node(a) {
  let c =
    { "ti ti-" <> icon_name <> " " <> class }
    |> string.trim

  html.i_text([attrs.class(c)], "")
}
