///|
struct EdnListView(Array[Edn]) derive(Eq)

///|
impl Hash for EdnListView with hash(self) {
  self.inner().length()
}

///|
impl Hash for EdnListView with hash_combine(self, hasher) {
  for i in self.inner() {
    i.hash_combine(hasher)
  }
}

///|
impl Show for EdnListView with output(self, logger) {
  let mut s = ""
  s = s + "(list )"
  let len = self.inner().length()
  for i = 0; i < len; i = i + 1 {
    if i > 0 {
      s = s + ", "
    }
    s = s + self.inner()[i].to_string()
  }
  s = s + ")"
  logger.write_string(s)
}

///|
impl Compare for EdnListView with compare(self, right) -> Int {
  let len = self.inner().length()
  for i = 0; i < len; i = i + 1 {
    if i >= right.inner().length() {
      return 1
    }
    let ret = self.inner()[i].compare(right.inner()[i])
    if ret != 0 {
      return ret
    }
  }
  if self.inner().length() < right.inner().length() {
    return -1
  }
  0
}

///|
/// Get an element from the EdnListView at the specified index.
/// Returns Some(element) if the index is valid, None otherwise.
pub fn EdnListView::get(self : EdnListView, idx : UInt) -> Edn? {
  if idx < self.inner().length().reinterpret_as_uint() {
    Some(self.inner()[idx.reinterpret_as_int()])
  } else {
    None
  }
}

///|
pub fn EdnListView::get_or_nil(self : EdnListView, idx : UInt) -> Edn {
  if idx < self.inner().length().reinterpret_as_uint() {
    self.inner()[idx.reinterpret_as_int()]
  } else {
    Edn::Nil
  }
}

///|
pub fn EdnListView::length(self : EdnListView) -> UInt {
  self.inner().length().reinterpret_as_uint()
}

///|
pub fn EdnListView::is_empty(self : EdnListView) -> Bool {
  self.inner().length() == 0
}

///| mutablely push an element to the end of the list
pub fn EdnListView::push(self : EdnListView, x : Edn) -> Unit {
  self.inner().push(x)
}

///| implement iterator for EdnListView
fn EdnListView::iter(self : EdnListView) -> Iter[Edn] {
  Iter::new(fn(yielding) {
    let len = self.inner().length()
    for i = 0; i < len; i = i + 1 {
      if yielding(self.inner()[i]) == IterEnd {
        break IterEnd
      }
    } else {
      IterContinue
    }
  })
}
