# Changelog

All notable changes to the SpSk code-review plugin.

## [1.0.0] - 2026-03-29

### Added

- `/code-review` command — multi-model PR review dispatching to up to 7 agents
- 5 Claude agents with distinct review personas (logic, security, performance, style, testing)
- Codex agent for cross-model diversity (different training data = different blind spots)
- Gemini agent for broad pattern recognition
- Confidence scoring — cross-model agreement (2+ models flag same issue) gets highest confidence
- 3-tier degradation: 7 agents (full), 6 agents (no Gemini), 5 agents (Claude-only)
- SpSk branded output with signature line and score display
- Structural eval harness with 22 assertions
- Case study: real-world bug detection comparison (single vs multi-model)

### The Multi-Model Story

Single-model code review catches the obvious — syntax issues, simple logic errors. But it has systematic blind spots from its training data. Adding Codex and Gemini isn't about more opinions — it's about genuinely different reasoning patterns catching genuinely different classes of bugs. Cross-model agreement is the strongest quality signal.
