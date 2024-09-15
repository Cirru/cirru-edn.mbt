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
  Buffer(Array[UInt])
  /// reference to Rust data, not interpretable in Calcit
  // AnyRef(EdnAnyRef)
} derive(Eq, Hash)

pub fn to_string(self : Edn) -> String {
  match self {
    Edn::Nil => "nil".to_string()
    Edn::Bool(b) => if b { "true" } else { "false" }
    Edn::Number(n) => n.to_string()
    Edn::Symbol(s) => s
    Edn::Str(s) => s
    Edn::Quote(e) => e.to_string()
    Edn::Buffer(b) => b.to_string()
  }
}

pub fn default(self : Edn) -> Edn {
  Edn::Nil
}
