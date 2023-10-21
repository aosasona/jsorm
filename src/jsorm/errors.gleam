import sqlight

pub type Error {
  DatabaseError(sqlight.Error)
}
