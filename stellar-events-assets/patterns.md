# Stellar Events And Assets Patterns

## Pattern 1: Narrow contract event watch

```bash
NETWORK=testnet EVENT_TYPE=contract scripts/watch_events.sh \
  CABCDEF0123456789 \
  50 \
  json
```

## Pattern 2: Topic-filtered watch

```bash
NETWORK=testnet TOPIC_FILTER='*,*' scripts/watch_events.sh \
  CABCDEF0123456789 \
  20 \
  plain
```

## Pattern 3: Asset id then deploy

```bash
NETWORK=testnet scripts/asset_id.sh native
NETWORK=testnet scripts/deploy_asset_contract.sh native alice xlm-asset
```
