///|
pub struct EdnTag(String) derive(Eq, Hash)

///|
pub impl Show for EdnTag with output(self, logger) {
  logger.write_string(self.0)
}

///|
pub fn EdnTag::new(s : String) -> EdnTag {
  EdnTag(s)
}

///|
pub fn EdnTag::str(self : EdnTag) -> String {
  self.0
}

///|
pub impl Compare for EdnTag with compare(self : EdnTag, other : EdnTag) -> Int {
  self.0.compare(other.0)
}
