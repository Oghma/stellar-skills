# Stellar Localnet Patterns

## Pattern 1: Fresh local Soroban session

```bash
scripts/preflight_localnet.sh
scripts/start_localnet.sh
scripts/bootstrap_identity.sh alice
scripts/logs_localnet.sh
```

## Pattern 2: Testnet bootstrap

```bash
NETWORK=testnet FUND=1 scripts/bootstrap_identity.sh alice
stellar keys public-key alice
```

## Pattern 3: Named local container

```bash
CONTAINER_NAME=stellar-dev scripts/start_localnet.sh
CONTAINER_NAME=stellar-dev scripts/logs_localnet.sh
CONTAINER_NAME=stellar-dev scripts/stop_localnet.sh
```
