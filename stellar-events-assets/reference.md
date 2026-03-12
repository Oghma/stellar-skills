# Stellar Events And Assets Reference

## Core commands

- `stellar events --id <contract-id> --count <n> --output <pretty|plain|json>`
- `stellar contract id asset --asset <asset>`
- `stellar contract asset deploy --asset <asset> --source-account <identity> --alias <name>`

## Useful environment variables

- `NETWORK`
- `EVENT_TYPE`
- `TOPIC_FILTER`
- `START_LEDGER`
- `RPC_URL`

## Filter notes

- `--id` can take up to five contract ids.
- `--topic` accepts comma-delimited topic segments and supports `*` and trailing `**`.
- `--type` can be `all`, `contract`, or `system`.

## Asset notes

- Use `native` for XLM’s asset contract id lookup.
- Use explicit `CODE:ISSUER` notation for issued assets.
- Compute the asset contract id before wiring follow-up invoke or alias logic.
