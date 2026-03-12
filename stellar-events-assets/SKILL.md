---
name: stellar-events-assets
description: Use this skill when watching Soroban contract events or working with Stellar Asset Contracts through the Stellar CLI, including event filters, asset contract ids, and asset contract deployment aliases.
---

# Stellar Events And Asset Contracts

## Overview

Use this skill for two related operational surfaces:
- contract event watching
- Stellar Asset Contract id and deploy flows

Primary scope:
- watch contract events with contract id, topic, and type filters
- compute or fetch the asset contract id for a classic asset
- deploy the built-in Soroban Asset Contract and save an alias

Out of scope:
- contract build pipelines
- raw transaction debugging

## Operating Rules

- Keep event filters narrow enough to make logs useful.
- Prefer explicit contract ids and topic filters over broad watches in busy environments.
- Save aliases on asset-contract deploys when the wrapped asset will be reused.
- Treat asset id lookup and asset deploy as separate steps.

## Quick Start

Preflight:

```bash
scripts/preflight_events_assets.sh
```

Watch a contract:

```bash
NETWORK=testnet scripts/watch_events.sh CABC... 20 plain
```

Get an asset contract id:

```bash
NETWORK=testnet scripts/asset_id.sh native
```

Deploy an asset contract:

```bash
NETWORK=testnet scripts/deploy_asset_contract.sh native alice xlm-asset
```

## Core Workflows

### 1. Watch events

- Use `scripts/watch_events.sh` for the common contract-id path.
- Add `TOPIC_FILTER` or `EVENT_TYPE` environment variables when narrowing the stream.

### 2. Compute the asset contract id

- Use `scripts/asset_id.sh` to resolve the Soroban Asset Contract id before deployment or invocation.
- Use explicit classic asset notation such as `native` or `USDC:G...`.

### 3. Deploy the built-in asset contract

- Use `scripts/deploy_asset_contract.sh` with a source identity and optional alias.
- Keep network and source explicit because deploy is a state-changing operation.

## Tooling / Commands

```bash
scripts/preflight_events_assets.sh
NETWORK=testnet scripts/watch_events.sh CABC... 20 plain
NETWORK=testnet scripts/asset_id.sh native
NETWORK=testnet scripts/deploy_asset_contract.sh native alice xlm-asset
```

## Edge Cases and Failure Handling

- If event output is too noisy, add `TOPIC_FILTER` or limit `EVENT_TYPE`.
- If asset id and deploy disagree, verify network selection first.
- If asset deploy fails, confirm the source identity can sign and submit on the selected network.

## Next Steps / Related Files

- Read `reference.md` for event filter reminders.
- Read `patterns.md` for common watch and deploy flows.
- Use `stellar-contracts` for regular contract deploy/invoke workflows.
