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
  Props(
    text: String,
    variant: Variant,
    render_as: As,
    class: String,
    attrs: List(attrs.Attr(a)),
  )
}

pub fn component(props: Props(t)) -> html.Node(t) {
  let class = case props.variant {
    Primary ->
      "bg-yellow-400 hover:bg-yellow-500 text-stone-900 font-bold py-2.5 px-5 rounded-md hover:scale-95"
    Ghost ->
      "bg-transparent hover:bg-yellow-400 text-yellow-400 font-bold py-2.5 px-5 rounded-md hover:scale-95"
  }

  let el = case props.render_as {
    Button -> html.button_text
    Link -> html.a_text
  }

  el([attrs.class(class <> " " <> props.class), ..props.attrs], props.text)
}
