# manifests

For hosting manifests to allow for the deployment of OAuth2-Proxy/OAuth2-Proxy

## Helm Chart

[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/oauth2-proxy)](https://artifacthub.io/packages/helm/oauth2-proxy/oauth2-proxy)

__repository:__ https://oauth2-proxy.github.io/manifests
__name:__ oauth2-proxy


The helm chart in this repo is based on the community chart from the deprecated [helm/stable repo](https://github.com/helm/charts/tree/master/stable/oauth2-proxy)

Linting/validation uses the [helm/chart-testing tool](https://github.com/helm/chart-testing). To run it locally you need to place [two schema files](https://github.com/helm/chart-testing/blob/master/etc/lintconf.yaml) in `~/.ct` or `/etc/ct`.

```bash
ct lint --all --config ct.yaml
ct install --all --config ct.yaml
```

## Verify Signed Helm Charts

With the introduction of cosign for signing artifacts you can verify the
integrity of our artifacts using the following command:

```
VERSION=8.3.0
cosign verify --certificate-oidc-issuer https://token.actions.githubusercontent.com \
    --certificate-github-workflow-repository oauth2-proxy/manifests \
    --certificate-github-workflow-name "Release Charts" \
    --certificate-github-workflow-ref refs/heads/main \
    --certificate-identity "https://github.com/oauth2-proxy/manifests/.github/workflows/release.yaml@refs/heads/main" \
    "ghcr.io/oauth2-proxy/charts/oauth2-proxy:${VERSION}" | jq
```

Note:

We utilize cosign to sign and verify artifacts with the KEYLESS mode. To learn
more about how keyless signing is done, visit the official documentation about 
[Keyless Signatures](https://docs.sigstore.dev/cosign/signing/overview/#the-signing-witnessing-and-verifying-process).
