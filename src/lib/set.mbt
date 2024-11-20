//

type EdnSetView @hashset.T[Edn]

/// implement Eq for EdnSetView,
/// TODO: this is not efficient, we should implement a more efficient way to compare two sets
fn op_equal(self : EdnSetView, other : EdnSetView) -> Bool {
  let mut equal = true
  self._.each(fn(x) { if not(other._.contains(x)) { equal = false } })
  if not(equal) {
    return false
  }
  other._.each(fn(x) { if not(self._.contains(x)) { equal = false } })
  equal
}

fn to_string(self : EdnSetView) -> String {
  let mut s = ""
  s = s + "(set"
  for i in self._ {
    s = s + " " + i.to_string()
  }
  s = s + ")"
  s
}

impl Hash for EdnSetView with hash(self) { self._.size() }

impl Hash for EdnSetView with hash_combine(self, hasher) {
  self._.each(fn(x) { x.hash_combine(hasher) })
}

fn contains(self : EdnSetView, x : Edn) -> Bool {
  self._.contains(x)
}

fn add(self : EdnSetView, x : Edn) -> Unit {
  self._.add(x)
}

fn length(self : EdnSetView) -> UInt {
  self._.size().reinterpret_as_uint()
}

fn is_empty(self : EdnSetView) -> Bool {
  self._.is_empty()
}

fn compare(self : EdnSetView, right : EdnSetView) -> Int {
  if self._.size() < right._.size() {
    return -1
  }
  if self._.size() > right._.size() {
    return 1
  }
  // TODO does not compare the order of set elements since set is unordered
  0
}
