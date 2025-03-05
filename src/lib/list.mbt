///|
type EdnListView Array[Edn] derive(Eq)

///|
impl Hash for EdnListView with hash(self) {
  self._.length()
}

///|
impl Hash for EdnListView with hash_combine(self, hasher) {
  for i in self._ {
    i.hash_combine(hasher)
  }
}

///|
fn EdnListView::to_string(self : EdnListView) -> String {
  let mut s = ""
  s = s + "(list )"
  for i = 0, len = self._.length(); i < len; i = i + 1 {
    if i > 0 {
      s = s + ", "
    }
    s = s + self._[i].to_string()
  }
  s = s + ")"
  s
}

///|
fn EdnListView::compare(self : EdnListView, right : EdnListView) -> Int {
  for i = 0, len = self._.length(); i < len; i = i + 1 {
    if i >= right._.length() {
      return 1
    }
    let ret = self._[i].compare(right._[i])
    if ret != 0 {
      return ret
    }
  }
  if self._.length() < right._.length() {
    return -1
  }
  0
}

///|
fn EdnListView::default() -> EdnListView {
  []
}

///|
fn EdnListView::get(self : EdnListView, idx : UInt) -> Edn? {
  if idx < self._.length().reinterpret_as_uint() {
    Some(self._[idx.reinterpret_as_int()])
  } else {
    None
  }
}

///|
fn EdnListView::get_or_nil(self : EdnListView, idx : UInt) -> Edn {
  if idx < self._.length().reinterpret_as_uint() {
    self._[idx.reinterpret_as_int()]
  } else {
    Edn::Nil
  }
}

///|
fn EdnListView::length(self : EdnListView) -> UInt {
  self._.length().reinterpret_as_uint()
}

///|
fn EdnListView::is_empty(self : EdnListView) -> Bool {
  self._.length() == 0
}

///| mutablely push an element to the end of the list
fn push(self : EdnListView, x : Edn) -> Unit {
  self._.push(x)
}

///| implement iterator for EdnListView
fn EdnListView::iter(self : EdnListView) -> Iter[Edn] {
  Iter::new(fn(yielding) {
    for i = 0, len = self._.length(); i < len; i = i + 1 {
      if yielding(self._[i]) == IterEnd {
        break IterEnd
      }
    } else {
      IterContinue
    }
  })
}
