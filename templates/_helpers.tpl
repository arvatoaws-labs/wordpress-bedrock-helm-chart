{{/*
Expand the name of the chart.
*/}}
{{- define "wordpress-bedrock.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "wordpress-bedrock.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "wordpress-bedrock.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "wordpress-bedrock.labels" -}}
helm.sh/chart: {{ include "wordpress-bedrock.chart" . }}
{{ include "wordpress-bedrock.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "wordpress-bedrock.selectorLabels" -}}
app.kubernetes.io/name: {{ include "wordpress-bedrock.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Toleration and Node Selector for selecting dedicated arch nodes
*/}}
{{- define "wordpress-bedrock.archSelector" -}}
{{- if eq .Values.karpenter.arch "arm64" }}
nodeSelector:
  karpenter.io/arch: {{ .Values.karpenter.arch }}
{{- end }}
{{- if not (eq .Values.karpenter.arch "amd64") }}
tolerations:
- effect: NoSchedule
  key: arch
  operator: Equal
  value: arm64
{{- end }}
{{- end }}

{{/*
Toleration and Node Selector for selecting dedicated cron nodes
*/}}
{{- define "wordpress-bedrock.cronSelector" -}}
nodeSelector:
  karpenter.sh/nodepool: {{ .Values.karpenter.cron.nodePoolPrefix }}{{ .Values.karpenter.arch | default "arm64" }}
tolerations:
- effect: NoSchedule
  key: nodepool
  operator: Equal
  value: {{ .Values.karpenter.cron.nodePoolPrefix }}{{ .Values.karpenter.arch | default "arm64" }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "wordpress-bedrock.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default .Release.Name .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "wordpress-bedrock.efsSubPath" -}}
{{- default .Release.Name .Values.efs.subPath | trunc 63 | trimSuffix "-" -}}
{{- end -}}
