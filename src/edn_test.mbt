///|
test "atom inside edn" {
  let edn = @cirru_edn.Edn::Atom(Number(1.0))
  assert_eq(edn.format(use_inline=true).trim(char_set="\n"), "atom 1")
  let parsed : Edn = @strconv.from_str("atom 1")
  assert_eq(parsed, @cirru_edn.Atom(Number(1.0)))
}
