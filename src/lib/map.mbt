type EdnMapView @hashmap.T[Edn, Edn] derive(Eq)

/// implement Eq for EdnMapView,
/// TODO: this is not efficient, we should implement a more efficient way to compare two maps
fn op_eq(self : EdnMapView, other : EdnMapView) -> Bool {
  let mut equal = true
  self._.each(
    fn(k, v) {
      match other._.get(k) {
        Some(v2) => if v != v2 { equal = false }
        None => equal = false
      }
    },
  )
  if not(equal) {
    return false
  }
  other._.each(
    fn(k, v) {
      match self._.get(k) {
        Some(v2) => if v != v2 { equal = false }
        None => equal = false
      }
    },
  )
  equal
}

fn tag_get(self : EdnMapView, k : Edn) -> Edn? {
  self._.get(k)
}

fn str_get(self : EdnMapView, k : String) -> Edn? {
  self._.get(Edn::Str(k))
}

fn get(self : EdnMapView, k : Edn) -> Edn? {
  self._.get(k)
}

fn get_or_nil(self : EdnMapView, k : Edn) -> Edn {
  match self._.get(k) {
    Some(v) => v
    None => Edn::Nil
  }
}

fn insert(self : EdnMapView, k : Edn, v : Edn) -> Unit {
  self._.set(k, v)
}

fn insert_key_str(self : EdnMapView, k : String, v : Edn) -> Unit {
  self._.set(Edn::Str(k), v)
}

fn length(self : EdnMapView) -> UInt {
  self._.size().reinterpret_as_uint()
}

fn is_empty(self : EdnMapView) -> Bool {
  self._.is_empty()
}
