///|
pub(all) struct EdnTupleView {
  tag : Edn
  extra : Array[Edn]
} derive(Eq)

///|
pub fn EdnTupleView::new(tag : Edn, extra : Array[Edn]) -> EdnTupleView {
  { tag, extra }
}

///|
pub impl Hash for EdnTupleView with hash(self) {
  self.extra.length() + 1
}

///|
pub impl Hash for EdnTupleView with hash_combine(self, hasher) {
  self.tag.hash_combine(hasher)
  for i in self.extra {
    i.hash_combine(hasher)
  }
}

///|
pub impl Show for EdnTupleView with output(self, logger) {
  let mut s = ""
  s = s + "(tuple"
  s = s + self.tag.to_string()
  for i in self.extra {
    s = s + " " + i.to_string()
  }
  s = s + ")"
  logger.write_string(s)
}

///|
pub impl Compare for EdnTupleView with compare(self, right) -> Int {
  let ret = self.tag.compare(right.tag)
  if ret != 0 {
    return ret
  }
  for i in self.extra {
    for j in right.extra {
      let ret = i.compare(j)
      if ret != 0 {
        return ret
      }
    }
  }
  0
}
