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

const shared_class = "disabled:opacity-50 disabled:cursor-not-allowed py-2 px-5 select-none"

pub fn component(props: Props(t)) -> html.Node(t) {
  let class =
    case props.variant {
      Primary ->
        "bg-yellow-400 hover:bg-yellow-500 text-stone-900 font-bold rounded-md"
      Ghost ->
        "bg-transparent hover:bg-yellow-400/20 text-yellow-400 hover:text-yelow-400 font-bold rounded-md"
    } <> " " <> shared_class

  let el = case props.render_as {
    Button -> html.button_text
    Link -> html.a_text
  }

  el([attrs.class(class <> " " <> props.class), ..props.attrs], props.text)
}
