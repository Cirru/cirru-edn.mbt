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
                Err(e) => raise EdnCommonError("failed to parse number: ")
              }
          }
      }
    @cirru_parser.Cirru::List(xs) =>
      if xs.is_empty() {
        raise EdnCommonError("empty expr is invalid for edn")
      } else {
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
                  Some(v) => ()
                }
                ret.or_error!(EdnCommonError("missing edn do value"))
              }
              "::" => {
                let mut tag : Edn? = None
                let mut extra : Array[Edn] = []
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
                let mut ys : Array[Edn] = []
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
                let mut ys : @hashset.T[Edn] = @hashset.new()
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
                let mut zs : Map[Edn, Edn] = {}
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
                      EdnTag::new(s.strip_prefix(':').unwrap_or(s))
                    @cirru_parser.Cirru::List(e) =>
                      raise EdnCommonError(
                        "expected record name in string: " + e,
                      )
                  }
                  let mut entries : Array[(EdnTag, Edn)] = []
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
                              entries.push(
                                (
                                  EdnTag::new(s.strip_prefix(':').unwrap_or(s)),
                                  v,
                                ),
                              )
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
                          raise EdnCommonError("expected pair of 2: " + ys)
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
                let mut ys : Array[UInt] = []
                for x in xs[1:] {
                  if is_comment(x) {
                    continue
                  }
                  match x {
                    @cirru_parser.Cirru::Leaf(y) =>
                      if y.length() == 2 {
                        match hex::decode(y) {
                          Ok(b) =>
                            if b.length() == 1 {
                              ys.push(b[0])
                            } else {
                              raise EdnCommonError(
                                "hex for buffer might be too large, got: " + b,
                              )
                            }
                          Err(e) =>
                            raise EdnCommonError(
                              "expected length 2 hex string in buffer, got: \{y} \{e}",
                            )
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
            raise EdnCommonError("invalid nodes for edn: " + a)
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
      @cirru_parser.Cirru::List(
        [@cirru_parser.Cirru::Leaf("quote"), @cirru_parser.Cirru::Leaf(v)],
      )
    Edn::List(xs) => {
      let mut ys : Array[@cirru_parser.Cirru] = []
      ys.push("[]")
      for x in xs {
        ys.push(assemble_cirru_node!(x))
      }
      @cirru_parser.Cirru::List(ys)
    }
    Edn::Set(xs) => {
      let mut ys : Array[@cirru_parser.Cirru] = []
      ys.push("#{}")
      let mut items = xs._
      items.sort()
      for x in items {
        ys.push(assemble_cirru_node!(x))
      }
      @cirru_parser.Cirru::List(ys)
    }
    Edn::Map(xs) => {
      let mut ys : Array[@cirru_parser.Cirru] = []
      ys.push(@cirru_parser.Cirru::Leaf("{}"))
      let mut items = Array::from_iter(xs.0.iter())
      // items.sort_by(|(a1, a2): (Edn, Edn), (b1, b2): (Edn, Edn)| {
      //   match (a1.is_literal(), b1.is_literal(), a2.is_literal(), b2.is_literal()) {
      //     (true, true, true, false) => Less,
      //     (true, true, false, true) => Greater,
      //     (true, false, ..) => Less,
      //     (false, true, ..) => Greater,
      //     _ => a1.cmp(b1),
      //   }
      // });
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
      let mut ys : Array[@cirru_parser.Cirru] = []
      ys.push(@cirru_parser.Cirru::Leaf("%{}"))
      ys.push(@cirru_parser.Cirru::Leaf(":" + name._))
      let mut ordered_entries = entries
      // ordered_entries.sort_by(fn ((_a1, a2), (_b1, b2)) {
      //   match (a2.is_literal(), b2.is_literal()) {
      //     (true, false) => Less,
      //     (false, true) => Greater,
      //     _ => Equal,
      //   }
      // })
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
      let mut ys : Array[@cirru_parser.Cirru] = [
        @cirru_parser.Cirru::Leaf("::"),
        assemble_cirru_node!(tag),
      ]
      for item in extra {
        ys.push(assemble_cirru_node!(item))
      }
      @cirru_parser.Cirru::List(ys)
    }
    Edn::Buffer(buf) => {
      let mut ys : Array[@cirru_parser.Cirru] = []
      ys.push(@cirru_parser.Cirru::Leaf("buf"))
      for b in buf._ {
        ys.push(hex::encode([b]))
      }
      @cirru_parser.Cirru::List(ys)
    }
    // Edn::AnyRef(..) => unreachable!("AnyRef is not serializable"),
  }
}

type! EdnCommonError String

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
