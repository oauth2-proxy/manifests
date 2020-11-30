# manifests

For hosting manifests to allow for the deployment of OAuth2-Proxy/OAuth2-Proxy

## Helm Chart

The helm chart in this repo is based on the community chart from the deprecated [helm/stable repo](https://github.com/helm/charts/tree/master/stable/oauth2-proxy)

Linting/validation uses the [helm/chart-testing tool](https://github.com/helm/chart-testing). To run it locally you need to place [two schema files](https://github.com/helm/chart-testing/blob/master/etc/lintconf.yaml) in `~/.ct` or `/etc/ct`.

```bash
ct lint --all --config ct.yaml
ct install --all --config ct.yaml
```
