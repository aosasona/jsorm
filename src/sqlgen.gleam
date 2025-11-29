// original: https://github.com/gleam-lang/packages/blob/main/test/codegen.gleam
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let Nil = generate_sql_queries_module()
}

const module_header = "// THIS FILE IS GENERATED. DO NOT EDIT.
// Regenerate with `gleam run -m sqlgen`"

fn generate_sql_queries_module() -> Nil {
  let module_path = "src/jsorm/generated/sql.gleam"
  let assert Ok(files) = simplifile.read_directory("sql")
  let assert Ok(functions) = list.try_map(files, generate_sql_function)

  let imports = [
    "import sqlight", "import gleam/result", "import gleam/dynamic/decode",
    "import jsorm/error.{type Error}",
  ]
  let module =
    string.join(
      [
        module_header,
        string.join(imports, "\n"),
        "pub type QueryResult(t) =\n  Result(List(t), Error)",
        ..functions
      ],
      "\n\n",
    )
  let assert Ok(_) = simplifile.write(to: module_path, contents: module <> "\n")
  Nil
}

fn generate_sql_function(file: String) -> Result(String, _) {
  let name = string.replace(file, ".sql", "")
  use contents <- result.try(simplifile.read("sql/" <> file))
  let escaped =
    contents
    |> string.replace("\\", "\\\\")
    |> string.replace("\"", "\\\"")
  let lines = [
    "pub fn " <> name <> "(",
    "  db: sqlight.Connection,",
    "  args arguments: List(sqlight.Value),",
    "  decoder decoder: decode.Decoder(a),",
    ") -> QueryResult(a) {",
    "  let query =",
    "    \"" <> escaped <> "\"",
    "  sqlight.query(query, db, arguments, decoder)",
    "  |> result.map_error(error.DatabaseError)",
    "}",
  ]
  let function = string.join(lines, "\n")
  Ok(function)
}
