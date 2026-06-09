#!/usr/bin/env python3
"""
chart-version-parser.py — version-parser for GarnerCorp/build-actions/bump-version

Usage:
    chart-version-parser.py parse  <chart-yaml>
        → prints current semver from "version: X.Y.Z"

    COMMIT_LOG=<path> chart-version-parser.py update <chart-yaml> <new-version>
        → updates "version:" and "artifacthub.io/changes" block in-place

COMMIT_LOG format (produced by GarnerCorp/build-actions/next-version):
    ### <filename>
    <one-line description> [#<pr-number>]

    ### <filename2>
    ...

Example input (Chart.yaml excerpt):
    version: 10.6.0
    annotations:
      artifacthub.io/changes: |
        - kind: added
          description: Added name attribute for HTTPRoute rules

Example COMMIT_LOG:
    ### add-runtimeclassname
    Add optional runtimeClassName field to the Deployment spec #410

    ### add-alpha-config-helpers
    Add alpha-config.source and alpha-config.name helpers #405

Example output (Chart.yaml excerpt):
    version: 10.7.0
    annotations:
      artifacthub.io/changes: |
        - kind: added
          description: Add optional runtimeClassName field to the Deployment spec
          links:
            - name: GitHub PR
              url: https://github.com/oauth2-proxy/manifests/pull/410
        - kind: added
          description: Add alpha-config.source and alpha-config.name helpers
          links:
            - name: GitHub PR
              url: https://github.com/oauth2-proxy/manifests/pull/405
"""

import os
import re
import sys

REPO = "oauth2-proxy/manifests"
BREAKING_PATTERN = re.compile(r"break|BREAKING|remov|deprecat", re.IGNORECASE)
PR_PATTERN = re.compile(r"#(\d+)")


def parse_version(chart_file):
    with open(chart_file) as f:
        for line in f:
            m = re.match(r"^version:\s*(\S+)", line)
            if m:
                return m.group(1)
    raise SystemExit(f"ERROR: could not find version in {chart_file}")


def parse_commit_log(log_file):
    """Parse next-version commit-log into a list of (kind, description, pr_number|None)."""
    entries = []
    current_file = None
    with open(log_file) as f:
        for line in f:
            line = line.rstrip("\n")
            m = re.match(r"^###\s+(.+)", line)
            if m:
                current_file = m.group(1)
                continue
            if line.strip() and current_file:
                kind = "changed" if BREAKING_PATTERN.search(line) else "added"
                pr_m = PR_PATTERN.search(line)
                pr_number = pr_m.group(1) if pr_m else None
                description = PR_PATTERN.sub("", line).strip()
                entries.append((kind, description, pr_number))
                current_file = None
    return entries


def build_changes_block(entries):
    """Build the artifacthub.io/changes YAML block (4-space indented)."""
    lines = ["  artifacthub.io/changes: |\n"]
    for kind, description, pr_number in entries:
        lines.append(f"    - kind: {kind}\n")
        lines.append(f"      description: {description}\n")
        if pr_number:
            lines.append("      links:\n")
            lines.append("        - name: GitHub PR\n")
            lines.append(f"          url: https://github.com/{REPO}/pull/{pr_number}\n")
    return lines


def update_chart(chart_file, new_version, entries):
    with open(chart_file) as f:
        original = f.readlines()

    out = []
    skip = False
    for line in original:
        # Update version line
        if re.match(r"^version:\s*\S+", line):
            out.append(f"version: {new_version}\n")
            continue
        # Replace artifacthub.io/changes block if we have new entries
        if entries and line.startswith("  artifacthub.io/changes:"):
            out.extend(build_changes_block(entries))
            skip = True
            continue
        # Skip old block content (4-space indented lines under the key)
        if skip:
            if line.startswith("    "):
                continue
            skip = False
        out.append(line)

    with open(chart_file, "w") as f:
        f.writelines(out)


def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} {{parse|update}} <chart-yaml> [version]", file=sys.stderr)
        sys.exit(1)

    command, chart_file = sys.argv[1], sys.argv[2]

    if command == "parse":
        print(parse_version(chart_file))

    elif command == "update":
        if len(sys.argv) < 4:
            print(f"Usage: {sys.argv[0]} update <chart-yaml> <version>", file=sys.stderr)
            sys.exit(1)
        new_version = sys.argv[3]
        log_file = os.environ.get("COMMIT_LOG", "")
        entries = parse_commit_log(log_file) if log_file and os.path.getsize(log_file) > 0 else []
        update_chart(chart_file, new_version, entries)

    else:
        print(f"Usage: {sys.argv[0]} {{parse|update}} <chart-yaml> [version]", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
