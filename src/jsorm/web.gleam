import sqlight
import plunk
import nakai
import nakai/html.{Node}
import wisp

pub type Context {
  Context(
    secret: String,
    db: sqlight.Connection,
    plunk: plunk.Instance,
    dist_directory: String,
  )
}

pub fn render(page: Node(t), code: Int) {
  page
  |> nakai.to_string_builder
  |> wisp.html_response(code)
}
