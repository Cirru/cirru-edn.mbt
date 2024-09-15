pub struct EdnRecordView {
  tag : EdnTag
  extra : Array[(EdnTag, Edn)]
} derive(Eq)

fn new(tag : EdnTag, extra : Array[(EdnTag, Edn)]) -> EdnRecordView {
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
