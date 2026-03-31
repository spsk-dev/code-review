#!/usr/bin/env bash
set -uo pipefail

# SpSk Code-Review — HTML Report Generator
# Reads review-state.json, produces self-contained HTML.
# Zero npm dependencies. Requires: jq.

if ! command -v jq &>/dev/null; then
  echo "ERROR: jq required. Install: brew install jq (macOS) or apt install jq (Linux)" >&2
  exit 1
fi

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" || -z "${1:-}" ]]; then
  echo "Usage: generate-report.sh <review-state.json> [output.html]"
  exit 0
fi

STATE_FILE="$1"
[[ -f "$STATE_FILE" ]] || { echo "ERROR: File not found: $STATE_FILE" >&2; exit 1; }
jq empty "$STATE_FILE" 2>/dev/null || { echo "ERROR: Invalid JSON: $STATE_FILE" >&2; exit 1; }

if [[ -n "${2:-}" ]]; then
  OUTPUT_HTML="$2"
else
  INPUT_DIR="$(cd "$(dirname "$STATE_FILE")" && pwd)"
  OUTPUT_HTML="${INPUT_DIR}/code-review-report.html"
fi

# Extract data
PR_NUMBER=$(jq -r '.pr_number // "N/A"' "$STATE_FILE")
PR_REPO=$(jq -r '.repo // "N/A"' "$STATE_FILE")
PR_TITLE=$(jq -r '.pr_title // "PR Review"' "$STATE_FILE")
TIER=$(jq -r '.tier // 1' "$STATE_FILE")
MODEL_CONFIG=$(jq -r '.model_config // "unknown"' "$STATE_FILE")
AGENT_COUNT=$(jq '.agents | length' "$STATE_FILE")
TOTAL_FINDINGS=$(jq '.findings | length' "$STATE_FILE" 2>/dev/null || echo 0)
HIGH_CONF=$(jq '[.findings[] | select(.confidence >= 80)] | length' "$STATE_FILE" 2>/dev/null || echo 0)

{
cat <<'HTML_HEAD'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
HTML_HEAD

echo "  <title>SpSk Code Review — PR #${PR_NUMBER}</title>"

cat <<'STYLE'
  <style>
    :root {
      --bg: #18181b; --surface: #27272a; --border: #3f3f46;
      --text: #fafafa; --text-muted: #a1a1aa;
      --high: #22c55e; --moderate: #eab308; --low: #f97316; --critical: #ef4444;
      --accent: #3b82f6;
    }
    @media (prefers-color-scheme: light) {
      :root {
        --bg: #fafafa; --surface: #ffffff; --border: #e4e4e7;
        --text: #18181b; --text-muted: #71717a;
      }
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: var(--bg); color: var(--text); line-height: 1.6; max-width: 800px; margin: 0 auto; padding: 2rem 1rem; }
    .header { text-align: center; margin-bottom: 2rem; }
    .signature { font-family: monospace; font-size: 0.85rem; color: var(--text-muted); margin-bottom: 0.5rem; }
    h1 { font-size: 1.3rem; margin-bottom: 0.5rem; }
    .pr-meta { font-size: 0.9rem; color: var(--text-muted); }
    .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 0.75rem; margin: 1.5rem 0; }
    .stat-card { background: var(--surface); border: 1px solid var(--border); border-radius: 8px; padding: 1rem; text-align: center; }
    .stat-value { font-size: 1.5rem; font-weight: 700; }
    .stat-label { font-size: 0.8rem; color: var(--text-muted); }
    section { margin: 1.5rem 0; }
    h2 { font-size: 1.1rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.05em; border-bottom: 1px solid var(--border); padding-bottom: 0.5rem; margin-bottom: 1rem; }
    .agent-card { background: var(--surface); border: 1px solid var(--border); border-radius: 8px; padding: 1rem; margin-bottom: 0.75rem; }
    .agent-header { display: flex; justify-content: space-between; align-items: center; }
    .agent-name { font-weight: 600; }
    .agent-model { font-size: 0.8rem; color: var(--text-muted); }
    .finding-item { padding: 0.75rem; background: var(--surface); border: 1px solid var(--border); border-radius: 6px; margin-bottom: 0.5rem; }
    .finding-header { display: flex; justify-content: space-between; }
    .confidence-badge { font-family: monospace; font-size: 0.8rem; padding: 2px 8px; border-radius: 4px; }
    .conf-high { background: var(--high); color: #000; }
    .conf-medium { background: var(--moderate); color: #000; }
    .conf-low { background: var(--border); color: var(--text-muted); }
    .severity-tag { font-size: 0.75rem; font-weight: 600; padding: 1px 6px; border-radius: 3px; }
    .severity-critical { background: var(--critical); color: #fff; }
    .severity-high { background: var(--low); color: #fff; }
    .severity-medium { background: var(--moderate); color: #000; }
    .file-ref { font-family: monospace; font-size: 0.85rem; color: var(--accent); }
    .footer { text-align: center; margin-top: 2rem; padding-top: 1rem; border-top: 1px solid var(--border); font-size: 0.85rem; color: var(--text-muted); }
    .footer a { color: var(--text-muted); text-decoration: none; }
    @media print { body { max-width: 100%; } }
  </style>
</head>
<body>
STYLE

# Header
echo '  <div class="header">'
echo "    <div class=\"signature\">SpSk  code-review  v1.1.0  ───  ${AGENT_COUNT} agents  ·  tier ${TIER}</div>"
echo "    <h1>${PR_TITLE}</h1>"
echo "    <div class=\"pr-meta\">${PR_REPO}#${PR_NUMBER} · ${MODEL_CONFIG}</div>"
echo '  </div>'

# Stats
echo '  <div class="stats-grid">'
echo "    <div class=\"stat-card\"><div class=\"stat-value\">${AGENT_COUNT}</div><div class=\"stat-label\">Agents</div></div>"
echo "    <div class=\"stat-card\"><div class=\"stat-value\">${TOTAL_FINDINGS}</div><div class=\"stat-label\">Total Findings</div></div>"
echo "    <div class=\"stat-card\"><div class=\"stat-value\">${HIGH_CONF}</div><div class=\"stat-label\">High Confidence (80+)</div></div>"
echo '  </div>'

# Agent results
echo '  <section>'
echo '    <h2>Agent Results</h2>'
for ((i=0; i<AGENT_COUNT; i++)); do
  A_NAME=$(jq -r ".agents[$i].name // \"Agent $((i+1))\"" "$STATE_FILE")
  A_MODEL=$(jq -r ".agents[$i].model // \"unknown\"" "$STATE_FILE")
  A_FINDINGS=$(jq -r ".agents[$i].findings_count // 0" "$STATE_FILE")
  A_TOP=$(jq -r ".agents[$i].top_finding // \"No findings\"" "$STATE_FILE")

  echo "    <div class=\"agent-card\">"
  echo "      <div class=\"agent-header\">"
  echo "        <span class=\"agent-name\">${A_NAME}</span>"
  echo "        <span class=\"agent-model\">${A_MODEL} · ${A_FINDINGS} findings</span>"
  echo "      </div>"
  echo "      <div style=\"font-size:0.9rem;color:var(--text-muted);margin-top:0.5rem\">${A_TOP}</div>"
  echo "    </div>"
done
echo '  </section>'

# Findings (high confidence only)
if [[ "$HIGH_CONF" -gt 0 ]]; then
  echo '  <section>'
  echo '    <h2>High-Confidence Findings (80+)</h2>'
  for ((i=0; i<TOTAL_FINDINGS; i++)); do
    CONF=$(jq -r ".findings[$i].confidence // 0" "$STATE_FILE")
    if [[ "$CONF" -ge 80 ]]; then
      ISSUE=$(jq -r ".findings[$i].issue // \"\"" "$STATE_FILE")
      FILE=$(jq -r ".findings[$i].file // \"\"" "$STATE_FILE")
      LINE=$(jq -r ".findings[$i].line // \"\"" "$STATE_FILE")
      SEVERITY=$(jq -r ".findings[$i].severity // \"medium\"" "$STATE_FILE")
      AGENTS=$(jq -r ".findings[$i].agents // [] | join(\", \")" "$STATE_FILE")

      SEV_CLASS="severity-${SEVERITY,,}"
      if [[ "$CONF" -ge 90 ]]; then CONF_CLASS="conf-high"
      elif [[ "$CONF" -ge 80 ]]; then CONF_CLASS="conf-medium"
      else CONF_CLASS="conf-low"; fi

      echo "    <div class=\"finding-item\">"
      echo "      <div class=\"finding-header\">"
      echo "        <span class=\"severity-tag ${SEV_CLASS}\">[${SEVERITY^^}]</span>"
      echo "        <span class=\"confidence-badge ${CONF_CLASS}\">${CONF}/100</span>"
      echo "      </div>"
      echo "      <div style=\"margin:0.5rem 0\">${ISSUE}</div>"
      if [[ -n "$FILE" && "$FILE" != "null" ]]; then
        echo "      <div class=\"file-ref\">${FILE}${LINE:+:$LINE}</div>"
      fi
      if [[ -n "$AGENTS" && "$AGENTS" != "null" ]]; then
        echo "      <div style=\"font-size:0.8rem;color:var(--text-muted)\">Found by: ${AGENTS}</div>"
      fi
      echo "    </div>"
    fi
  done
  echo '  </section>'
fi

# Footer
echo '  <div class="footer">'
echo '    <a href="https://github.com/spsk-dev/code-review">github.com/spsk-dev/code-review</a>'
echo '  </div>'

echo '</body>'
echo '</html>'
} > "$OUTPUT_HTML"

FILE_SIZE=$(wc -c < "$OUTPUT_HTML" | tr -d ' ')
FILE_SIZE_KB=$((FILE_SIZE / 1024))
echo ""
echo "SpSk  generate-report  v1.1.0"
echo "Report generated: ${OUTPUT_HTML}"
echo "Size: ${FILE_SIZE_KB}KB"
echo ""
