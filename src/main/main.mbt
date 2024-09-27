let demo =
  #|{}
  #|  :a $ {}
  #|    :b $ {}
  #|      :1 1
  #|    :c |aaa
  #|    :d true
  #|    :e $ [] 1 2 :three

fn main {
  match @edn.parse?(demo) {
    Ok(x) => {
      println(x.to_string())
      println(@edn.format?(x, false).unwrap())
    }
    Err(e) => println("error:" + e.to_string())
  }
}
