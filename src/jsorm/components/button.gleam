import nakai/html
import nakai/html/attrs

pub type Variant {
  Primary
  Ghost
}

pub type As {
  Button
  Link
}

pub type Props(a) {
  Props
}

pub fn component(
  label label: String,
  variant variant: Variant,
  render_as render_as: As,
  attrs attributes: List(attrs.Attr(t)),
) -> html.Node(t) {
  let class = case variant {
    Primary ->
      "bg-yellow-400 hover:bg-yellow-500 text-stone-900 font-bold py-2 px-5 rounded-md hover:scale-95 transiton-all"
    Ghost ->
      "bg-transparent hover:bg-yellow-400 text-yellow-400 font-bold py-2 px-5 rounded-md hover:scale-95 transiton-all"
  }

  let el = case render_as {
    Button -> html.button_text
    Link -> html.a_text
  }

  el([attrs.class(class), ..attributes], label)
}
