import sqlight

pub type Error {
  MatchError(message: String)
  DatabaseError(sqlight.Error)
  SessionError(message: String)
  CustomDBError(message: String)
}
