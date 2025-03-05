///|
pub fn hello() -> String {
  "Hello, world!"
}

///|
pub(all) enum Edn {
  Nil
  Bool(Bool)
  Number(Double)
  Symbol(String)
  Tag(EdnTag)
  Str(String)
  Quote(@cirru_parser.Cirru)
  Tuple(EdnTupleView)
  List(EdnListView)
  Set(EdnSetView)
  Map(EdnMapView)
  Record(EdnRecordView)
  Buffer(EdnBufferView)
  /// reference to Rust data, not interpretable in Calcit
  // AnyRef(EdnAnyRef)
  Atom(Edn)
} derive(Eq, Hash, Default)

///|
pub fn Edn::to_string(self : Edn) -> String {
  match self {
    Nil => "nil".to_string()
    Tag(t) => t.to_string()
    Bool(b) => if b { "true" } else { "false" }
    Number(n) => n.to_string()
    Symbol(s) => s
    Str(s) =>
      if is_simple_token(s) {
        s
      } else {
        let mut ret = "|"
        for c in s {
          if is_simple_char(c) {
            ret = ret + c.to_string()
          } else {
            ret = ret + c.to_string().escape()
          }
        }
        ret
      }
    Quote(e) => e.to_string()
    Buffer(b) => b.to_string()
    Tuple(t) => t.to_string()
    List(l) => l.to_string()
    Set(s) => s.to_string()
    Map(m) => m.to_string()
    Record(r) => r.to_string()
    Atom(a) => "atom " + a.to_string()
  }
}

///|
pub impl Show for Edn with output(self, logger) -> Unit {
  logger.write_string(self.to_string())
}

// TODO Hash

///|
pub fn Edn::compare(self : Edn, right : Edn) -> Int {
  let ret = match (self, right) {
    (Nil, Nil) => 0
    (Nil, _) => -1
    (_, Nil) => 1
    (Bool(a), Bool(b)) => a.compare(b)
    (Bool(_), _) => -1
    (_, Bool(_)) => 1
    (Number(a), Number(b)) => a.compare(b)
    (Number(_), _) => -1
    (_, Number(_)) => 1
    (Symbol(a), Symbol(b)) => a.compare(b)
    (Symbol(_), _) => -1
    (_, Symbol(_)) => 1
    (Tag(a), Tag(b)) => a.compare(b)
    (Tag(_), _) => -1
    (_, Tag(_)) => 1
    (Str(a), Str(b)) => a.compare(b)
    (Str(_), _) => -1
    (_, Str(_)) => 1
    (Quote(a), Quote(b)) => a.compare(b)
    (Quote(_), _) => -1
    (_, Quote(_)) => 1
    (Tuple(a), Tuple(b)) => a.compare(b)
    (Tuple(_), _) => -1
    (_, Tuple(_)) => 1
    (List(a), List(b)) => a.compare(b)
    (List(_), _) => -1
    (_, List(_)) => 1
    (Buffer(a), Buffer(b)) => a.compare(b)
    (Buffer(_), _) => -1
    (_, Buffer(_)) => 1
    (Set(a), Set(b)) => a.compare(b)
    (Set(_), _) => -1
    (_, Set(_)) => 1
    (Map(a), Map(b)) => a.compare(b)
    (Map(_), _) => -1
    (_, Map(_)) => 1
    (Atom(a), Atom(b)) => a.compare(b)
    (Atom(_), _) => -1
    (_, Atom(_)) => 1
    (Record(a), Record(b)) => a.compare(b)
    // (Record(_), _) => -1
    // (_, Record(_)) => 1
  }
  ret
}

///|
pub fn Edn::str(s : String) -> Edn {
  Edn::Str(s)
}

///|
pub fn Edn::tag(s : String) -> Edn {
  Edn::Tag(EdnTag::new(s))
}

///|
pub fn Edn::symbol(s : String) -> Edn {
  Edn::Symbol(s)
}

///|
pub fn Edn::tuple(tag : Edn, extra : Array[Edn]) -> Edn {
  Edn::Tuple(EdnTupleView::new(tag, extra))
}

// TODO any-ref

///|
pub fn Edn::is_literal(self : Edn) -> Bool {
  match self {
    Nil => true
    Bool(_) => true
    Number(_) => true
    Symbol(_) => true
    Str(_) => true
    Tag(_) => true
    _ => false
  }
}

///|
fn is_simple_char(c : Char) -> Bool {
  match c {
    '-' | '?' | '.' | '$' | ',' => true
    _ =>
      if c.to_int() >= 0x30 && c.to_int() <= 0x39 { // 0-9
        true
      } else if c.to_int() >= 0x41 && c.to_int() <= 0x5A { // A-Z
        true
      } else if c.to_int() >= 0x61 && c.to_int() <= 0x7A { // a-z
        true
      } else {
        false
      }
  }
}

///|
fn is_simple_token(tok : String) -> Bool {
  for s in tok {
    if not(is_simple_char(s)) {
      return false
    }
  }
  true
}
