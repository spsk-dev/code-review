#!/usr/bin/env bash
set -uo pipefail

PASS=0
FAIL=0

check() {
  local label="$1"
  shift
  if "$@" > /dev/null 2>&1; then
    echo "[PASS] $label"
    PASS=$((PASS + 1))
  else
    echo "[FAIL] $label"
    FAIL=$((FAIL + 1))
  fi
}

# Plugin manifest
check "plugin.json exists" test -f .claude-plugin/plugin.json
check "plugin.json is valid JSON" jq empty .claude-plugin/plugin.json
check "plugin.json has name field" jq -e '.name' .claude-plugin/plugin.json
check "plugin.json has version field" jq -e '.version' .claude-plugin/plugin.json
check "plugin.json has description field" jq -e '.description' .claude-plugin/plugin.json

# Command
check "commands/code-review.md exists" test -f commands/code-review.md
check "commands/code-review.md has frontmatter" bash -c "head -1 commands/code-review.md | grep -q '^---'"
check "commands/code-review.md has description field" grep -q '^description:' commands/code-review.md
check "commands/code-review.md references shared/output.md" grep -q "shared/output.md" commands/code-review.md

# Skill
check "skills/code-review/SKILL.md exists" test -f skills/code-review/SKILL.md
check "skills/code-review/SKILL.md has frontmatter" bash -c "head -1 skills/code-review/SKILL.md | grep -q '^---'"
check "skills/code-review/references/review-guidelines.md exists" test -f skills/code-review/references/review-guidelines.md

# Shared branding
check "shared/output.md exists" test -f shared/output.md
check "shared/output.md contains SpSk" grep -q "SpSk" shared/output.md
check "shared/output.md contains footer" grep -q "github.com/spsk-dev/code-review" shared/output.md

# Evals
check "evals/assertions-code-review.json is valid JSON" jq empty evals/assertions-code-review.json
check "evals/fixtures/sample-pr.diff exists" test -f evals/fixtures/sample-pr.diff

# Root files
check "VERSION file exists" test -f VERSION
check "VERSION matches semver" bash -c "grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$' VERSION"
check "README.md exists" test -f README.md
check "LICENSE exists" test -f LICENSE

# No hardcoded paths
HARDCODED=$(grep -rn "/Users/\|/home/\|~/.claude/plugins" \
  --include='*.md' --include='*.json' --include='*.sh' \
  --exclude-dir=.git --exclude-dir=evals . 2>/dev/null || true)
check "No hardcoded user paths" test -z "$HARDCODED"

echo ""
echo "$PASS/$((PASS + FAIL)) checks passed"
[ "$FAIL" -gt 0 ] && exit 1
exit 0
