///|
type EdnMapView Map[Edn, Edn]

///| implement Eq for EdnMapView,
/// TODO: this is not efficient, we should implement a more efficient way to compare two maps
impl Eq for EdnMapView with op_equal(self : EdnMapView, other : EdnMapView) -> Bool {
  let mut equal = true
  self._.each(fn(k, v) {
    match other._.get(k) {
      Some(v2) => if v != v2 { equal = false }
      None => equal = false
    }
  })
  if not(equal) {
    return false
  }
  other._.each(fn(k, v) {
    match self._.get(k) {
      Some(v2) => if v != v2 { equal = false }
      None => equal = false
    }
  })
  equal
}

///|
impl Hash for EdnMapView with hash(self) {
  self._.size()
}

///|
impl Hash for EdnMapView with hash_combine(self, hasher) {
  self._.each(fn(k, v) {
    k.hash_combine(hasher)
    v.hash_combine(hasher)
  })
}

///|
fn EdnMapView::to_string(self : EdnMapView) -> String {
  let mut s = ""
  s = s + "(map"
  self._.each(fn(k, v) {
    s = s + " (" + k.to_string() + " " + v.to_string() + ")"
  })
  s = s + ")"
  s
}

///|
fn EdnMapView::tag_get(self : EdnMapView, k : Edn) -> Edn? {
  self._.get(k)
}

///|
fn EdnMapView::str_get(self : EdnMapView, k : String) -> Edn? {
  self._.get(Edn::Str(k))
}

///|
fn EdnMapView::get(self : EdnMapView, k : Edn) -> Edn? {
  self._.get(k)
}

///|
fn EdnMapView::get_or_nil(self : EdnMapView, k : Edn) -> Edn {
  match self._.get(k) {
    Some(v) => v
    None => Edn::Nil
  }
}

///|
fn EdnMapView::insert(self : EdnMapView, k : Edn, v : Edn) -> Unit {
  self._.set(k, v)
}

///|
fn EdnMapView::insert_key_str(self : EdnMapView, k : String, v : Edn) -> Unit {
  self._.set(Edn::Str(k), v)
}

///|
fn EdnMapView::length(self : EdnMapView) -> UInt {
  self._.size().reinterpret_as_uint()
}

///|
fn EdnMapView::is_empty(self : EdnMapView) -> Bool {
  self._.is_empty()
}

///|
fn EdnMapView::compare(self : EdnMapView, right : EdnMapView) -> Int {
  if self._.size() < right._.size() {
    return -1
  }
  if self._.size() > right._.size() {
    return 1
  }
  // order of map is not defined, so we need to sort the keys
  return 0
}
