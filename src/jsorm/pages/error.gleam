import nakai/html
import nakai/html/attrs
import jsorm/pages/layout

fn get_message(code: Int) -> String {
  case code {
    404 -> "Page not found"
    _ -> "Oof, something went wrong"
  }
}

fn get_subtext(code: Int) -> String {
  case code {
    404 -> "The page you're looking for doesn't exist"
    _ -> "Please try again later or contact us if the problem persists"
  }
}

pub fn page(code: Int) -> html.Node(t) {
  let message = get_message(code)

  html.div(
    [attrs.class("min-h-screen flex flex-col items-center justify-center")],
    [
      html.h1_text([attrs.class("text-4xl font-bold mb-3")], get_message(code)),
      html.p_text([attrs.class("text-base text-stone-500")], get_subtext(code)),
    ],
  )
  |> layout.render(message)
}
