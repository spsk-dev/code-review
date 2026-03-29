# SpSk Branded Output — Code Review

Standard output formatting for the code-review plugin. All command output MUST use these patterns.

## Signature Line

```
 SpSk  code-review  v{version}  ───  {agent_count} agents  ·  tier {tier}
```

- `{version}`: Read from `${CLAUDE_PLUGIN_ROOT}/VERSION`
- `{agent_count}`: 7 (Tier 1), 6 (Tier 2), 5 (Tier 3)
- `{tier}`: From CLI availability detection

## Symbols

| Symbol | Meaning |
|--------|---------|
| ✓ | Pass / Verified |
| ✗ | Fail / Issue found |
| ◆ | In progress |
| ○ | Pending |
| ⚡ | Auto-approved |
| ⚠ | Warning |

## Confidence Bar

```
████████░░ 85/100
```

Block characters showing confidence score. 10 characters wide.
- `█` = filled (score / 10)
- `░` = empty (remaining)

## Footer

Every output ends with:
```
github.com/spsk-dev/code-review
```

## Boxes (single-line borders)

```
┌──────────────────────────────────────────────────────────┐
│  Section Title                                            │
└──────────────────────────────────────────────────────────┘
```

Use `┌─┐│└─┘` characters. NOT double-line (`╔═╗║╚═╝`).
