import gleam/list
import jsorm/lib/component_utils
import nakai/attr as attrs
import nakai/html

pub type Variant {
  Hidden
  Text
  Email
}

pub type Props(a) {
  Props(
    id: String,
    label: String,
    name: String,
    variant: Variant,
    attrs: List(attrs.Attr),
  )
}

const general_class = "disabled:opacity-40 disabled:cursor-not-allowed disabled:select-none disabled:focus:ring-stone-600 disabled:focus:outline-none"

fn get_classes(variant: Variant) -> String {
  case variant {
    Text | Email ->
      "block w-full bg-stone-800 px-3 py-2.5 rounded-md border-0 text-stone-100 shadow-sm outline-none focus:outline-none ring-1 ring-inset ring-stone-700 placeholder:text-stone-600 focus:ring-2 focus:ring-inset focus:ring-yellow-400 sm:text-sm sm:leading-6"
    Hidden -> ""
  }
  <> " "
  <> general_class
}

pub fn component(props: Props(t)) -> html.Node {
  let #(extra_classes, attrs) = component_utils.extract_class(props.attrs)

  html.div(
    [
      attrs.class(case props.variant {
        Hidden -> "hidden"
        _ -> ""
      }),
    ],
    [
      html.label(
        [attrs.for(props.name), attrs.class("text-sm text-stone-400 block")],
        [html.Text(props.label)],
      ),
      html.div([attrs.class("mt-2")], [
        html.input(
          list.concat([
            attrs,
            [
              attrs.id(props.id),
              attrs.name(props.name),
              attrs.type_(case props.variant {
                Text -> "text"
                Email -> "email"
                Hidden -> "hidden"
              }),
              attrs.class(get_classes(props.variant) <> " " <> extra_classes),
            ],
          ]),
        ),
      ]),
    ],
  )
}
