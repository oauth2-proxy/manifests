# Agent Guidance for the oauth2-proxy Helm Chart

This repository hosts the community Helm chart for deploying [oauth2-proxy](https://github.com/oauth2-proxy/oauth2-proxy). Automated or human agents working in this repo should prioritize clarity, reproducibility, and reviewer trust.

## Mission and scope

- Keep the chart aligned with upstream oauth2-proxy releases and Kubernetes best practices.
- Ensure every functional change ships with updated values, docs, and tests where applicable.
- Maintain a clear audit trail so reviewers can understand *why* a change exists and how it was validated.

## Context to load first

- `helm/oauth2-proxy/Chart.yaml` – chart metadata, versioning, Artifact Hub annotations.
- `helm/oauth2-proxy/values.yaml` – defaults you must update when adding new flags/behavior.
- `helm/oauth2-proxy/README.md` – source of truth for documented configuration knobs.
- `ct.yaml` – configuration for `chart-testing`; run `ct lint --config ct.yaml` before requesting review.
- `helm/oauth2-proxy/ci/*.yaml` – sample value files that double as regression cases.

## Quality checklist before opening a PR

- [ ] Chart version bumped when any template, values, or docs change.
- [ ] `artifacthub.io/changes` updated when user-facing behavior changes.
- [ ] New/changed values documented in both `values.yaml` (with clear comments) and `helm/oauth2-proxy/README.md` tables.
- [ ] Tests/lint (`ct lint` and, if needed, `ct install`) executed and exits captured in the PR description.
- [ ] Any required secrets or sample manifests documented so reviewers can reproduce.

## AI attribution (keep it brief but visible)

We encourage useful automation, but reviewers must know when AI meaningfully shaped a change. Mark substantial AI assistance by append a commit trailer such as `Assisted-by: <tool or service>`.

Trivial autocomplete (variable names, single-line suggestions you fully rewrote) does **not** need disclosure. When in doubt, disclose.

## Need updates?

If the expectations in this file stop reflecting the team’s workflow, propose edits via an issue or PR referencing `agents.md`. Keeping these guidelines current helps both humans and agents land safe, reviewable changes.
