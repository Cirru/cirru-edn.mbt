///|
typealias @cirru_parser.Cirru

///|
pub(all) suberror EdnCommonError String derive(Eq, Hash, Default, Show)

///|
pub impl @strconv.FromStr for Edn with from_string(s) {
  Edn::parse(s)
}

///| parse Cirru code into data
pub fn Edn::parse(s : String) -> Edn raise @strconv.StrConvError {
  let xs = Cirru::parse?(s).unwrap()
  if xs.length() == 1 {
    match xs[0] {
      Leaf(s) =>
        raise @strconv.StrConvError("expected expr for data, got leaf: " + s)
      List(_) => extract_cirru_edn(xs[0])
    }
  } else {
    raise @strconv.StrConvError(
      "Expected 1 expr for edn, got length \{xs.length()}",
    )
  }
}

///|
fn extract_cirru_edn(
  node : @cirru_parser.Cirru,
) -> Edn raise @strconv.StrConvError {
  match node {
    Leaf(s) =>
      match s {
        "nil" => Nil
        "true" => Bool(true)
        "false" => Bool(false)
        "" => raise @strconv.StrConvError("empty string is invalid for edn")
        s1 =>
          match s1.char_at(0) {
            '\'' => Symbol(s1.substring(start=1))
            ':' => Tag(s1.substring(start=1))
            '"' | '|' => Str(s1.substring(start=1))
            _ =>
              match @strconv.parse_double?(s1.trim(" ").to_string()) {
                Ok(f) => Number(f)
                Err(e) =>
                  match e {
                    @strconv.StrConvError(s) =>
                      raise @strconv.StrConvError(
                        "failed to parse number: " + s,
                      )
                  }
              }
          }
      }
    List(xs) =>
      if xs.is_empty() {
        raise @strconv.StrConvError("empty expr is invalid for edn")
      } else {
        // println("extracting list: " + xs.to_string())
        match xs[0] {
          Leaf(s) =>
            match s {
              "quote" =>
                if xs.length() == 2 {
                  Quote(xs[1])
                } else {
                  raise @strconv.StrConvError("missing edn quote value")
                }
              "do" => {
                let mut ret : Edn? = None
                for x in xs[1:] {
                  if is_comment(x) {
                    continue
                  }
                  match ret {
                    Some(_) =>
                      raise @strconv.StrConvError("multiple values in do")
                    None => ret = Some(extract_cirru_edn(x))
                  }
                }
                match ret {
                  None => raise @strconv.StrConvError("missing edn do value")
                  Some(_v) => ()
                }
                ret.or_error(@strconv.StrConvError("missing edn do value"))
              }
              "atom" =>
                if xs.length() == 2 {
                  Atom(extract_cirru_edn(xs[1]))
                } else {
                  raise @strconv.StrConvError("missing edn atom value")
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
                      extra.push(extract_cirru_edn(x))
                      continue
                    }
                    None => tag = Some(extract_cirru_edn(x))
                  }
                }
                match tag {
                  Some(x0) => Tuple({ tag: x0, extra })
                  None =>
                    raise @strconv.StrConvError("missing edn :: fst value")
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
                    Err(v) => raise @strconv.StrConvError(v.to_string())
                  }
                }
                List(EdnListView(ys))
              }
              "#{}" => {
                let ys : @hashset.T[Edn] = @hashset.new()
                for x in xs[1:] {
                  if is_comment(x) {
                    continue
                  }
                  match extract_cirru_edn?(x) {
                    Ok(v) => ys.add(v)
                    Err(v) => raise @strconv.StrConvError(v.to_string())
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
                    Leaf(s) =>
                      raise @strconv.StrConvError(
                        "expected a pair, invalid map entry: " + s,
                      )
                    List(ys) =>
                      if ys.length() == 2 {
                        match
                          (extract_cirru_edn?(ys[0]), extract_cirru_edn?(ys[1])) {
                          (Ok(k), Ok(v)) => zs.set(k, v)
                          (Err(e), _) =>
                            raise @strconv.StrConvError(
                              "invalid map entry `\{e}` from `\{ys[0]}`",
                            )
                          (Ok(k), Err(e)) =>
                            raise @strconv.StrConvError(
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
                    Leaf(s) => EdnTag::new(s.trim_start(":").to_string())
                    List(e) =>
                      raise @strconv.StrConvError(
                        "expected record name in string: " + e.to_string(),
                      )
                  }
                  let entries : Array[(EdnTag, Edn)] = []
                  for x in xs[2:] {
                    if is_comment(x) {
                      continue
                    }
                    match x {
                      Leaf(s) =>
                        raise @strconv.StrConvError(
                          "expected record, invalid record entry: " + s,
                        )
                      List(ys) =>
                        if ys.length() == 2 {
                          match (ys[0], extract_cirru_edn?(ys[1])) {
                            (Leaf(s), Ok(v)) =>
                              entries.push(
                                (EdnTag::new(s.trim_start(":").to_string()), v),
                              )
                            (Leaf(s), Err(e)) =>
                              raise @strconv.StrConvError(
                                "invalid record value for `\{s}`, got: \{e}",
                              )
                            (List(zs), _) =>
                              raise @strconv.StrConvError(
                                "invalid list as record key: \{zs}",
                              )
                          }
                        } else {
                          raise @strconv.StrConvError(
                            "expected pair of 2: " + ys.to_string(),
                          )
                        }
                    }
                  }
                  if entries.is_empty() {
                    raise @strconv.StrConvError("empty record is invalid")
                  }
                  Edn::Record({ tag: name, extra: entries })
                } else {
                  raise @strconv.StrConvError(
                    "insufficient items for edn record",
                  )
                }
              "buf" => {
                let ys : Array[UInt] = []
                for x in xs[1:] {
                  if is_comment(x) {
                    continue
                  }
                  match x {
                    Leaf(y) =>
                      if y.length() == 2 {
                        match @strconv.parse_int?(y) {
                          Ok(b) => ys.push(b.reinterpret_as_uint())
                          Err(e) =>
                            match e {
                              @strconv.StrConvError(s) =>
                                raise @strconv.StrConvError(
                                  "expected length 2 hex string in buffer, got: \{y} \{s}",
                                )
                            }
                        }
                      } else {
                        raise @strconv.StrConvError(
                          "expected length 2 hex string in buffer, got: \{y}",
                        )
                      }
                    _ =>
                      raise @strconv.StrConvError(
                        "expected hex string in buffer, got: " + x.to_string(),
                      )
                  }
                }
                Edn::Buffer(ys)
              }
              a => raise @strconv.StrConvError("invalid operator for edn: " + a)
            }
          List(a) =>
            raise @strconv.StrConvError(
              "invalid nodes for edn: " + a.to_string(),
            )
        }
      }
  }
}

///|
fn is_comment(node : @cirru_parser.Cirru) -> Bool {
  match node {
    Leaf(_) => false
    List(xs) => xs[0] == @cirru_parser.Cirru::Leaf(";")
  }
}

///|
fn assemble_cirru_node(data : Edn) -> @cirru_parser.Cirru raise EdnCommonError {
  match data {
    Nil => Leaf("nil")
    Bool(v) => Leaf(v.to_string())
    Number(n) => Leaf(n.to_string())
    Symbol(s) => Leaf("'\{s}")
    Tag(s) => Leaf(":" + s.inner())
    Str(s) => Leaf("|" + s)
    Quote(v) => List([Leaf("quote"), v])
    List(xs) => {
      let ys : Array[@cirru_parser.Cirru] = []
      ys.push(Leaf("[]"))
      for x in xs {
        ys.push(assemble_cirru_node(x))
      }
      List(ys)
    }
    Set(xs) => {
      let ys : Array[@cirru_parser.Cirru] = []
      ys.push(@cirru_parser.Cirru::Leaf("#{}"))
      let items = xs.inner()
      // items.sort()
      for x in items {
        ys.push(assemble_cirru_node(x))
      }
      @cirru_parser.Cirru::List(ys)
    }
    Map(xs) => {
      let ys : Array[@cirru_parser.Cirru] = []
      ys.push(@cirru_parser.Cirru::Leaf("{}"))
      let items = Array::from_iter(xs.inner().iter())
      items.sort_by(fn(left, right) {
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
      })
      for pair in items.iter() {
        let (k, v) = pair
        ys.push(List([assemble_cirru_node(k), assemble_cirru_node(v)]))
      }
      List(ys)
    }
    Record({ tag: name, extra: entries }) => {
      let ys : Array[@cirru_parser.Cirru] = []
      ys.push(Leaf("%{}"))
      ys.push(Leaf(":" + name.inner()))
      let ordered_entries = entries
      ordered_entries.sort_by(fn(left, right) {
        let (_a1, a2) = left
        let (_b1, b2) = right
        match (a2.is_literal(), b2.is_literal()) {
          (true, false) => -1
          (false, true) => 1
          _ => 0
        }
      })
      for entry in ordered_entries {
        let v = entry.1
        ys.push(List([Leaf(":" + entry.0.inner()), assemble_cirru_node(v)]))
      }
      List(ys)
    }
    Tuple({ tag, extra }) => {
      let ys : Array[@cirru_parser.Cirru] = [
        Leaf("::"),
        assemble_cirru_node(tag),
      ]
      for item in extra {
        ys.push(assemble_cirru_node(item))
      }
      List(ys)
    }
    Buffer(buf) => {
      let ys : Array[@cirru_parser.Cirru] = []
      ys.push(Leaf("buf"))
      for b in buf.inner() {
        ys.push(Leaf(BigInt::from_int(b.reinterpret_as_int()).to_hex()))
      }
      List(ys)
    }
    // AnyRef(..) => unreachable!("AnyRef is not serializable"),
    Atom(v) => {
      let ys : Array[@cirru_parser.Cirru] = []
      ys.push(Leaf("atom"))
      ys.push(assemble_cirru_node(v))
      List(ys)
    }
  }
}

///| generate Cirru code from Edn
pub fn Edn::format(
  data : Self,
  use_inline? : Bool,
) -> String raise EdnCommonError {
  let options : @cirru_parser.CirruWriterOptions = {
    use_inline: use_inline.or(false),
  }
  let ret = match assemble_cirru_node(data) {
    Leaf(s) => Cirru::format?([List([Leaf("do"), Leaf(s)])], options)
    List(xs) => Cirru::format?([List(xs)], options)
  }
  match ret {
    Ok(s) => s
    Err(e) => raise EdnCommonError(e.to_string())
  }
}
