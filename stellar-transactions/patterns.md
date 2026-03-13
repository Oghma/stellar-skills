# Stellar Transactions Patterns

## Pattern 1: Decode first, then simulate

```bash
scripts/decode_tx.sh ./tx.xdr
NETWORK=testnet scripts/simulate_tx.sh alice ./tx.xdr
```

## Pattern 2: JSON round-trip

```bash
scripts/decode_tx.sh ./tx.xdr > ./tx.json
scripts/encode_tx.sh ./tx.json
```

## Pattern 3: Simulate, then send

```bash
NETWORK=testnet scripts/simulate_tx.sh alice ./tx.xdr
NETWORK=testnet scripts/send_tx.sh ./tx.xdr
```
