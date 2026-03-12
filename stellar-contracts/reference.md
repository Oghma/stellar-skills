# Stellar Contracts Reference

## Command map

- `stellar contract init <project-path> --name <contract-name>`
- `stellar contract build --manifest-path <Cargo.toml> --optimize`
- `stellar contract deploy --wasm <file.wasm> --source-account <identity> --alias <name>`
- `stellar contract invoke --id <contract-id> --source-account <identity> --send <default|no|yes> -- <fn> [args]`
- `stellar contract read --id <contract-id> --key <symbol> --output <string|json|xdr>`
- `stellar contract bindings python ...`
- `stellar contract bindings json ...`

## Recommended defaults

- Build with `--optimize` for anything intended for deployment.
- Use contract aliases for local or repeated workflows.
- Use `--send=no` for first-pass invoke validation.
- Keep `NETWORK`, `STELLAR_RPC_URL`, and `STELLAR_NETWORK_PASSPHRASE` explicit in scripts or shell sessions when moving between environments.

## Common environment variables

- `NETWORK`: network alias passed through to `-n`
- `STELLAR_RPC_URL`
- `STELLAR_NETWORK_PASSPHRASE`
- `STELLAR_ACCOUNT`
- `STELLAR_SIGN_WITH_KEY`

## Binding generation

For a no-JS repository, prefer:
- `stellar contract bindings python`
- `stellar contract bindings json`

The helper script in this repo intentionally passes arguments through to the CLI instead of hardcoding a flag shape, because the installed help output may vary by CLI version.

Use TypeScript bindings only in downstream app repos that explicitly want them.

## Failure patterns

- Build failures from missing Rust target or toolchain: validate `cargo`, `rustc`, and target installation before debugging the contract.
- Deploy failures from auth or fees: confirm the selected identity and network first.
- Invoke failures from argument shape: inspect the generated CLI with `stellar contract invoke ... -- --help`.
- Read failures from wrong key format: switch from `--key` to `--key-xdr` when the key is not a plain symbol.
