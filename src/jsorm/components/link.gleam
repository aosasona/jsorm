import nakai/html.{type Node}
import nakai/html/attrs

pub type Props {
  Props(href: String, new_tab: Bool)
}

pub fn component(text: String, props: Props) -> Node(t) {
  let target_attrs = case props.new_tab {
    True -> [attrs.rel("noopener noreferrer"), attrs.target("_blank")]
    False -> []
  }
  html.a_text(
    [
      attrs.href(props.href),
      attrs.class("underline text-yellow-400"),
      ..target_attrs
    ],
    text,
  )
}
