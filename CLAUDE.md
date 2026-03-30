# SpSk Code Review — Multi-Model PR Review Plugin

7-agent multi-model PR review using Claude, Codex, and Gemini in parallel. Cross-model agreement is the highest-confidence signal.

## Command

### `/code-review` — Review a Pull Request

```bash
/code-review 123
/code-review https://github.com/owner/repo/pull/123
/code-review 123 --model claude
```

**Output:** Confidence-scored findings from up to 7 independent agents. Cross-model agreement highlighted. Structured report with severity levels.

## Degradation

- **Tier 1** (7 agents): 5 Claude + Codex + Gemini — maximum coverage
- **Tier 2** (6 agents): 5 Claude + Codex — no Gemini
- **Tier 3** (5 agents): 5 Claude only — baseline

## Requirements

- GitHub CLI (`gh`) authenticated for PR fetching
- Codex CLI (optional) — cross-model diversity
- Gemini CLI (optional) — cross-model diversity

## Project

**SpSk** — A GitHub portfolio of polished AI agent skills as open-source Claude Code plugins.

- `spsk-dev/tasteful-design` — 7-specialist design review + flow audit (v1.2.0)
- `spsk-dev/code-review` — 7-agent multi-model PR review (v1.0.0)
- `spsk-dev/consensus` — 3-model consensus validation (v1.0.0)
