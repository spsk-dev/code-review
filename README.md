# Code Review

Multi-model PR code review for Claude Code. Dispatches 7 parallel agents across Claude, Codex, and Gemini for higher coverage and fewer false negatives than any single model.

## What It Does

```
/code-review 247
```

1. Validates PR eligibility (not draft, not trivially simple)
2. Launches 7 agents in parallel — 5 Claude Sonnet specialists + Codex + Gemini
3. Each agent reviews the diff independently with a different lens
4. Haiku agents score every finding 0-100 for confidence
5. Cross-model agreement boosts confidence (found by 2+ models = strong signal)
6. Only findings scoring 80+ are posted to the PR

### The 7 Agents

| # | Agent | Focus |
|---|-------|-------|
| 1 | CLAUDE.md Auditor | Compliance with project-specific guidelines |
| 2 | Shallow Scanner | Obvious bugs in the diff itself |
| 3 | History Analyzer | Bugs in context of git blame and file history |
| 4 | PR Archaeologist | Patterns from previous PRs on the same files |
| 5 | Comment Reader | Compliance with code comments and inline guidance |
| 6 | Codex Reviewer | Independent review via OpenAI Codex CLI |
| 7 | Gemini Reviewer | Independent review via Google Gemini CLI |

### 3-Tier Degradation

| Tier | Condition | Agents | Quality |
|------|-----------|--------|---------|
| 1 | Codex + Gemini available | 7 | Best — cross-model consensus |
| 2 | Only one CLI available | 6 | Good — note missing model |
| 3 | Neither CLI available | 5 | Adequate — Claude-only |

The review always works. External CLIs make it better but aren't required.

## Install

**Via Claude Code plugin registry:**
```bash
claude /install-plugin code-review@spsk-dev/code-review
```

**Manual:**
```bash
git clone https://github.com/spsk-dev/code-review.git
cd code-review && bash install.sh
```

## Why Multi-Model?

Each model has different blind spots. In [our case study](docs/case-studies/code-review-bugs-caught.md), single-model review found 3 issues. Multi-model found 8 — including a race condition that all 3 models flagged independently but none caught alone on first pass.

| Metric | Single Model | Multi-Model (3) |
|--------|-------------|-----------------|
| Issues Found | 3 | 8 |
| High Confidence (>80) | 2 | 5 |
| False Positive Rate | ~40% | ~12% |

## Structure

```
.claude-plugin/plugin.json    # Plugin manifest
commands/code-review.md       # Main command (202 lines)
skills/code-review/
  SKILL.md                    # Skill descriptor
  references/
    review-guidelines.md      # What to flag, what to skip
shared/output.md              # Branded output formatting
evals/
  validate-structure.sh       # Structural validation
  assertions-code-review.json # Quality eval assertions
  fixtures/sample-pr.diff     # Test fixture with intentional bug
docs/case-studies/
  code-review-bugs-caught.md  # Real-world impact case study
```

## Requirements

- **Claude Code** — plugin host
- **GitHub CLI** (`gh`) — required for PR fetching. Must be authenticated (`gh auth login`)
- **Codex CLI** (optional) — for multi-model review. Falls back gracefully if unavailable.
- **Gemini CLI** (optional) — for multi-model review. Falls back gracefully if unavailable.

## Part of SpSk

Polished AI agent skills for Claude Code. See more at [github.com/spsk-dev](https://github.com/spsk-dev).

## License

MIT
