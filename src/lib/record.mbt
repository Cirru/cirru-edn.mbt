pub struct EdnRecordView {
  tag : EdnTag
  extra : Array[(EdnTag, Edn)]
} derive(Eq)

impl Hash for EdnRecordView with hash(self) { self.extra.length() + 1 }

impl Hash for EdnRecordView with hash_combine(self, hasher) {
  self.tag.hash_combine(hasher)
  for i in self.extra {
    i.0.hash_combine(hasher)
    i.1.hash_combine(hasher)
  }
}

pub fn to_string(self : EdnRecordView) -> String {
  let mut s = ""
  s = s + "(record"
  s = s + self.tag.to_string()
  for i in self.extra {
    s = s + " (" + i.0.to_string() + " " + i.1.to_string() + ")"
  }
  s = s + ")"
  s
}

fn EdnRecordView::new(
  tag : EdnTag,
  extra : Array[(EdnTag, Edn)]
) -> EdnRecordView {
  { tag, extra }
}

fn has_key(self : EdnRecordView, key : EdnTag) -> Bool {
  for i = 0, len = self.extra.length(); i < len; i = i + 1 {
    if self.extra[i].0 == key {
      return true
    }
  }
  false
}

/// order not guaranteed yet, better be sorted before used by runtime
fn insert(self : EdnRecordView, key : EdnTag, value : Edn) -> Unit {
  self.extra.push((key, value))
}

fn compare(self : EdnRecordView, right : EdnRecordView) -> Int {
  let len = self.extra.length()
  let right_len = right.extra.length()
  if len < right_len {
    return -1
  }
  if len > right_len {
    return 1
  }
  for i = 0, len = len; i < len; i = i + 1 {
    let mut ret = self.extra[i].0.compare(right.extra[i].0)
    if ret != 0 {
      return ret
    }
    ret = self.extra[i].1.compare(right.extra[i].1)
    if ret != 0 {
      return ret
    }
  }
  0
}
