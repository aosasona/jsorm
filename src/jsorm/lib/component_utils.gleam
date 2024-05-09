import gleam/list
import nakai/attr as attrs

pub fn extract_class(attrs: List(attrs.Attr)) -> #(String, List(attrs.Attr)) {
  let extra_classes = case list.find(attrs, fn(attr) { attr.name == "class" }) {
    Ok(attr) ->
      case attr {
        attrs.Attr(_, value) -> value
      }
    Error(_) -> ""
  }

  let attrs = list.filter(attrs, fn(attr) { attr.name != "class" })

  #(extra_classes, attrs)
}
