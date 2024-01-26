import jsorm/components/tabler
import nakai/html.{type Node}
import nakai/html/attrs.{class}

pub type Status {
  Success
  Warning
  Failure
}

pub type Props {
  Props(message: String, status: Status, class: String)
}

pub fn component(props: Props) -> Node(t) {
  let icon = case props.status {
    Success -> "circle-check"
    Warning -> "alert-triangle"
    Failure -> "exclamation-circle"
  }

  let bg = case props.status {
    Success -> "bg-green-500"
    Warning -> "bg-yellow-500"
    Failure -> "bg-red-500"
  }

  let text_color = case props.status {
    Success -> "text-white"
    Warning -> "text-stone-900"
    Failure -> "text-white"
  }

  html.div(
    [
      class(
        bg <> " flex items-center gap-2.5 px-3 py-2 rounded-md " <> props.class,
      ),
    ],
    [
      tabler.icon(name: icon, class: "text-2xl " <> text_color),
      html.p_text([class(text_color <> " text-sm")], props.message),
    ],
  )
}
