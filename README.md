# manifests

For hosting manifests to allow for the deployment of [OAuth2 Proxy](https://github.com/oauth2-proxy/oauth2-proxy)

## Helm Chart

[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/oauth2-proxy)](https://artifacthub.io/packages/helm/oauth2-proxy/oauth2-proxy)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Foauth2-proxy%2Fmanifests.svg?type=shield&issueType=license)](https://app.fossa.com/projects/git%2Bgithub.com%2Foauth2-proxy%2Fmanifests?ref=badge_shield&issueType=license)

__repository:__ https://oauth2-proxy.github.io/manifests
__name:__ oauth2-proxy


The helm chart in this repo is based on the community chart from the deprecated [helm/stable repo](https://github.com/helm/charts/tree/master/stable/oauth2-proxy)

Linting/validation uses the [helm/chart-testing tool](https://github.com/helm/chart-testing). To run it locally you need to place [two schema files](https://github.com/helm/chart-testing/blob/master/etc/lintconf.yaml) in `~/.ct` or `/etc/ct`.

```bash
ct lint --all --config ct.yaml
ct install --all --config ct.yaml
```

## Contributing

If you want to contribute to this project, please make yourself familiar with the [CONTRIBUTING.md](https://github.com/oauth2-proxy/manifests/tree/main/CONTRIBUTING.md) guide before opening a PR or issue.
Be aware this is just the Helm chart / manifest repository. Actual problems with the application OAuth2 Proxy itself should be reported in the main project repository.

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


## Code of Conduct
Participation in the OAuth2 Proxy project is governed by the [CNCF Code of Conduct](https://github.com/oauth2-proxy/oauth2-proxy/tree/master/CODE_OF_CONDUCT.md).

## License

OAuth2 Proxy is distributed under [The MIT License](https://github.com/oauth2-proxy/oauth2-proxy/tree/master/LICENSE).

[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Foauth2-proxy%2Fmanifests.svg?type=large&issueType=license)](https://app.fossa.com/projects/git%2Bgithub.com%2Foauth2-proxy%2Fmanifests?ref=badge_large&issueType=license)

The OAuth2 Proxy helm chart is distributed under [Apache License 2.0](https://github.com/oauth2-proxy/manifests/tree/main/LICENSE).

## Trademarks

OAuth2 Proxy is a [Cloud Native Computing Foundation](https://cncf.io) Sandbox project.

![CNCF](https://www.cncf.io/wp-content/uploads/2023/04/cncf-main-site-logo.svg)

The Linux Foundation® (TLF) has registered trademarks and uses trademarks. For a list of TLF trademarks, see [Trademark Usage](https://www.linuxfoundation.org/legal/trademark-usage).
