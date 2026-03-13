# Stellar Skills

Ready-made AI coding skills for Soroban and Stellar CLI workflows — drop them into Claude Code or Codex and go.

## Skills

| Skill | Description |
|---|---|
| `stellar-contracts` | Contract init, build, deploy, invoke, state reads, and binding generation |
| `stellar-localnet` | Local container lifecycle, network setup, key generation, and bootstrap flows |
| `stellar-transactions` | Transaction simulation, send/fetch, decode/encode, and XDR troubleshooting |
| `stellar-events-assets` | Contract event watching and Stellar Asset Contract id/deploy workflows |

## Install

Run the one-liner from the root of your project:

```bash
curl -fsSL https://raw.githubusercontent.com/Oghma/stellar-skills/main/install.sh | bash
```

The interactive installer will ask you:

1. **Target** — `codex`, `claude`, or `both`
2. **Scope** — `project` (skills live in the repo) or `user` (skills live in `~`)
3. **Skills** — pick individual skills or install all
4. **Conflict policy** — `replace`, `skip`, or `abort` if a skill already exists

Skills are copied to the appropriate directory:

| Target | Scope | Install location |
|---|---|---|
| Claude Code | project | `.claude/skills/` |
| Claude Code | user | `~/.claude/skills/` |
| Codex | project | `.agents/skills/` |
| Codex | user | `~/.agents/skills/` |

### Non-interactive

Pass flags to skip prompts (useful for CI or scripted setups):

```bash
curl -fsSL https://raw.githubusercontent.com/Oghma/stellar-skills/main/install.sh | \
  bash -s -- --target claude --scope-claude project --skills all --on-exists replace --yes
```

### Update

Re-run the same command. Existing skills are replaced with the latest version.

## Development

Validate packaged contents:

```bash
bash scripts/check-packaged-contents.sh
```

Run the installer smoke test:

```bash
bash scripts/smoke-installer.sh
```
