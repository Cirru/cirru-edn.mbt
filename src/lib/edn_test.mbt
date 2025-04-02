///|
test "atom inside edn" {
  let edn = @lib.Edn::Atom(Number(1.0))
  assert_eq!(@lib.format!(edn, true).trim("\n"), "atom 1")
  let parsed = @lib.parse!("atom 1")
  assert_eq!(parsed, @lib.Atom(Number(1.0)))
}
