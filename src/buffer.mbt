///|
struct EdnBufferView(Array[UInt]) derive(Eq)

///|
impl Hash for EdnBufferView with hash(self) {
  self.0.length()
}

///|
impl Hash for EdnBufferView with hash_combine(self, hasher) {
  for i in self.0 {
    hasher.combine(i)
  }
}

///|
impl Show for EdnBufferView with output(self, logger) {
  let mut s = ""
  s = s + "["
  for i = 0; i < self.0.length(); i = i + 1 {
    if i > 0 {
      s = s + ", "
    }
    s = s + self.0[i].to_string()
  }
  s = s + "]"
  logger.write_string(s)
}

///|
impl Compare for EdnBufferView with compare(
  self : EdnBufferView,
  right : EdnBufferView,
) -> Int {
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
