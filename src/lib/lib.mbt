pub type! EdnCommonError String derive(Eq, Hash, Default)

pub fn to_string(self : EdnCommonError) -> String {
  match self {
    EdnCommonError(s) => s
  }
}

pub impl Show for EdnCommonError with output(self, logger) {
  Show::output(self.to_string(), logger)
}

/// parse Cirru code into data
pub fn parse(s : String) -> Edn!EdnCommonError {
  let xs = @cirru_parser.parse?(s).unwrap()
  if xs.length() == 1 {
    match xs[0] {
      @cirru_parser.Cirru::Leaf(s) =>
        raise EdnCommonError("expected expr for data, got leaf: " + s)
      @cirru_parser.Cirru::List(_) => extract_cirru_edn!(xs[0])
    }
  } else {
    raise EdnCommonError("Expected 1 expr for edn, got length \{xs.length()}")
  }
}

fn extract_cirru_edn(node : @cirru_parser.Cirru) -> Edn!EdnCommonError {
  match node {
    @cirru_parser.Cirru::Leaf(s) =>
      match s {
        "nil" => Edn::Nil
        "true" => Edn::Bool(true)
        "false" => Edn::Bool(false)
        "" => raise EdnCommonError("empty string is invalid for edn")
        s1 =>
          match s1[0] {
            '\'' => Edn::Symbol(s1.substring(start=1))
            ':' => Edn::tag(s1.substring(start=1))
            '"' | '|' => Edn::Str(s1.substring(start=1))
            _ =>
              match @strconv.parse_double?(s1.trim(" ")) {
                Ok(f) => Edn::Number(f)
                Err(e) =>
                  match e {
                    @strconv.StrConvError(s) =>
                      raise EdnCommonError("failed to parse number: " + s)
                  }
              }
          }
      }
    @cirru_parser.Cirru::List(xs) =>
      if xs.is_empty() {
        raise EdnCommonError("empty expr is invalid for edn")
      } else {
        println("extracting list: " + xs.to_string())
        match xs[0] {
          @cirru_parser.Cirru::Leaf(s) =>
            match s {
              "quote" =>
                if xs.length() == 2 {
                  Edn::Quote(xs[1])
                } else {
                  raise EdnCommonError("missing edn quote value")
                }
              "do" => {
                let mut ret : Edn? = None
                for x in xs[1:] {
                  if is_comment(x) {
                    continue
                  }
                  match ret {
                    Some(_) => raise EdnCommonError("multiple values in do")
                    None => ret = Some(extract_cirru_edn!(x))
                  }
                }
                match ret {
                  None => raise EdnCommonError("missing edn do value")
                  Some(_v) => ()
                }
                ret.or_error!(EdnCommonError("missing edn do value"))
              }
              "::" => {
                let mut tag : Edn? = None
                let extra : Array[Edn] = []
                for x in xs[1:] {
                  if is_comment(x) {
                    continue
                  }
                  match tag {
                    Some(_) => {
                      extra.push(extract_cirru_edn!(x))
                      continue
                    }
                    None => tag = Some(extract_cirru_edn!(x))
                  }
                }
                match tag {
                  Some(x0) => Edn::Tuple({ tag: x0, extra })
                  None => raise EdnCommonError("missing edn :: fst value")
                }
              }
              "[]" => {
                let ys : Array[Edn] = []
                for x in xs[1:] {
                  if is_comment(x) {
                    continue
                  }
                  match extract_cirru_edn?(x) {
                    Ok(v) => ys.push(v)
                    Err(v) => raise EdnCommonError(v.to_string())
                  }
                }
                Edn::List(EdnListView(ys))
              }
              "#{}" => {
                let ys : @hashset.T[Edn] = @hashset.new()
                for x in xs[1:] {
                  if is_comment(x) {
                    continue
                  }
                  match extract_cirru_edn?(x) {
                    Ok(v) => ys.insert(v)
                    Err(v) => raise EdnCommonError(v.to_string())
                  }
                }
                Edn::Set(EdnSetView(ys))
              }
              "{}" => {
                let zs : Map[Edn, Edn] = {}
                for x in xs[1:] {
                  if is_comment(x) {
                    continue
                  }
                  match x {
                    @cirru_parser.Cirru::Leaf(s) =>
                      raise EdnCommonError(
                        "expected a pair, invalid map entry: " + s,
                      )
                    @cirru_parser.Cirru::List(ys) =>
                      if ys.length() == 2 {
                        match
                          (extract_cirru_edn?(ys[0]), extract_cirru_edn?(ys[1])) {
                          (Ok(k), Ok(v)) => zs.set(k, v)
                          (Err(e), _) =>
                            raise EdnCommonError(
                              "invalid map entry `\{e}` from `\{ys[0]}`",
                            )
                          (Ok(k), Err(e)) =>
                            raise EdnCommonError(
                              "invalid map entry for `\{k}`, got \{e}",
                            )
                        }
                      }
                  }
                }
                Edn::Map(EdnMapView(zs))
              }
              "%{}" =>
                if xs.length() >= 3 {
                  let name = match xs[1] {
                    @cirru_parser.Cirru::Leaf(s) =>
                      EdnTag::new(s.trim_start(":"))
                    @cirru_parser.Cirru::List(e) =>
                      raise EdnCommonError(
                        "expected record name in string: " + e.to_string(),
                      )
                  }
                  let entries : Array[(EdnTag, Edn)] = []
                  for x in xs[2:] {
                    if is_comment(x) {
                      continue
                    }
                    match x {
                      @cirru_parser.Cirru::Leaf(s) =>
                        raise EdnCommonError(
                          "expected record, invalid record entry: " + s,
                        )
                      @cirru_parser.Cirru::List(ys) =>
                        if ys.length() == 2 {
                          match (ys[0], extract_cirru_edn?(ys[1])) {
                            (@cirru_parser.Cirru::Leaf(s), Ok(v)) =>
                              entries.push((EdnTag::new(s.trim_start(":")), v))
                            (@cirru_parser.Cirru::Leaf(s), Err(e)) =>
                              raise EdnCommonError(
                                "invalid record value for `\{s}`, got: \{e}",
                              )
                            (@cirru_parser.Cirru::List(zs), _) =>
                              raise EdnCommonError(
                                "invalid list as record key: \{zs}",
                              )
                          }
                        } else {
                          raise EdnCommonError(
                            "expected pair of 2: " + ys.to_string(),
                          )
                        }
                    }
                  }
                  if entries.is_empty() {
                    raise EdnCommonError("empty record is invalid")
                  }
                  Edn::Record({ tag: name, extra: entries })
                } else {
                  raise EdnCommonError("insufficient items for edn record")
                }
              "buf" => {
                let ys : Array[UInt] = []
                for x in xs[1:] {
                  if is_comment(x) {
                    continue
                  }
                  match x {
                    @cirru_parser.Cirru::Leaf(y) =>
                      if y.length() == 2 {
                        match @strconv.parse_int?(y) {
                          Ok(b) => ys.push(b.reinterpret_as_uint())
                          Err(e) =>
                            match e {
                              @strconv.StrConvError(s) =>
                                raise EdnCommonError(
                                  "expected length 2 hex string in buffer, got: \{y} \{s}",
                                )
                            }
                        }
                      } else {
                        raise EdnCommonError(
                          "expected length 2 hex string in buffer, got: \{y}",
                        )
                      }
                    _ =>
                      raise EdnCommonError(
                        "expected hex string in buffer, got: " + x.to_string(),
                      )
                  }
                }
                Edn::Buffer(ys)
              }
              a => raise EdnCommonError("invalid operator for edn: " + a)
            }
          @cirru_parser.Cirru::List(a) =>
            raise EdnCommonError("invalid nodes for edn: " + a.to_string())
        }
      }
  }
}

fn is_comment(node : @cirru_parser.Cirru) -> Bool {
  match node {
    @cirru_parser.Cirru::Leaf(_) => false
    @cirru_parser.Cirru::List(xs) => xs[0] == @cirru_parser.Cirru::Leaf(";")
  }
}

fn assemble_cirru_node(data : Edn) -> @cirru_parser.Cirru!EdnCommonError {
  match data {
    Edn::Nil => @cirru_parser.Cirru::Leaf("nil")
    Edn::Bool(v) => @cirru_parser.Cirru::Leaf(v.to_string())
    Edn::Number(n) => @cirru_parser.Cirru::Leaf(n.to_string())
    Edn::Symbol(s) => @cirru_parser.Cirru::Leaf("'\{s}")
    Edn::Tag(s) => @cirru_parser.Cirru::Leaf(":" + s._)
    Edn::Str(s) => @cirru_parser.Cirru::Leaf("|" + s)
    Edn::Quote(v) =>
      @cirru_parser.Cirru::List([@cirru_parser.Cirru::Leaf("quote"), v])
    Edn::List(xs) => {
      let ys : Array[@cirru_parser.Cirru] = []
      ys.push(@cirru_parser.Cirru::Leaf("[]"))
      for x in xs {
        ys.push(assemble_cirru_node!(x))
      }
      @cirru_parser.Cirru::List(ys)
    }
    Edn::Set(xs) => {
      let ys : Array[@cirru_parser.Cirru] = []
      ys.push(@cirru_parser.Cirru::Leaf("#{}"))
      let items = xs._
      // items.sort()
      for x in items {
        ys.push(assemble_cirru_node!(x))
      }
      @cirru_parser.Cirru::List(ys)
    }
    Edn::Map(xs) => {
      let ys : Array[@cirru_parser.Cirru] = []
      ys.push(@cirru_parser.Cirru::Leaf("{}"))
      let items = Array::from_iter(xs._.iter())
      items.sort_by(
        fn(left, right) {
          let (a1, a2) = left
          let (b1, b2) = right
          match
            (a1.is_literal(), b1.is_literal(), a2.is_literal(), b2.is_literal()) {
            (true, true, true, false) => -1
            (true, true, false, true) => 1
            (true, false, _, _) => -1
            (false, true, _, _) => 1
            // _ => a1.cmp(b1)
            _ => a1.compare(b1)
          }
        },
      )
      for pair in items.iter() {
        let (k, v) = pair
        ys.push(
          @cirru_parser.Cirru::List(
            [assemble_cirru_node!(k), assemble_cirru_node!(v)],
          ),
        )
      }
      @cirru_parser.Cirru::List(ys)
    }
    Edn::Record({ tag: name, extra: entries }) => {
      let ys : Array[@cirru_parser.Cirru] = []
      ys.push(@cirru_parser.Cirru::Leaf("%{}"))
      ys.push(@cirru_parser.Cirru::Leaf(":" + name._))
      let ordered_entries = entries
      ordered_entries.sort_by(
        fn(left, right) {
          let (_a1, a2) = left
          let (_b1, b2) = right
          match (a2.is_literal(), b2.is_literal()) {
            (true, false) => -1
            (false, true) => 1
            _ => 0
          }
        },
      )
      for entry in ordered_entries {
        let v = entry.1
        ys.push(
          @cirru_parser.Cirru::List(
            [
              @cirru_parser.Cirru::Leaf(":" + entry.0._),
              assemble_cirru_node!(v),
            ],
          ),
        )
      }
      @cirru_parser.Cirru::List(ys)
    }
    Edn::Tuple({ tag, extra }) => {
      let ys : Array[@cirru_parser.Cirru] = [
        @cirru_parser.Cirru::Leaf("::"),
        assemble_cirru_node!(tag),
      ]
      for item in extra {
        ys.push(assemble_cirru_node!(item))
      }
      @cirru_parser.Cirru::List(ys)
    }
    Edn::Buffer(buf) => {
      let ys : Array[@cirru_parser.Cirru] = []
      ys.push(@cirru_parser.Cirru::Leaf("buf"))
      for b in buf._ {
        ys.push(
          @cirru_parser.Cirru::Leaf(
            BigInt::from_int(b.reinterpret_as_int()).to_hex(),
          ),
        )
      }
      @cirru_parser.Cirru::List(ys)
    }
    // Edn::AnyRef(..) => unreachable!("AnyRef is not serializable"),
  }
}

/// generate string from Edn
pub fn format(data : Edn, use_inline : Bool) -> String!EdnCommonError {
  let options : @cirru_parser.CirruWriterOptions = { use_inline, }
  let ret = match assemble_cirru_node!(data) {
    @cirru_parser.Cirru::Leaf(s) =>
      @cirru_parser.format?(
        [
          @cirru_parser.Cirru::List(
            [@cirru_parser.Cirru::Leaf("do"), @cirru_parser.Cirru::Leaf(s)],
          ),
        ],
        options,
      )
    @cirru_parser.Cirru::List(xs) =>
      @cirru_parser.format?([@cirru_parser.Cirru::List(xs)], options)
  }
  match ret {
    Ok(s) => s
    Err(e) => raise EdnCommonError(e.to_string())
  }
}
