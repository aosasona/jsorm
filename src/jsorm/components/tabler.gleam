import gleam/string
import nakai/attr as attrs
import nakai/html.{type Node}

pub fn icon(name icon_name: String, class class: String) -> Node {
  let c =
    { "ti ti-" <> icon_name <> " " <> class }
    |> string.trim

  html.i_text([attrs.class(c)], "")
}
