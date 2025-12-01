//

///|
pub struct EdnSetView(@hashset.HashSet[Edn])

///|
/// implement Eq for EdnSetView,
/// TODO: this is not efficient, we should implement a more efficient way to compare two sets
pub impl Eq for EdnSetView with equal(self : EdnSetView, other : EdnSetView) -> Bool {
  let mut equal = true
  self.0.each(fn(x) { if not(other.0.contains(x)) { equal = false } })
  if not(equal) {
    return false
  }
  other.0.each(fn(x) { if not(self.0.contains(x)) { equal = false } })
  equal
}

///|
impl Show for EdnSetView with output(self, logger) {
  let mut s = ""
  s = s + "(set"
  for i in self.0 {
    s = s + " " + i.to_string()
  }
  s = s + ")"
  logger.write_string(s)
}

///|
pub impl Hash for EdnSetView with hash(self) {
  self.0.length()
}

///|
pub impl Hash for EdnSetView with hash_combine(self, hasher) {
  self.0.each(fn(x) { x.hash_combine(hasher) })
}

///|
pub fn EdnSetView::contains(self : EdnSetView, x : Edn) -> Bool {
  self.0.contains(x)
}

///|
pub fn EdnSetView::add(self : EdnSetView, x : Edn) -> Unit {
  self.0.add(x)
}

///|
pub fn EdnSetView::length(self : EdnSetView) -> UInt {
  self.0.length().reinterpret_as_uint()
}

///|
pub fn EdnSetView::is_empty(self : EdnSetView) -> Bool {
  self.0.is_empty()
}

///|
pub impl Compare for EdnSetView with compare(self, right) -> Int {
  if self.0.length() < right.0.length() {
    return -1
  }
  if self.0.length() > right.0.length() {
    return 1
  }
  // TODO does not compare the order of set elements since set is unordered
  0
}
