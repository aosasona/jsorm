import nakai/attr as attrs
import nakai/html.{type Node}

pub type Props {
  Props(href: String, new_tab: Bool)
}

pub fn component(text: String, props: Props) -> Node {
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
