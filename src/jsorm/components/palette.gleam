import jsorm/models/document.{type ListItem}
import nakai/html.{type Node, div, input}
import nakai/html/attrs.{class, id}

pub type Props {
  Props(documents: List(ListItem))
}

pub fn component(props: Props) -> Node(a) {
  let Props(_) = props

  div(
    [class("command-palette hidden"), id("command-palette")],
    [
      input([
        class(
          "w-full bg-stone-900 border-b border-b-stone-800 text-lg text-stone-200 placeholder-stone-500 outline-none focus:outline-none px-5 py-3.5",
        ),
        attrs.placeholder("Search..."),
      ]),
    ],
  )
}
