# tiye/cirru-edn

> Experimental port from cirru-edn.rs .

```bash
moon install tiye/cirru-edn
```

import it as `edn`:

```moonbit
typealias @edn.Edn
match Edn::parse?(demo) {
  Ok(x) => {
    println(x.to_string())
    println(x.format?(use_inline=false).unwrap())
  }
  Err(e) => println("error:" + e.to_string())
}
```

Or parse with `@strconv.parse!`:

```moonbit
let parsed : Edn = @strconv.parse!("atom 1")

parsed.format?(use_inline=false).unwrap() // "atom 1"
```

TODO

- tests
- any ref
