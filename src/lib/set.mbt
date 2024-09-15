//

type EdnSetView @hashset.T[Edn] derive(Eq)

/// implement Eq for EdnSetView,
/// TODO: this is not efficient, we should implement a more efficient way to compare two sets
fn op_eq(self : EdnSetView, other : EdnSetView) -> Bool {
  let mut equal = true
  self._.each(fn(x) { if not(other._.contains(x)) { equal = false } })
  if not(equal) {
    return false
  }
  other._.each(fn(x) { if not(self._.contains(x)) { equal = false } })
  equal
}

fn contains(self : EdnSetView, x : Edn) -> Bool {
  self._.contains(x)
}

fn insert(self : EdnSetView, x : Edn) -> Unit {
  self._.insert(x)
}

fn length(self : EdnSetView) -> UInt {
  self._.size().reinterpret_as_uint()
}

fn is_empty(self : EdnSetView) -> Bool {
  self._.is_empty()
}
