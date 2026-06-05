#!/usr/bin/env bash
# chart-version-parser.sh — version-parser for GarnerCorp/build-actions/bump-version
#
# Usage:
#   chart-version-parser.sh parse  <chart-yaml>
#       → prints current semver from "version: X.Y.Z"
#
#   COMMIT_LOG=<path> chart-version-parser.sh update <chart-yaml> <new-version>
#       → updates "version:" and "artifacthub.io/changes" block in-place
#
# COMMIT_LOG format (produced by GarnerCorp/build-actions/next-version):
#   ### <filename>
#   <one-line description> [#<pr-number>]
#
#   ### <filename2>
#   ...
#
# Example input (Chart.yaml excerpt):
#   version: 10.6.0
#   annotations:
#     artifacthub.io/changes: |
#       - kind: added
#         description: Added name attribute for HTTPRoute rules
#
# Example COMMIT_LOG:
#   ### add-runtimeclassname
#   Add optional runtimeClassName field to the Deployment spec #410
#
#   ### add-alpha-config-helpers
#   Add alpha-config.source and alpha-config.name helpers #405
#
# Example output (Chart.yaml excerpt):
#   version: 10.7.0
#   annotations:
#     artifacthub.io/changes: |
#       - kind: added
#         description: Add optional runtimeClassName field to the Deployment spec
#         links:
#           - name: GitHub PR
#             url: https://github.com/oauth2-proxy/manifests/pull/410
#       - kind: added
#         description: Add alpha-config.source and alpha-config.name helpers
#         links:
#           - name: GitHub PR
#             url: https://github.com/oauth2-proxy/manifests/pull/405
set -euo pipefail

COMMAND="${1:-}"
CHART_FILE="${2:-}"

case "$COMMAND" in
  parse)
    grep -E '^version:' "$CHART_FILE" | head -1 | sed 's/version:[[:space:]]*//'
    ;;

  update)
    NEW_VERSION="${3:-}"
    if [ -z "$NEW_VERSION" ]; then
      echo "Usage: $0 update <chart-yaml> <version>" >&2
      exit 1
    fi

    # Update the version field
    sed -i.bak "s/^version:[[:space:]].*/version: ${NEW_VERSION}/" "$CHART_FILE"
    rm -f "${CHART_FILE}.bak"

    # Rebuild artifacthub.io/changes from COMMIT_LOG (set by next-version action)
    COMMIT_LOG="${COMMIT_LOG:-}"
    if [ -z "$COMMIT_LOG" ] || [ ! -s "$COMMIT_LOG" ]; then
      exit 0
    fi

    # Build the new changes YAML block from commit log entries
    changes_yaml=""
    current_file=""
    while IFS= read -r line; do
      if [[ "$line" =~ ^###[[:space:]]+(.*) ]]; then
        current_file="${BASH_REMATCH[1]}"
      elif [[ -n "$line" && -n "$current_file" ]]; then
        kind="added"
        if echo "$line" | grep -qiE "break|BREAKING|remov|deprecat"; then
          kind="changed"
        fi
        pr_number=$(echo "$line" | grep -oE '#[0-9]+' | head -1 | tr -d '#' || true)
        description=$(echo "$line" | sed 's/[[:space:]]*#[0-9]*[[:space:]]*$//' | sed 's/^[[:space:]]*//')

        entry="    - kind: ${kind}\n      description: ${description}"
        if [ -n "${pr_number}" ]; then
          entry="${entry}\n      links:\n        - name: GitHub PR\n          url: https://github.com/oauth2-proxy/manifests/pull/${pr_number}"
        fi
        changes_yaml="${changes_yaml}${entry}\n"
        current_file=""
      fi
    done < "$COMMIT_LOG"

    if [ -z "$changes_yaml" ]; then
      exit 0
    fi

    # Splice the new changes block into Chart.yaml using python for reliable multi-line handling
    changes_block="$(printf '%b' "$changes_yaml")"
    python3 - "$CHART_FILE" "$changes_block" << 'PYEOF'
import sys

chart_file = sys.argv[1]
new_entries = sys.argv[2]  # pre-formatted YAML lines (4-space indented)

with open(chart_file) as f:
    lines = f.readlines()

out = []
skip = False
for line in lines:
    if line.startswith('  artifacthub.io/changes:'):
        # Replace the entire block with new content
        out.append('  artifacthub.io/changes: |\n')
        for entry_line in new_entries.splitlines():
            out.append(entry_line + '\n')
        skip = True
        continue
    if skip:
        # Skip old block lines (indented with 4+ spaces under annotations)
        if line.startswith('    '):
            continue
        else:
            skip = False
    out.append(line)

with open(chart_file, 'w') as f:
    f.writelines(out)
PYEOF
    ;;

  *)
    echo "Usage: $0 {parse|update} <chart-yaml> [version]" >&2
    exit 1
    ;;
esac
