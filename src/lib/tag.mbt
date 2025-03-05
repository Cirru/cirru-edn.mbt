///|
type EdnTag String derive(Eq, Hash)

///|
fn EdnTag::to_string(self : EdnTag) -> String {
  self._
}

///|
impl Show for EdnTag with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
fn EdnTag::new(s : String) -> EdnTag {
  EdnTag(s)
}

///|
fn str(self : EdnTag) -> String {
  self._
}

///|
pub fn EdnTag::compare(self : EdnTag, other : EdnTag) -> Int {
  self._.compare(other._)
}
