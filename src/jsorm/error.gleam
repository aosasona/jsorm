import sqlight

pub type Error {
  CustomDBError(message: String)
  DatabaseError(sqlight.Error)
  MatchError(message: String)
  NotFoundError
  SessionError(message: String)
}
