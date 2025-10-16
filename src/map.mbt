///|
struct EdnMapView(Map[Edn, Edn])

///|
/// implement Eq for EdnMapView,
/// TODO: this is not efficient, we should implement a more efficient way to compare two maps
impl Eq for EdnMapView with equal(self : EdnMapView, other : EdnMapView) -> Bool {
  let mut equal = true
  self
  .inner()
  .each(fn(k, v) {
    match other.inner().get(k) {
      Some(v2) => if v != v2 { equal = false }
      None => equal = false
    }
  })
  if not(equal) {
    return false
  }
  other
  .inner()
  .each(fn(k, v) {
    match self.inner().get(k) {
      Some(v2) => if v != v2 { equal = false }
      None => equal = false
    }
  })
  equal
}

///|
impl Hash for EdnMapView with hash(self) {
  self.inner().length()
}

///|
impl Hash for EdnMapView with hash_combine(self, hasher) {
  self
  .inner()
  .each(fn(k, v) {
    k.hash_combine(hasher)
    v.hash_combine(hasher)
  })
}

///|
impl Show for EdnMapView with output(self, logger) {
  let mut s = ""
  s = s + "(map"
  self
  .inner()
  .each(fn(k, v) { s = s + " (" + k.to_string() + " " + v.to_string() + ")" })
  s = s + ")"
  logger.write_string(s)
}

///|
pub fn EdnMapView::tag_get(self : EdnMapView, k : Edn) -> Edn? {
  self.inner().get(k)
}

///|
pub fn EdnMapView::str_get(self : EdnMapView, k : String) -> Edn? {
  self.inner().get(Edn::Str(k))
}

///|
pub fn EdnMapView::get(self : EdnMapView, k : Edn) -> Edn? {
  self.inner().get(k)
}

///|
pub fn EdnMapView::get_or_nil(self : EdnMapView, k : Edn) -> Edn {
  match self.inner().get(k) {
    Some(v) => v
    None => Edn::Nil
  }
}

///|
pub fn EdnMapView::insert(self : EdnMapView, k : Edn, v : Edn) -> Unit {
  self.inner().set(k, v)
}

///|
pub fn EdnMapView::insert_key_str(
  self : EdnMapView,
  k : String,
  v : Edn,
) -> Unit {
  self.inner().set(Edn::Str(k), v)
}

///|
pub fn EdnMapView::length(self : EdnMapView) -> UInt {
  self.inner().length().reinterpret_as_uint()
}

///|
pub fn EdnMapView::is_empty(self : EdnMapView) -> Bool {
  self.inner().is_empty()
}

///|
impl Compare for EdnMapView with compare(self, right) -> Int {
  if self.inner().length() < right.inner().length() {
    return -1
  }
  if self.inner().length() > right.inner().length() {
    return 1
  }
  // order of map is not defined, so we need to sort the keys
  return 0
}
