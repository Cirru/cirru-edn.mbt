pub fn hello() -> String {
  "Hello, world!"
}

pub enum Edn {
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
} derive(Eq, Hash, Default)

pub fn to_string(self : Edn) -> String {
  match self {
    Edn::Nil => "nil".to_string()
    Edn::Tag(t) => t.to_string()
    Edn::Bool(b) => if b { "true" } else { "false" }
    Edn::Number(n) => n.to_string()
    Edn::Symbol(s) => s
    Edn::Str(s) =>
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
    Edn::Quote(e) => e.to_string()
    Edn::Buffer(b) => b.to_string()
    Edn::Tuple(t) => t.to_string()
    Edn::List(l) => l.to_string()
    Edn::Set(s) => s.to_string()
    Edn::Map(m) => m.to_string()
    Edn::Record(r) => r.to_string()
  }
}

// TODO Hash

pub fn compare(self : Edn, right : Edn) -> Int {
  let ret = match (self, right) {
    (Edn::Nil, Edn::Nil) => 0
    (Edn::Nil, _) => -1
    (_, Edn::Nil) => 1
    (Edn::Bool(a), Edn::Bool(b)) => a.op_compare(b)
    (Edn::Bool(_), _) => -1
    (_, Edn::Bool(_)) => 1
    (Edn::Number(a), Edn::Number(b)) => a.compare(b)
    (Edn::Number(_), _) => -1
    (_, Edn::Number(_)) => 1
    (Edn::Symbol(a), Edn::Symbol(b)) => a.compare(b)
    (Edn::Symbol(_), _) => -1
    (_, Edn::Symbol(_)) => 1
    (Edn::Tag(a), Edn::Tag(b)) => a.compare(b)
    (Edn::Tag(_), _) => -1
    (_, Edn::Tag(_)) => 1
    (Edn::Str(a), Edn::Str(b)) => a.compare(b)
    (Edn::Str(_), _) => -1
    (_, Edn::Str(_)) => 1
    (Edn::Quote(a), Edn::Quote(b)) => a.compare(b)
    (Edn::Quote(_), _) => -1
    (_, Edn::Quote(_)) => 1
    (Edn::Tuple(a), Edn::Tuple(b)) => a.compare(b)
    (Edn::Tuple(_), _) => -1
    (_, Edn::Tuple(_)) => 1
    (Edn::List(a), Edn::List(b)) => a.compare(b)
    (Edn::List(_), _) => -1
    (_, Edn::List(_)) => 1
    (Edn::Buffer(a), Edn::Buffer(b)) => a.compare(b)
    (Edn::Buffer(_), _) => -1
    (_, Edn::Buffer(_)) => 1
    (Edn::Set(a), Edn::Set(b)) => a.compare(b)
    (Edn::Set(_), _) => -1
    (_, Edn::Set(_)) => 1
    (Edn::Map(a), Edn::Map(b)) => a.compare(b)
    (Edn::Map(_), _) => -1
    (_, Edn::Map(_)) => 1
    (Edn::Record(a), Edn::Record(b)) => a.compare(b)
    // (Edn::Record(_), _) => -1
    // (_, Edn::Record(_)) => 1
  }
  ret
}

pub fn Edn::str(s : String) -> Edn {
  Edn::Str(s)
}

pub fn Edn::tag(s : String) -> Edn {
  Edn::Tag(EdnTag::new(s))
}

pub fn Edn::symbol(s : String) -> Edn {
  Edn::Symbol(s)
}

pub fn Edn::tuple(tag : Edn, extra : Array[Edn]) -> Edn {
  Edn::Tuple(EdnTupleView::new(tag, extra))
}

// TODO any-ref

pub fn Edn::is_literal(self : Edn) -> Bool {
  match self {
    Edn::Nil => true
    Edn::Bool(_) => true
    Edn::Number(_) => true
    Edn::Symbol(_) => true
    Edn::Str(_) => true
    Edn::Tag(_) => true
    _ => false
  }
}

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

fn is_simple_token(tok : String) -> Bool {
  for s in tok {
    if not(is_simple_char(s)) {
      return false
    }
  }
  true
}
