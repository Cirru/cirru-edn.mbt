type EdnBufferView Array[UInt] derive(Eq)

impl Hash for EdnBufferView with hash(self) { self._.length() }

impl Hash for EdnBufferView with hash_combine(self, hasher) {
  for i in self._ {
    hasher.combine(i)
  }
}

fn to_string(self : EdnBufferView) -> String {
  let mut s = ""
  s = s + "["
  for i = 0, len = self._.length(); i < len; i = i + 1 {
    if i > 0 {
      s = s + ", "
    }
    s = s + self._[i].to_string()
  }
  s = s + "]"
  s
}

fn compare(self : EdnBufferView, right : EdnBufferView) -> Int {
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
