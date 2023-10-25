import gleam/list
import nakai/html/attrs

pub fn extract_class(
  attrs: List(attrs.Attr(a)),
) -> #(String, List(attrs.Attr(a))) {
  let extra_classes = case list.find(attrs, fn(attr) { attr.name == "class" }) {
    Ok(attr) ->
      case attr {
        attrs.Attr(_, value) -> value
        attrs.Event(_, _) -> ""
      }
    Error(_) -> ""
  }

  let attrs = list.filter(attrs, fn(attr) { attr.name != "class" })

  #(extra_classes, attrs)
}
