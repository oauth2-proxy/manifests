{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "oauth2-proxy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "oauth2-proxy.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "oauth2-proxy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Generate basic labels
*/}}
{{- define "oauth2-proxy.labels" }}
helm.sh/chart: {{ include "oauth2-proxy.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: authentication-proxy
app.kubernetes.io/part-of: {{ template "oauth2-proxy.name" . }}
{{- include "oauth2-proxy.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- if .Values.customLabels }}
{{ toYaml .Values.customLabels }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "oauth2-proxy.selectorLabels" }}
app.kubernetes.io/name: {{ include "oauth2-proxy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Get the secret name.
*/}}
{{- define "oauth2-proxy.secretName" -}}
{{- if .Values.config.existingSecret -}}
{{- printf "%s" .Values.config.existingSecret -}}
{{- else -}}
{{- printf "%s" (include "oauth2-proxy.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "oauth2-proxy.serviceAccountName" -}}
{{- if .Values.serviceAccount.enabled -}}
    {{ default (include "oauth2-proxy.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Compute the redis url if not set explicitly.
*/}}
{{- define "oauth2-proxy.redisStandaloneUrl" -}}
{{- $masterPort := .Values.redis.master.service.ports.redis -}}
{{- if .Values.sessionStorage.redis.standalone.connectionUrl -}}
{{ .Values.sessionStorage.redis.standalone.connectionUrl }}
{{- else if .Values.redis.fullnameOverride -}}
{{- printf "redis://%s-master:%.0f" (.Values.redis.fullnameOverride | trunc 63 | trimSuffix "-") $masterPort -}}
{{- else -}}
{{- $name := default "redis" .Values.redis.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "redis://%s-master:%.0f" (.Release.Name | trunc 63 | trimSuffix "-") $masterPort -}}
{{- else -}}
{{- printf "redis://%s-master:%.0f" (printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-") $masterPort -}}
{{- end -}}
{{- end -}}
{{- end -}}
