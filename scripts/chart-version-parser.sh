#!/usr/bin/env bash
# chart-version-parser.sh — version-parser for GarnerCorp/build-actions/bump-version
#
# Usage:
#   chart-version-parser.sh parse  <chart-yaml>          → prints current version
#   chart-version-parser.sh update <chart-yaml> <version> → updates version + changelog
set -euo pipefail

COMMAND="${1:-}"
CHART_FILE="${2:-}"

case "$COMMAND" in
  parse)
    grep -E '^version:' "$CHART_FILE" | head -1 | sed 's/version: *//'
    ;;

  update)
    NEW_VERSION="${3:-}"
    if [ -z "$NEW_VERSION" ]; then
      echo "Usage: $0 update <chart-yaml> <version>" >&2
      exit 1
    fi

    # Update the version field
    perl -pi -e 's/^(version:\s*)[\d.]+/$1'"$NEW_VERSION"'/' "$CHART_FILE"

    # Rebuild artifacthub.io/changes from all changelog files (consumed by next-version)
    # The commit-log produced by next-version contains "## minor changes\n\nfile contents\n..."
    # We parse it and inject a proper YAML changelog entry.
    COMMIT_LOG="${COMMIT_LOG:-}"
    if [ -n "$COMMIT_LOG" ] && [ -s "$COMMIT_LOG" ]; then
      # Extract kind and description from commit log sections
      changes_yaml=""
      while IFS= read -r line; do
        if [[ "$line" =~ ^###\ (.*) ]]; then
          # New changelog entry — filename becomes the description source
          current_file="${BASH_REMATCH[1]}"
        elif [[ -n "$line" && -n "${current_file:-}" ]]; then
          kind="added"
          # Detect breaking change keywords
          if echo "$line" | grep -qi "break\|BREAKING\|major"; then
            kind="changed"
          fi
          pr_number=$(echo "$line" | grep -oE '#[0-9]+' | head -1 | tr -d '#' || true)
          description=$(echo "$line" | sed 's/#[0-9]*//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
          entry="    - kind: $kind\n      description: $description"
          if [ -n "${pr_number:-}" ]; then
            entry="$entry\n      links:\n        - name: GitHub PR\n          url: https://github.com/oauth2-proxy/manifests/pull/$pr_number"
          fi
          changes_yaml="${changes_yaml}${entry}\n"
          current_file=""
        fi
      done < "$COMMIT_LOG"

      if [ -n "$changes_yaml" ]; then
        # Replace the artifacthub.io/changes block in Chart.yaml
        perl -0pi -e "s|(  artifacthub\\.io/changes: \\|\\n).*?\n(?=  [a-z]|\$)|  artifacthub.io/changes: |\n${changes_yaml}|s" "$CHART_FILE"
      fi
    fi
    ;;

  *)
    echo "Usage: $0 {parse|update} <chart-yaml> [version]" >&2
    exit 1
    ;;
esac
