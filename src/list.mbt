///|
struct EdnListView(Array[Edn]) derive(Eq)

///|
impl Hash for EdnListView with hash(self) {
  self.0.length()
}

///|
impl Hash for EdnListView with hash_combine(self, hasher) {
  for i in self.0 {
    i.hash_combine(hasher)
  }
}

///|
impl Show for EdnListView with output(self, logger) {
  let mut s = ""
  s = s + "(list )"
  for i = 0; i < self.0.length(); i = i + 1 {
    if i > 0 {
      s = s + ", "
    }
    s = s + self.0[i].to_string()
  }
  s = s + ")"
  logger.write_string(s)
}

///|
impl Compare for EdnListView with compare(self, right) -> Int {
  for i = 0; i < self.0.length(); i = i + 1 {
    if i >= right.0.length() {
      return 1
    }
    let ret = self.0[i].compare(right.0[i])
    if ret != 0 {
      return ret
    }
  }
  if self.0.length() < right.0.length() {
    return -1
  }
  0
}

///|
pub fn EdnListView::get(self : EdnListView, idx : UInt) -> Edn? {
  if idx < self.0.length().reinterpret_as_uint() {
    Some(self.0[idx.reinterpret_as_int()])
  } else {
    None
  }
}

///|
pub fn EdnListView::get_or_nil(self : EdnListView, idx : UInt) -> Edn {
  if idx < self.0.length().reinterpret_as_uint() {
    self.0[idx.reinterpret_as_int()]
  } else {
    Edn::Nil
  }
}

///|
pub fn EdnListView::length(self : EdnListView) -> UInt {
  self.0.length().reinterpret_as_uint()
}

///|
pub fn EdnListView::is_empty(self : EdnListView) -> Bool {
  self.0.length() == 0
}

///|
/// mutablely push an element to the end of the list
pub fn EdnListView::push(self : EdnListView, x : Edn) -> Unit {
  self.0.push(x)
}

///|
/// implement iterator for EdnListView
pub fn EdnListView::iter(self : EdnListView) -> Iter[Edn] {
  let mut i = 0
  Iterator::new(() => if i < self.0.length() {
    let val = self.0[i]
    i = i + 1
    Some(val)
  } else {
    None
  }).iter()
}
