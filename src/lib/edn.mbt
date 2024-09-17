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
    Edn::Str(s) => s
    Edn::Quote(e) => e.to_string()
    Edn::Buffer(b) => b.to_string()
    Edn::Tuple(t) => t.to_string()
    Edn::List(l) => l.to_string()
    Edn::Set(s) => s.to_string()
    Edn::Map(m) => m.to_string()
    Edn::Record(r) => r.to_string()
  }
}
