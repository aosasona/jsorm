import nakai/html
import nakai/html/attrs
import gleam/list

pub type Variant {
  Text
  Email
}

pub type Props(a) {
  Props(
    id: String,
    label: String,
    name: String,
    variant: Variant,
    attrs: List(attrs.Attr(a)),
  )
}

fn get_classes(variant: Variant) -> String {
  case variant {
    Text | Email ->
      "w-full bg-stone-800 px-3 py-2 border border-stone-700 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-yellow-400 focus:border-yellow-400 text-sm text-stone-300 placeholder-stone-600"
  }
}

pub fn component(props: Props(t)) -> html.Node(t) {
  html.div(
    [],
    [
      html.label(
        [
          attrs.for(props.name),
          attrs.class("text-sm text-stone-400 block mb-2"),
        ],
        [html.Text(props.label)],
      ),
      html.input(list.concat([
        props.attrs,
        [
          attrs.id(props.id),
          attrs.name(props.name),
          attrs.type_(case props.variant {
            Text -> "text"
            Email -> "email"
          }),
          attrs.class(get_classes(props.variant)),
        ],
      ])),
    ],
  )
}
