# Standardized Skill Specification

This repository uses a compact skill layout:

```text
<skill-name>/
|- SKILL.md
|- reference.md
|- patterns.md
`- scripts/
```

## Frontmatter

Every `SKILL.md` must start with YAML frontmatter containing:
- `name`
- `description`

Rules:
- `name` must match the directory name exactly.
- Use lowercase letters, digits, and hyphens only.
- `description` must state both capability and activation context.

## Body shape

Use this section order unless the domain strongly needs a different one:

1. `# Skill Title`
2. `## Overview`
3. `## Operating Rules`
4. `## Quick Start`
5. `## Core Workflows`
6. `## Tooling / Commands`
7. `## Edge Cases and Failure Handling`
8. `## Next Steps / Related Files`

## Repository conventions

- Keep `SKILL.md` short and procedural.
- Put command maps and long-form notes in `reference.md`.
- Put copyable workflows in `patterns.md`.
- Put deterministic wrappers in `scripts/`.
- Prefer `stellar` CLI commands over custom logic.
- Use Bash first. Only use Python when shell becomes brittle.
- Do not require Node, Bun, or TypeScript for repo-owned tooling.

## Validation

Run:

```bash
bash scripts/check-packaged-contents.sh
```
