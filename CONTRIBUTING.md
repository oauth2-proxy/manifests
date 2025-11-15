# Contributing

This repository is the official **community maintained** helm chart for OAuth2 Proxy and is not to be confused with the helm chart published by bitnami. We rely on you to test your changes sufficiently.

## Pull Requests

All submissions, including submissions by project members, require a review. We use GitHub pull requests for this purpose.

### Pull Request Title

We do not enforce the title of your pull request to follow guidelines but we do appreciate [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

## Documentation

The documentation in the chart [README.md](charts/oauth2-proxy) and the `values.yaml` should always be kept up to date if you make changes to existing parameters or introduce new ones.

### Artifact Hub Annotation

Since we have rolling release and publish the chart on Artifact Hub, we require you to update the `artifacthub.io/changes` annotation in the `Chart.yaml` for every PR.

* [https://artifacthub.io/docs/topics/annotations/helm/](https://artifacthub.io/docs/topics/annotations/helm/)


## Versioning

We follow the [semver standard](https://semver.org/) for the chart version and application version.

Always consider your changes and try to avoid breaking changes whenever possible.

### New Application Versions

The application version is only to be updated if a new release of the OAuth2 Proxy application repo was published.

### Immutability

Each release must be immutable. Any change to a chart (even just documentation) requires a version bump. Trying to release the same version twice will result in an error.


## Testing

When making changes to the logic or resources of the chart, please make sure you tested those changes in two ways:

* Existing helm release with the chart version before your changes: `helm upgrade`
* Fresh helm release with your changes: `helm install`


### Testing Charts

As part of the Continuous Integration, we run Helm's [Chart Testing](https://github.com/helm/chart-testing) tool.

The checks for Chart Testing are stricter than the standard Helm requirements.

The configuration can be found in [ct.yaml](ct.yaml)

If you have `ct` installed, you can manually invoke the linting with the following command:

```shell
ct lint --config ct.yaml
```

If you want to run the tests locally, we recommend to use [kind](https://kind.sigs.k8s.io) to setup a local cluster.

Prerequisites:

```shell
# Add monitoring CRD
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/release-0.78/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
```

Run the tests (takes up to 10 minutes):

```shell
ct --config ct.yaml install
```

## Publishing Changes

Changes are automatically publish, whenever a commit is merged to the `main` branch by the CI job (see `./.github/workflows/release.yml`).
