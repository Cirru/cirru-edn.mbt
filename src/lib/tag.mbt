type EdnTag String derive(Eq, Hash)

fn to_string(self : EdnTag) -> String {
  self.to_string()
}

fn EdnTag::new(s : String) -> EdnTag {
  EdnTag(s)
}

fn str(self : EdnTag) -> String {
  self._
}
