# Stellar Localnet Reference

## Core commands

- `stellar container start local`
- `stellar container logs`
- `stellar container stop`
- `stellar keys generate <name>`
- `stellar keys fund <name> -n testnet`
- `stellar keys public-key <name>`
- `stellar network ls`

## Recommended environment variables

- `NETWORK`
- `DOCKER_HOST`
- `CONTAINER_NAME`
- `FUND=1`
- `OVERWRITE=1`

## Localnet notes

- `stellar container start` defaults to a local network if no network is passed.
- The default port mapping is `8000:8000`.
- Local workflows depend on a working Docker-compatible runtime.

## Identity notes

- `stellar keys generate --fund` is convenient, but explicit generate-then-fund is easier to debug in scripts.
- Keep the source identity stable across contract deploy and invoke flows to avoid alias confusion.
