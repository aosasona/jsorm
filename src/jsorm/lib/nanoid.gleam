import glanoid

pub fn generate() -> String {
  let assert Ok(nanoid) = glanoid.make_generator(glanoid.default_alphabet)
  nanoid(18)
}
