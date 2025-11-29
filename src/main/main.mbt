///|
using @cirru_edn {type Edn}

///|
let demo =
  #|{}
  #|  :a $ {}
  #|    :b $ {}
  #|      :1 1
  #|    :c |aaa
  #|    :d true
  #|    :e $ [] 1 2 :three

///|
fn main {
  try Edn::parse(demo) catch {
    e => println("error:" + e.to_string())
  } noraise {
    x => {
      println(x.to_string())
      println((try? x.format(use_inline=false)).unwrap())
    }
  }
  let v = (try? Edn::Atom(@cirru_edn.Edn::Number(1.0)).format(use_inline=true)).unwrap()
  println(v)
  let parsed = (try? Edn::parse("atom 1")).unwrap()
  println(parsed.to_string())
}
