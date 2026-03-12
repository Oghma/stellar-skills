---
name: stellar-contracts
description: Use this skill when creating, building, deploying, invoking, reading, or debugging Soroban smart contracts with the Stellar CLI, including contract init, wasm builds, deployment aliases, state reads, and client binding generation.
---

# Stellar Contract Workflows

## Overview

Use this skill for Soroban contract lifecycle work driven by the `stellar` CLI.

Primary scope:
- initialize a new Soroban contract workspace
- build Rust contracts into wasm
- deploy or upload contract wasm
- invoke contract functions
- read contract state entries
- generate client bindings, especially Python or JSON bindings

Out of scope:
- raw transaction envelope surgery unrelated to contract flows
- local container operations beyond basic prerequisites

## Operating Rules

- Prefer `stellar contract` subcommands over handwritten cargo or wasm steps.
- Use `stellar contract build --optimize` for deployable wasm unless debugging a build issue.
- Treat deploy and invoke as separate phases: first capture the contract id, then bind aliases or follow-up calls.
- Use explicit `--source-account` and explicit network selection for all state-changing operations.
- Use `--send=no` on `stellar contract invoke` when checking return values or auth requirements before submission.
- Keep repo-owned tooling Bash-first. Do not introduce JS wrappers in this repo.

## Quick Start

Create a new workspace:

```bash
scripts/new_contract.sh ./hello-workspace hello-world
```

Build optimized wasm:

```bash
scripts/build_contract.sh ./hello-workspace/Cargo.toml
```

Deploy and save an alias:

```bash
NETWORK=testnet scripts/deploy_contract.sh \
  target/wasm32v1-none/release/hello_world.wasm \
  alice \
  hello-world
```

Invoke a function without sending:

```bash
NETWORK=testnet scripts/invoke_contract.sh \
  hello-world \
  alice \
  no \
  -- hello --to world
```

## Core Workflows

### 1. Scaffold a contract workspace

- Use `scripts/new_contract.sh` to wrap `stellar contract init`.
- Use one workspace per example or app when possible.
- Keep the generated sample until build and deploy work end-to-end.

### 2. Build wasm

- Use `scripts/preflight_contracts.sh` before the first build on a new machine.
- Use `scripts/build_contract.sh` for the common `manifest + optimize + optional out-dir` path.
- If you need to inspect commands only, use the CLI directly with `stellar contract build --print-commands-only`.

### 3. Deploy or upload

- Use `scripts/deploy_contract.sh` for normal deploys from a built wasm file.
- Save an alias on deploy whenever the contract will be reused.
- Use the CLI directly for advanced flags such as `--build-only` or custom constructor slop.

### 4. Invoke safely

- Use `scripts/invoke_contract.sh` with `send_mode=no` first for uncertain calls.
- Switch to `send_mode=yes` or `default` only after arguments and auth are confirmed.
- Use `stellar contract invoke ... -- --help` to inspect a contract’s generated function CLI.

### 5. Read state and generate bindings

- Use `scripts/read_contract.sh` for symbol-key reads and output selection.
- Use `scripts/generate_python_bindings.sh` as a thin pass-through wrapper around `stellar contract bindings python` when a Python client is useful and you want to stay within the no-JS constraint.

## Tooling / Commands

```bash
scripts/preflight_contracts.sh
scripts/new_contract.sh ./workspace counter
scripts/build_contract.sh ./workspace/Cargo.toml
NETWORK=testnet scripts/deploy_contract.sh ./counter.wasm alice counter
NETWORK=testnet scripts/invoke_contract.sh counter alice no -- increment
NETWORK=testnet scripts/read_contract.sh counter STATE json persistent
scripts/generate_python_bindings.sh --help
```

## Edge Cases and Failure Handling

- If `cargo` or `rustc` is missing, run the preflight script before assuming a contract issue.
- If `stellar contract build` cannot find the right crate, pass `--manifest-path` explicitly.
- If invoke output looks like a simulation result when you expected a send, check `send_mode` and whether the call is view-like.
- If state reads fail, verify whether the key is a symbol key or whether the contract stores the value under XDR-only keys.

## Next Steps / Related Files

- Read `reference.md` for the command map and flag reminders.
- Read `patterns.md` for reusable scaffold, deploy, and invoke patterns.
- Use the scripts in `scripts/` for the deterministic happy-path wrappers.
