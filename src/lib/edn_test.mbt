///|
test "atom inside edn" {
  let edn = @lib.Edn::Atom(Number(1.0))
  assert_eq!(edn.format!(use_inline=true).trim("\n"), "atom 1")
  let parsed : Edn = @strconv.parse!("atom 1")
  assert_eq!(parsed, @lib.Atom(Number(1.0)))
}
