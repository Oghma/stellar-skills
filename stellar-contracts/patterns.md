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

## Pattern 6: Interface crate for cross-project consumption (optional)

When you want other projects to call your deployed contract in a type-safe way,
publish a lightweight **interface crate**. This is the Soroban equivalent of an
Ethereum ABI — it exposes the contract's public trait and types without shipping
any implementation. Skip this if only you will invoke the contract.

### Recommended structure

```
my-contract-interface/
├── Cargo.toml
└── src/
    ├── lib.rs
    └── types.rs      # shared types used in the trait
```

### Minimal `Cargo.toml`

```toml
[package]
name = "my-contract-interface"
version = "0.1.0"
edition = "2021"

[dependencies]
soroban-sdk = { workspace = true }

[lib]
crate-type = ["rlib"]
```

The crate only depends on `soroban-sdk` — no business logic, no test
infrastructure.

### `src/lib.rs` skeleton

```rust
#![no_std]

mod types;
pub use types::*;

use soroban_sdk::contractclient;

/// Public interface of MyContract.
/// Importing this crate gives callers a generated `MyContractClient`
/// that can invoke the deployed contract.
#[contractclient(name = "MyContractClient")]
pub trait MyContractInterface {
    fn do_something(env: soroban_sdk::Env, arg: MyArg) -> MyResult;
}
```

`#[contractclient]` generates a client struct that other crates can
instantiate with a contract address to perform cross-contract or
off-chain invocations.

### `src/types.rs` example

```rust
use soroban_sdk::contracttype;

#[contracttype]
#[derive(Clone, Debug)]
pub struct MyArg {
    pub value: u64,
}

#[contracttype]
#[derive(Clone, Debug)]
pub enum MyResult {
    Ok(u64),
    Err(u32),
}
```
