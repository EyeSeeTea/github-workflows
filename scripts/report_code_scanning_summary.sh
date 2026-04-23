#!/usr/bin/env bash
set -euo pipefail

# TODO: Add tests using sample files.

# Input parameters and defaults.
sarif_file=""
tool_name=""
summary_title="Code scanning summary"
output_prefix="open_alerts"
repo="${GITHUB_REPOSITORY:-}"
branch_name="${GITHUB_HEAD_REF:-${GITHUB_REF_NAME:-}}"
open_alerts_json="${OPEN_ALERTS_OUTPUTS_JSON:-}"

# Parse CLI arguments.
while [ "$#" -gt 0 ]; do
  case "$1" in
    --sarif-file)
      [ "$#" -ge 2 ] || { echo "Missing value for --sarif-file" >&2; exit 2; }
      sarif_file="$2"
      shift 2
      ;;
    --tool-name)
      [ "$#" -ge 2 ] || { echo "Missing value for --tool-name" >&2; exit 2; }
      tool_name="$2"
      shift 2
      ;;
    --summary-title)
      [ "$#" -ge 2 ] || { echo "Missing value for --summary-title" >&2; exit 2; }
      summary_title="$2"
      shift 2
      ;;
    --output-prefix)
      [ "$#" -ge 2 ] || { echo "Missing value for --output-prefix" >&2; exit 2; }
      output_prefix="$2"
      shift 2
      ;;
    --repo)
      [ "$#" -ge 2 ] || { echo "Missing value for --repo" >&2; exit 2; }
      repo="$2"
      shift 2
      ;;
    --branch-name)
      [ "$#" -ge 2 ] || { echo "Missing value for --branch-name" >&2; exit 2; }
      branch_name="$2"
      shift 2
      ;;
    --open-alerts-json)
      [ "$#" -ge 2 ] || { echo "Missing value for --open-alerts-json" >&2; exit 2; }
      open_alerts_json="$2"
      shift 2
      ;;
    -h|--help)
      cat <<'EOF'
Usage:
  report_code_scanning_summary.sh [options]

Required:
  --sarif-file <file>
  --tool-name <name>

Optional:
  --summary-title <title>     Default: Code scanning summary
  --output-prefix <name>      Default: open_alerts
  --repo <owner/repo>         Default: $GITHUB_REPOSITORY
  --branch-name <name>        Default: $GITHUB_HEAD_REF or $GITHUB_REF_NAME
  --open-alerts-json <json>   Default: $OPEN_ALERTS_OUTPUTS_JSON
  -h, --help                  Show this help
EOF
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

# Validate required runtime dependency.
command -v jq >/dev/null 2>&1 || { echo "Missing required command: jq" >&2; exit 1; }

# Validate required inputs.
[ -n "$sarif_file" ] || { echo "Missing --sarif-file" >&2; exit 1; }
[ -n "$tool_name" ] || { echo "Missing --tool-name" >&2; exit 1; }
[ -n "$repo" ] || { echo "Missing --repo (or GITHUB_REPOSITORY)." >&2; exit 1; }
[ -n "$branch_name" ] || { echo "Missing --branch-name (or GITHUB_HEAD_REF/GITHUB_REF_NAME)." >&2; exit 1; }
[ -s "$sarif_file" ] || { echo "SARIF file is missing or empty: $sarif_file" >&2; exit 1; }

# Ensure JSON payload is always valid for jq lookups.
if [ -z "$open_alerts_json" ]; then
  open_alerts_json='{}'
fi

# Read UI counters from the JSON outputs produced by the open-alerts step.
ui_open_total="$(jq -r --arg k "${output_prefix}_head_instances_count" '.[$k] // "0"' <<<"$open_alerts_json")"
ui_open_critical="$(jq -r --arg k "${output_prefix}_head_critical_count" '.[$k] // "0"' <<<"$open_alerts_json")"
ui_open_high="$(jq -r --arg k "${output_prefix}_head_high_count" '.[$k] // "0"' <<<"$open_alerts_json")"
ui_open_medium="$(jq -r --arg k "${output_prefix}_head_medium_count" '.[$k] // "0"' <<<"$open_alerts_json")"
ui_open_low="$(jq -r --arg k "${output_prefix}_head_low_count" '.[$k] // "0"' <<<"$open_alerts_json")"
ui_open_unknown="$(jq -r --arg k "${output_prefix}_head_unknown_count" '.[$k] // "0"' <<<"$open_alerts_json")"
ui_new_total="$(jq -r --arg k "${output_prefix}_introduced_instances_count" '.[$k] // "0"' <<<"$open_alerts_json")"
ui_new_critical="$(jq -r --arg k "${output_prefix}_introduced_instances_critical_count" '.[$k] // "0"' <<<"$open_alerts_json")"
ui_new_high="$(jq -r --arg k "${output_prefix}_introduced_instances_high_count" '.[$k] // "0"' <<<"$open_alerts_json")"
ui_new_medium="$(jq -r --arg k "${output_prefix}_introduced_instances_medium_count" '.[$k] // "0"' <<<"$open_alerts_json")"
ui_new_low="$(jq -r --arg k "${output_prefix}_introduced_instances_low_count" '.[$k] // "0"' <<<"$open_alerts_json")"
ui_new_unknown="$(jq -r --arg k "${output_prefix}_introduced_instances_unknown_count" '.[$k] // "0"' <<<"$open_alerts_json")"
ui_baseline_missing="$(jq -r --arg k "${output_prefix}_baseline_missing" '.[$k] // "false"' <<<"$open_alerts_json")"

# Count unique uploaded findings from SARIF (ruleId + package + version).
sarif_uploaded_total="$({
  jq -r '
    [
      .runs[]?.results[]?
      | [
          (.ruleId // ""),
          (.properties.name // "unknown-package"),
          (.properties.version // "")
        ]
      | join("|")
    ]
    | unique
    | length
  ' "$sarif_file"
} || echo "0")"

# Guard numeric fields to avoid downstream formatting/comparison issues.
[[ "$sarif_uploaded_total" =~ ^[0-9]+$ ]] || sarif_uploaded_total="0"
[[ "$ui_open_total" =~ ^[0-9]+$ ]] || ui_open_total="0"
[[ "$ui_open_critical" =~ ^[0-9]+$ ]] || ui_open_critical="0"
[[ "$ui_open_high" =~ ^[0-9]+$ ]] || ui_open_high="0"
[[ "$ui_open_medium" =~ ^[0-9]+$ ]] || ui_open_medium="0"
[[ "$ui_open_low" =~ ^[0-9]+$ ]] || ui_open_low="0"
[[ "$ui_open_unknown" =~ ^[0-9]+$ ]] || ui_open_unknown="0"
[[ "$ui_new_total" =~ ^[0-9]+$ ]] || ui_new_total="0"
[[ "$ui_new_critical" =~ ^[0-9]+$ ]] || ui_new_critical="0"
[[ "$ui_new_high" =~ ^[0-9]+$ ]] || ui_new_high="0"
[[ "$ui_new_medium" =~ ^[0-9]+$ ]] || ui_new_medium="0"
[[ "$ui_new_low" =~ ^[0-9]+$ ]] || ui_new_low="0"
[[ "$ui_new_unknown" =~ ^[0-9]+$ ]] || ui_new_unknown="0"

# Build a direct URL to code scanning alerts filtered by branch and tool.
query="is:open branch:${branch_name} tool:\"${tool_name}\""
branch_url="https://github.com/${repo}/security/code-scanning?query=$(jq -rn --arg value "$query" '$value|@uri')"

# Build one reusable report block.
summary_report="$(cat <<EOF
${summary_title}
SARIF findings uploaded: $sarif_uploaded_total
Open alert instances in branch (GitHub UI): critical=$ui_open_critical high=$ui_open_high medium=$ui_open_medium low=$ui_open_low unknown=$ui_open_unknown total=$ui_open_total
New alert instances vs base (head - base): critical=$ui_new_critical high=$ui_new_high medium=$ui_new_medium low=$ui_new_low unknown=$ui_new_unknown total=$ui_new_total
Baseline missing for instance comparison (base has no open instances): $ui_baseline_missing
Branch alerts URL: $branch_url
EOF
)"

# Emit a single multiline notice (GitHub commands require escaped newlines).
notice_payload="$summary_report"
notice_payload="${notice_payload//'%'/'%25'}"
notice_payload="${notice_payload//$'\n'/'%0A'}"
notice_payload="${notice_payload//$'\r'/'%0D'}"
echo "::notice::${notice_payload}"

# Keep the full human-readable breakdown in the job summary.
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  cat >> "$GITHUB_STEP_SUMMARY" <<EOF
### ${summary_title}
$summary_report
EOF
fi
