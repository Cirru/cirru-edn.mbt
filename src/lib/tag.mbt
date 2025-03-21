///|
pub type EdnTag String derive(Eq, Hash)

///|
pub impl Show for EdnTag with output(self, logger) {
  logger.write_string(self._)
}

///|
pub fn EdnTag::new(s : String) -> EdnTag {
  EdnTag(s)
}

///|
pub fn EdnTag::str(self : EdnTag) -> String {
  self._
}

///|
pub impl Compare for EdnTag with compare(self : EdnTag, other : EdnTag) -> Int {
  self._.compare(other._)
}
