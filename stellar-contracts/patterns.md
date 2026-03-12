# Stellar Contracts Patterns

## Pattern 1: Fresh Soroban workspace

```bash
scripts/new_contract.sh ./counter-workspace counter
scripts/preflight_contracts.sh ./counter-workspace/Cargo.toml
scripts/build_contract.sh ./counter-workspace/Cargo.toml
```

## Pattern 2: Testnet deploy with alias

```bash
NETWORK=testnet scripts/deploy_contract.sh \
  ./target/wasm32v1-none/release/counter.wasm \
  alice \
  counter
```

## Pattern 3: Safe invoke before send

```bash
NETWORK=testnet scripts/invoke_contract.sh \
  counter \
  alice \
  no \
  -- increment
```

If the simulation looks correct:

```bash
NETWORK=testnet scripts/invoke_contract.sh \
  counter \
  alice \
  yes \
  -- increment
```

## Pattern 4: Read a symbol-keyed state entry

```bash
NETWORK=testnet scripts/read_contract.sh \
  counter \
  STATE \
  json \
  persistent
```

## Pattern 5: Generate Python bindings

```bash
scripts/generate_python_bindings.sh --help
scripts/generate_python_bindings.sh <binding-args-supported-by-your-cli>
```
