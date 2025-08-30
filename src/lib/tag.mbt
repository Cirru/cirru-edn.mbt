///|
pub struct EdnTag(String) derive(Eq, Hash)

///|
pub impl Show for EdnTag with output(self, logger) {
  logger.write_string(self.inner())
}

///|
pub fn EdnTag::new(s : String) -> EdnTag {
  EdnTag(s)
}

///|
pub fn EdnTag::str(self : EdnTag) -> String {
  self.inner()
}

///|
pub impl Compare for EdnTag with compare(self : EdnTag, other : EdnTag) -> Int {
  self.inner().compare(other.inner())
}
