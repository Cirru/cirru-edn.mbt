///|
struct EdnBufferView(Array[UInt]) derive(Eq)

///|
impl Hash for EdnBufferView with hash(self) {
  self.inner().length()
}

///|
impl Hash for EdnBufferView with hash_combine(self, hasher) {
  for i in self.inner() {
    hasher.combine(i)
  }
}

///|
impl Show for EdnBufferView with output(self, logger) {
  let mut s = ""
  s = s + "["
  let len = self.inner().length()
  for i = 0; i < len; i = i + 1 {
    if i > 0 {
      s = s + ", "
    }
    s = s + self.inner()[i].to_string()
  }
  s = s + "]"
  logger.write_string(s)
}

///|
impl Compare for EdnBufferView with compare(
  self : EdnBufferView,
  right : EdnBufferView,
) -> Int {
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
