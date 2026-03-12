---
name: stellar-localnet
description: Use this skill when starting or stopping a local Stellar container network, configuring network aliases, generating and funding identities, or bootstrapping a repeatable local Soroban development environment with the Stellar CLI.
---

# Stellar Localnet Operations

## Overview

Use this skill for local network and identity setup workflows.

Primary scope:
- start or stop a local container network
- inspect local network logs
- generate identities for local or testnet use
- fund identities on supported test networks
- validate that local prerequisites are present before contract work

Out of scope:
- contract build and deploy details
- low-level transaction envelope editing

## Operating Rules

- Prefer `stellar container` over handwritten Docker commands when using the standard quickstart image.
- Keep network naming explicit when switching between `local`, `testnet`, and other environments.
- Generate identities with stable names and reuse them instead of scattering ad hoc seed phrases in shell history.
- Treat Docker availability as a preflight requirement for local container workflows.
- Fund identities only on networks where the CLI supports it; do not assume local funding mirrors testnet funding.

## Quick Start

Preflight:

```bash
scripts/preflight_localnet.sh
```

Start a local container:

```bash
scripts/start_localnet.sh
```

Generate an identity:

```bash
scripts/bootstrap_identity.sh alice
```

Show container logs:

```bash
scripts/logs_localnet.sh
```

## Core Workflows

### 1. Preflight a machine

- Run `scripts/preflight_localnet.sh` before assuming the issue is with Soroban or RPC.
- Confirm both `stellar` and Docker are present for local network flows.

### 2. Start and stop localnet

- Use `scripts/start_localnet.sh` for the common `stellar container start local` path.
- Use `scripts/stop_localnet.sh` and `scripts/logs_localnet.sh` instead of manual container cleanup.
- Pass a custom container name only when you need multiple environments or more obvious log routing.

### 3. Bootstrap identities

- Use `scripts/bootstrap_identity.sh` to generate a named identity.
- For testnet-style flows, set `NETWORK=testnet` and `FUND=1`.
- For localnet, generate first and fund through the network-specific path you are using rather than assuming the same CLI friendbot behavior.

## Tooling / Commands

```bash
scripts/preflight_localnet.sh
scripts/start_localnet.sh
scripts/logs_localnet.sh
NETWORK=testnet FUND=1 scripts/bootstrap_identity.sh alice
scripts/stop_localnet.sh
```

## Edge Cases and Failure Handling

- If `stellar container start` fails, confirm Docker is running before debugging the network itself.
- If identity generation fails because a name already exists, rerun with `OVERWRITE=1` or choose a stable naming scheme.
- If funding fails, confirm the selected network actually supports `stellar keys fund`.

## Next Steps / Related Files

- Read `reference.md` for environment and command reminders.
- Read `patterns.md` for repeatable bootstrap flows.
- Use `stellar-contracts` after the network and identities are ready.
