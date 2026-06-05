# Changelogs

This directory drives the automatic version bump workflow.

When a PR modifies the Helm chart, include a file in the appropriate subdirectory:

- `minor/` — new feature (bumps `x.Y.0`)
- `major/` — breaking change (bumps `X.0.0`)
- No file needed for patch-only changes (CI fixes, doc tweaks) — the workflow defaults to patch

## Filename

Use a descriptive name matching your PR, e.g.:
- `minor/add-runtimeclassname`
- `major/breaking-tpl-extrainitcontainers`

## File content

Write a short description of the change. This becomes part of the version bump commit message.

Example (`minor/add-runtimeclassname`):
```
Add optional runtimeClassName field to the Deployment spec, enabling
users to run oauth2-proxy under alternative container runtimes such as
gVisor or Kata Containers.
```

## How it works

On merge to `main`, the `bump-version` workflow reads files from these
directories, determines the bump type (major > minor > patch), updates
`version:` in `helm/oauth2-proxy/Chart.yaml`, commits, and pushes.
The changelog files are deleted as part of that commit.
