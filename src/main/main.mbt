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
}
