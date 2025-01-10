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
  match @lib.parse?(demo) {
    Ok(x) => {
      println(x.to_string())
      println(@lib.format?(x, false).unwrap())
    }
    Err(e) => println("error:" + e.to_string())
  }
  let v = @lib.format?(@lib.Edn::Atom(@lib.Edn::Number(1.0)), true).unwrap()
  println(v)
  let parsed = @lib.parse?("atom 1").unwrap()
  println(parsed.to_string())
}
