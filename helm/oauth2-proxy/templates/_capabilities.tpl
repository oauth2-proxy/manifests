{{/*
Returns the appropriate apiVersion for podDisruptionBudget object.
*/}}
{{- define "capabilities.podDisruptionBudget.apiVersion" -}}
{{- if semverCompare "<1.21-0" ( .Values.kubeVersion | default .Capabilities.KubeVersion.Version ) -}}
{{- print "policy/v1beta1" -}}
{{- else -}}
{{- print "policy/v1" -}}
{{- end -}}
{{- end -}}
