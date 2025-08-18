//

///|
pub struct EdnSetView(@hashset.T[Edn])

///| implement Eq for EdnSetView,
/// TODO: this is not efficient, we should implement a more efficient way to compare two sets
pub impl Eq for EdnSetView with op_equal(self : EdnSetView, other : EdnSetView) -> Bool {
  let mut equal = true
  self.inner().each(fn(x) {
    if not(other.inner().contains(x)) {
      equal = false
    }
  })
  if not(equal) {
    return false
  }
  other.inner().each(fn(x) {
    if not(self.inner().contains(x)) {
      equal = false
    }
  })
  equal
}

///|
impl Show for EdnSetView with output(self, logger) {
  let mut s = ""
  s = s + "(set"
  for i in self.inner() {
    s = s + " " + i.to_string()
  }
  s = s + ")"
  logger.write_string(s)
}

///|
pub impl Hash for EdnSetView with hash(self) {
  self.inner().size()
}

///|
pub impl Hash for EdnSetView with hash_combine(self, hasher) {
  self.inner().each(fn(x) { x.hash_combine(hasher) })
}

///|
pub fn EdnSetView::contains(self : EdnSetView, x : Edn) -> Bool {
  self.inner().contains(x)
}

///|
pub fn EdnSetView::add(self : EdnSetView, x : Edn) -> Unit {
  self.inner().add(x)
}

///|
pub fn EdnSetView::length(self : EdnSetView) -> UInt {
  self.inner().size().reinterpret_as_uint()
}

///|
pub fn EdnSetView::is_empty(self : EdnSetView) -> Bool {
  self.inner().is_empty()
}

///|
pub impl Compare for EdnSetView with compare(self, right) -> Int {
  if self.inner().size() < right.inner().size() {
    return -1
  }
  if self.inner().size() > right.inner().size() {
    return 1
  }
  // TODO does not compare the order of set elements since set is unordered
  0
}
