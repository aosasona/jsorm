import nakai/html.{Node}
import nakai/html/attrs.{class}

pub type Status {
  Success
  Warning
  Failure
}

pub type Props {
  Props(message: String, status: Status)
}

pub fn component() -> Node(t) {
  todo
}
