---
name: stellar-transactions
description: Use this skill when simulating, signing, sending, fetching, decoding, or encoding Stellar transaction envelopes with the Stellar CLI, including raw XDR troubleshooting, offline review flows, and simulation-first transaction debugging.
---

# Stellar Transaction Workflows

## Overview

Use this skill for raw transaction and XDR-centric workflows.

Primary scope:
- simulate transaction envelopes
- send or fetch transaction envelopes
- decode XDR to JSON
- encode JSON to XDR
- troubleshoot transaction shape, fee, and signing issues

Out of scope:
- Soroban contract authoring details
- local container lifecycle

## Operating Rules

- Prefer simulation before send whenever the envelope is not already known-good.
- Preserve raw XDR during debugging so decode/encode round-trips stay reproducible.
- Keep source identity explicit on simulation paths.
- Use this skill when the problem is “what is in this envelope?” or “why won’t this transaction submit?”, not when the issue is contract API usage.

## Quick Start

Preflight:

```bash
scripts/preflight_tx.sh
```

Simulate an XDR envelope:

```bash
NETWORK=testnet scripts/simulate_tx.sh alice ./tx.xdr
```

Decode envelope JSON:

```bash
scripts/decode_tx.sh ./tx.xdr
```

Send envelope:

```bash
NETWORK=testnet scripts/send_tx.sh ./tx.xdr
```

## Core Workflows

### 1. Inspect an envelope before acting

- Use `scripts/decode_tx.sh` first when the raw payload is unclear.
- Use `scripts/encode_tx.sh` after JSON edits or tool-generated JSON output.

### 2. Simulate before send

- Use `scripts/simulate_tx.sh` with an explicit source identity.
- Keep the same network and source identity when moving from simulate to send.

### 3. Send and fetch

- Use `scripts/send_tx.sh` for already-signed or ready-to-submit envelopes.
- Fetch by hash directly with `stellar tx fetch` when you need post-submit confirmation.

## Tooling / Commands

```bash
scripts/preflight_tx.sh
NETWORK=testnet scripts/simulate_tx.sh alice ./tx.xdr
NETWORK=testnet scripts/send_tx.sh ./tx.xdr
scripts/decode_tx.sh ./tx.xdr
scripts/encode_tx.sh ./tx.json
```

## Edge Cases and Failure Handling

- If simulation fails but decode looks fine, confirm the source identity and network match the intended envelope context.
- If send fails, keep the original XDR and decode it rather than reconstructing the transaction from memory.
- If decode/encode output differs unexpectedly, verify the selected input and output modes.

## Next Steps / Related Files

- Read `reference.md` for envelope troubleshooting reminders.
- Read `patterns.md` for simulate/decode/send workflows.
- Use `stellar-contracts` when the issue is contract-specific rather than transaction-shape specific.
