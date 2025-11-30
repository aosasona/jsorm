import gleam/bool
import gleam/int
import gleam/json.{type Json, array, null, string}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/regexp
import gleam/string

// This is all primarily for string fields, but we could extend it to other types later
pub type Rule {
  Email
  Filename
  NotEqualTo(name: String, value: String)
  EqualTo(name: String, value: String)
  MinLength(Int)
  MaxLength(Int)
  Numeric
  Required
  Regex(regex: String, error: String)
}

// TODO: make this a StringField to enable other forms of validation later
pub type Field {
  Field(name: String, value: String, rules: List(Rule))
  NullableField(name: String, value: Option(String), rules: List(Rule))
}

pub type MatchResult {
  Failed(reason: String)
  Passed
}

pub type FieldError {
  FieldError(name: String, errors: List(String))
  NoFieldError
}

pub fn to_object(errors: List(FieldError)) -> List(#(String, Json)) {
  errors
  |> list.map(fn(error) {
    case error {
      FieldError(name, errors) -> #(name, array(from: errors, of: string))
      NoFieldError -> #("", null())
    }
  })
}

// Validate a list of fields
pub fn validate_many(fields: List(Field)) -> List(FieldError) {
  fields
  |> list.map(fn(field) {
    let result = case field {
      Field(_, value, rules) -> validate_field(value, rules)
      NullableField(_, value, rules) ->
        case value {
          Some(value) -> validate_field(value, rules)
          None -> #(False, [])
        }
    }

    result
    |> fn(result) {
      case result {
        #(True, errors) -> FieldError(name: field.name, errors: errors)
        #(False, _) -> NoFieldError
      }
    }
  })
  |> list.filter(fn(result) { result != NoFieldError })
}

// Validate a list of rules on a field
pub fn validate_field(
  value value: String,
  rules rules: List(Rule),
) -> #(Bool, List(String)) {
  rules
  |> list.map(fn(rule) { match(value: value, rule: rule) })
  |> list.filter(fn(error) { error != Passed })
  |> list.map(fn(error) {
    case error {
      Failed(reason) -> reason
      Passed -> ""
    }
  })
  |> fn(errors) {
    use <- bool.guard(when: errors != [], return: #(True, errors))
    #(False, [])
  }
}

// Validate a single rule on a field
fn match(value value: String, rule rule: Rule) -> MatchResult {
  case rule {
    Email -> email(value)
    Filename ->
      regex(
        "^[a-zA-Z0-9-_\\.]+$",
        value,
        "must be a valid filename (a-z, 0-9, -, _, .)",
      )
    EqualTo(name, to) -> equal_to(name, value, to)
    NotEqualTo(name, to) -> not_equal_to(name, value, to)
    MinLength(min) -> min_length(value, min)
    MaxLength(max) -> max_length(value, max)
    Numeric -> regex("^([0-9]+)$", value, "must be numeric (0-9)")
    Required -> required(value)
    Regex(r, error) -> regex(r, value, error)
  }
}

fn not_equal_to(name: String, value: String, other: String) -> MatchResult {
  case string.compare(value, other) {
    order.Eq -> Failed("must not match `" <> name <> "` field")
    _ -> Passed
  }
}

fn regex(re: String, value: String, error: String) -> MatchResult {
  let valid = case regexp.from_string(re) {
    Ok(re) -> regexp.check(with: re, content: value)
    Error(_) -> False
  }

  case valid {
    True -> Passed
    False -> Failed(error)
  }
}

fn equal_to(name: String, value: String, other: String) -> MatchResult {
  case string.compare(value, other) {
    order.Eq -> Passed
    _ -> Failed("must match `" <> name <> "` field")
  }
}

fn required(value: String) -> MatchResult {
  case value {
    value if value == "" -> Failed("is required")
    _ -> Passed
  }
}

fn min_length(value: String, min: Int) -> MatchResult {
  case string.length(value) < min {
    True -> Failed("must be at least " <> int.to_string(min) <> " characters")
    _ -> Passed
  }
}

fn max_length(value: String, max: Int) -> MatchResult {
  case string.length(value) > max {
    True -> Failed("must be at most " <> int.to_string(max) <> " characters")
    _ -> Passed
  }
}

fn email(value: String) -> MatchResult {
  let valid = case
    regexp.from_string("^([a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})$")
  {
    Ok(re) -> regexp.check(with: re, content: value)
    Error(_) -> False
  }

  case valid {
    True -> Passed
    False -> Failed("must be a valid email address")
  }
}
