pub struct EdnTupleView {
  tag : Edn
  extra : Array[Edn]
} derive(Eq)

impl Hash for EdnTupleView with hash(self) { self.extra.length() + 1 }

impl Hash for EdnTupleView with hash_combine(self, hasher) {
  self.tag.hash_combine(hasher)
  for i in self.extra {
    i.hash_combine(hasher)
  }
}

pub fn to_string(self : EdnTupleView) -> String {
  let mut s = ""
  s = s + "(tuple"
  s = s + self.tag.to_string()
  for i in self.extra {
    s = s + " " + i.to_string()
  }
  s = s + ")"
  s
}
