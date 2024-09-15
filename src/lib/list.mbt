type EdnListView Array[Edn] derive(Eq, Hash, Default)

fn get(self : EdnListView, idx : UInt) -> Edn? {
  if idx < self._.length().reinterpret_as_uint() {
    Some(self._[idx.reinterpret_as_int()])
  } else {
    None
  }
}

fn get_or_nil(self : EdnListView, idx : UInt) -> Edn {
  if idx < self._.length().reinterpret_as_uint() {
    self._[idx.reinterpret_as_int()]
  } else {
    Edn::Nil
  }
}

fn length(self : EdnListView) -> UInt {
  self._.length().reinterpret_as_uint()
}

fn is_empty(self : EdnListView) -> Bool {
  self._.length() == 0
}

/// mutablely push an element to the end of the list
fn push(self : EdnListView, x : Edn) -> Unit {
  self._.push(x)
}

/// implement iterator for EdnListView
fn iter(self : EdnListView) -> Iter[Edn] {
  Iter::new(
    fn(yield) {
      for i = 0, len = self._.length(); i < len; i = i + 1 {
        if yield(self._[i]) == IterEnd {
          break IterEnd
        }
      } else {
        IterContinue
      }
    },
  )
}
