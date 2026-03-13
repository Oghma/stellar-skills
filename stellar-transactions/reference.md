# Stellar Transactions Reference

## Core commands

- `stellar tx simulate --source-account <identity> <xdr-or-file>`
- `stellar tx send <xdr-or-file>`
- `stellar tx fetch <hash>`
- `stellar tx decode [input...]`
- `stellar tx encode [input...]`
- `stellar xdr ...`

## When to use this skill

Use this skill when:
- you already have a transaction envelope
- you need to inspect XDR or JSON form
- you need a simulation-first debugging loop
- you need to submit a prebuilt envelope

Use `stellar-contracts` instead when:
- the work starts from a contract function call rather than a raw envelope

## Useful flags

- `-n <network>`
- `--source-account <identity>`
- `--instruction-leeway <count>` on simulation
- `--input` and `--output` on decode/encode

## Failure patterns

- Wrong source account on simulation
- Envelope built for a different network
- Signed payload submitted to the wrong RPC endpoint
- JSON edits that do not round-trip cleanly back to XDR
