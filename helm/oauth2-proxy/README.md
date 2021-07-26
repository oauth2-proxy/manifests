# oauth2-proxy

[oauth2-proxy](https://github.com/oauth2-proxy/oauth2-proxy) is a reverse proxy and static file server that provides authentication using Providers (Google, GitHub, and others) to validate accounts by email, domain or group.

## TL;DR;

```console
$ helm repo add oauth2-proxy https://oauth2-proxy.github.io/manifests
$ helm install my-release oauth2-proxy/oauth2-proxy
```

## Introduction

This chart bootstraps an oauth2-proxy deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install my-release oauth2-proxy/oauth2-proxy
```

The command deploys oauth2-proxy on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm uninstall my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Upgrading an existing Release to a new major version

A major chart version change (like v1.2.3 -> v2.0.0) indicates that there is an
incompatible breaking change needing manual actions.

### To 1.0.0

This version upgrades oauth2-proxy to v4.0.0. Please see the [changelog](https://github.com/oauth2-proxy/oauth2-proxy/blob/v4.0.0/CHANGELOG.md#v400) in order to upgrade.

### To 2.0.0

Version 2.0.0 of this chart introduces support for Kubernetes v1.16.x by way of addressing the deprecation of the Deployment object apiVersion `apps/v1beta2`.  See [the v1.16 API deprecations page](https://kubernetes.io/blog/2019/07/18/api-deprecations-in-1-16/) for more information.

Due to [this issue](https://github.com/helm/helm/issues/6583) there may be errors performing a `helm upgrade` of this chart from versions earlier than 2.0.0.

### To 3.0.0

Version 3.0.0 introduces support for [EKS IAM roles for service accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) by adding a managed service account to the chart.  This is a breaking change since the service account is enabled by default.  To disable this behaviour set `serviceAccount.enabled` to `false`

### To 4.0.0

Version 4.0.0 adds support for the new Ingress apiVersion **networking.k8s.io/v1**.
Therefore the `ingress.extraPaths` parameter needs to be updated to the new format.
See the [v1.22 API deprecations guide](https://kubernetes.io/docs/reference/using-api/deprecation-guide/#ingress-v122) for more information.

For the same reason `service.port` was renamed to `service.portNumber`.

## Configuration

The following table lists the configurable parameters of the oauth2-proxy chart and their default values.

Parameter | Description | Default
--- | --- | ---
`affinity` | node/pod affinities | None
`authenticatedEmailsFile.enabled` | Enables authorize individual email addresses | `false`
`authenticatedEmailsFile.persistence` | Defines how the email addresses file will be projected, via a configmap or secret | `configmap`
`authenticatedEmailsFile.template` | Name of the configmap or secret that is handled outside of that chart | `""`
`authenticatedEmailsFile.restrictedUserAccessKey` | The key of the configmap or secret that holds the email addresses list | `""`
`authenticatedEmailsFile.restricted_access` | [email addresses](https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/oauth_provider#email-authentication) list config | `""`
`authenticatedEmailsFile.annotations` | configmap or secret annotations | `nil`
`config.clientID` | oauth client ID | `""`
`config.clientSecret` | oauth client secret | `""`
`config.cookieSecret` | server specific cookie for the secret; create a new one with `openssl rand -base64 32 | head -c 32 | base64` | `""`
`config.existingSecret` | existing Kubernetes secret to use for OAuth2 credentials. See [secret template](https://github.com/oauth2-proxy/manifests/blob/master/helm/oauth2-proxy/templates/secret.yaml) for the required values | `nil`
`config.configFile` | custom [oauth2_proxy.cfg](https://github.com/oauth2-proxy/oauth2-proxy/blob/master/contrib/oauth2-proxy.cfg.example) contents for settings not overridable via environment nor command line | `""`
`config.existingConfig` | existing Kubernetes configmap to use for the configuration file. See [config template](https://github.com/oauth2-proxy/manifests/blob/master/helm/oauth2-proxy/templates/configmap.yaml) for the required values | `nil`
`config.cookieName` | The name of the cookie that oauth2-proxy will create. | `""`
`config.google.adminEmail` | user impersonated by the google service account | `""`
`config.google.serviceAccountJson` | google service account json contents | `""`
`config.google.existingConfig` | existing Kubernetes configmap to use for the service account file. See [google secret template](https://github.com/oauth2-proxy/manifests/blob/master/helm/oauth2-proxy/templates/google-secret.yaml) for the required values | `nil`
`extraArgs` | key:value list of extra arguments to give the binary | `{}`
`extraEnv` | key:value list of extra environment variables to give the binary | `[]`
`extraVolumes` | list of extra volumes | `[]`
`extraVolumeMounts` | list of extra volumeMounts | `[]`
`htpasswdFile.enabled` | enable htpasswd-file option | `false`
`htpasswdFile.entries` | list of [SHA encrypted user:passwords](https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/overview#command-line-options) | `{}`
`htpasswdFile.existingSecret` | existing Kubernetes secret to use for OAuth2 htpasswd file | `""`
`httpScheme` | `http` or `https`. `name` used for port on the deployment. `httpGet` port `name` and `scheme` used for `liveness`- and `readinessProbes`. `name` and `targetPort` used for the service. | `http`
`image.pullPolicy` | Image pull policy | `IfNotPresent`
`image.repository` | Image repository | `quay.io/oauth2-proxy/oauth2-proxy`
`image.tag` | Image tag | `v7.1.3`
`imagePullSecrets` | Specify image pull secrets | `nil` (does not add image pull secrets to deployed pods)
`ingress.enabled` | Enable Ingress | `false`
`ingress.path` | Ingress accepted path | `/`
`ingress.pathType` | Ingress [path type](https://kubernetes.io/docs/concepts/services-networking/ingress/#path-types) | `ImplementationSpecific`
`ingress.extraPaths` | Ingress extra paths to prepend to every host configuration. Useful when configuring [custom actions with AWS ALB Ingress Controller](https://kubernetes-sigs.github.io/aws-alb-ingress-controller/guide/ingress/annotation/#actions). | `[]`
`ingress.annotations` | Ingress annotations | `nil`
`ingress.hosts` | Ingress accepted hostnames | `nil`
`ingress.tls` | Ingress TLS configuration | `nil`
`livenessProbe.enabled`  | enable Kubernetes livenessProbe. Disable to use oauth2-proxy with Istio mTLS. See [Istio FAQ](https://istio.io/help/faq/security/#k8s-health-checks) | `true`
`livenessProbe.initialDelaySeconds` | number of seconds | 0
`livenessProbe.timeoutSeconds` | number of seconds | 1
`nodeSelector` | node labels for pod assignment | `{}`
`podAnnotations` | annotations to add to each pod | `{}`
`podLabels` | additional labesl to add to each pod | `{}`
`podDisruptionBudget.enabled`| Enabled creation of PodDisruptionBudget (only if replicaCount > 1) | true
`podDisruptionBudget.minAvailable`| minAvailable parameter for PodDisruptionBudget | 1
`podSecurityContext` | Kubernetes security context to apply to pod | `{}`
`priorityClassName` | priorityClassName | `nil`
`readinessProbe.enabled` | enable Kubernetes readinessProbe. Disable to use oauth2-proxy with Istio mTLS. See [Istio FAQ](https://istio.io/help/faq/security/#k8s-health-checks) | `true`
`readinessProbe.initialDelaySeconds` | number of seconds | 0
`readinessProbe.timeoutSeconds` | number of seconds | 1
`readinessProbe.periodSeconds` | number of seconds | 10
`readinessProbe.successThreshold` | number of successes | 1
`replicaCount` | desired number of pods | `1`
`resources` | pod resource requests & limits | `{}`
`service.portNumber` | port number for the service | `80`
`service.type` | type of service | `ClusterIP`
`service.clusterIP` | cluster ip address | `nil`
`service.loadBalancerIP` | ip of load balancer | `nil`
`service.loadBalancerSourceRanges` | allowed source ranges in load balancer | `nil`
`serviceAccount.enabled` | create a service account | `true`
`serviceAccount.name` | the service account name | ``
`serviceAccount.annotations` | (optional) annotations for the service account | `{}`
`tolerations` | list of node taints to tolerate | `[]`
`securityContext.enabled` | enable Kubernetes security context on container | `false`
`securityContext.runAsNonRoot` | make sure that the container runs as a non-root user | `true`
`proxyVarsAsSecrets` | choose between environment values or secrets for setting up OAUTH2_PROXY variables. When set to false, remember to add the variables OAUTH2_PROXY_CLIENT_ID, OAUTH2_PROXY_CLIENT_SECRET, OAUTH2_PROXY_COOKIE_SECRET in extraEnv | `true`
`sessionStorage.type` | Session storage type which can be one of the following: cookie or redis | `cookie`
`sessionStorage.redis.existingSecret` | existing Kubernetes secret to use for redis-password and redis-sentinel-password | `""`
`sessionStorage.redis.password` | Redis password. Applicable for all Redis configurations | `nil`
`sessionStorage.redis.clientType` | Allows the user to select which type of client will be used for redis instance. Possible options are: `sentinel`, `cluster` or `standalone` | `standalone`
`sessionStorage.redis.standalone.connectionUrl` | URL of redis standalone server for redis session storage (e.g. redis://HOST[:PORT]). Automatically generated if not set. | `""`
`sessionStorage.redis.cluster.connectionUrls` | List of Redis cluster connection URLs (e.g. redis://HOST[:PORT]) | `[]`
`sessionStorage.redis.sentinel.password` | Redis sentinel password. Used only for sentinel connection; any redis node passwords need to use `sessionStorage.redis.password` | `nil`
`sessionStorage.redis.sentinel.masterName` | Redis sentinel master name | `nil`
`sessionStorage.redis.sentinel.connectionUrls` | List of Redis sentinel connection URLs (e.g. redis://HOST[:PORT]) | `[]`
`redis.enabled` | Enable the redis subchart deployment | `false`
`checkDeprecation` | Enable deprecation checks | `true`
`metrics.enabled` | Enable Prometheus metrics endpoint | `true`
`metrics.port` | Serve Prometheus metrics on this port | `44180`
`metrics.servicemonitor.enabled` | Enable Prometheus Operator ServiceMonitor | `false`
`metrics.servicemonitor.namespace` | Define the namespace where to deploy the ServiceMonitor resource | `""`
`metrics.servicemonitor.prometheusInstance` | Prometheus Instance definition  | `default`
`metrics.servicemonitor.interval` | Prometheus scrape interval | `60s`
`metrics.servicemonitor.scrapeTimeout` | Prometheus scrape timeout | `30s`
`metrics.servicemonitor.labels` | Add custom labels to the ServiceMonitor resource| `{}`

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
$ helm install my-release oauth2-proxy/oauth2-proxy \
  --set=image.tag=v0.0.2,resources.limits.cpu=200m
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
$ helm install my-release oauth2-proxy/oauth2-proxy -f values.yaml
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## TLS Configuration

See: [TLS Configuration](https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/tls).
Use ```values.yaml``` like:

```yaml
...
extraArgs:
  tls-cert-file: /path/to/cert.pem
  tls-key-file: /path/to/cert.key

extraVolumes:
  - name: ssl-cert
    secret:
      secretName: my-ssl-secret

extraVolumeMounts:
  - mountPath: /path/to/
    name: ssl-cert
...
```

With a secret called `my-ssl-secret`:

```yaml
...
data:
  cert.pem: AB..==
  cert.key: CD..==
```

## Extra environment variable templating
The extraEnv value supports the tpl function which evaluate strings as templates inside the deployment template.
This is useful to pass a template string as a value to the chart's extra environment variables and to render external configuration environment values


```yaml
...
tplValue: "This is a test value for the tpl function"
extraEnv:
  - name: TEST_ENV_VAR_1
    value: test_value_1
  - name: TEST_ENV_VAR_2
    value: '{{ .Values.tplValue }}'
```
