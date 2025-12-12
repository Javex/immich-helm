{{/*
Expand the name of the chart.
*/}}
{{- define "immich.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "immich.fullname" -}}
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
{{- define "immich.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Labels for all resources that are shared between components
*/}}
{{- define "immich.labels" -}}
{{ include "immich.commonLabels" . }}
{{ include "immich.commonSelectorLabels" . }}
{{- end }}

{{/*
Common labels. Not meant to be included directly, but used by the other
helpers.
*/}}
{{- define "immich.commonLabels" -}}
helm.sh/chart: {{ include "immich.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common selector labels. Not meant to be included directly, but used by the
other helpers.
*/}}
{{- define "immich.commonSelectorLabels" -}}
app.kubernetes.io/name: {{ include "immich.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Server labels to apply to server-specific resources (e.g. Deployment).
*/}}
{{- define "immich.serverLabels" -}}
{{ include "immich.commonLabels" . }}
{{ include "immich.serverSelectorLabels" . }}
{{- end }}

{{/*
Server selector labels to apply anywhere you need a selector for
server-specific resources (e.g. Service or Deployment selectors).
*/}}
{{- define "immich.serverSelectorLabels" -}}
{{ include "immich.commonSelectorLabels" . }}
app.kubernetes.io/component: server
{{- end }}

{{/*
Machine learning labels
*/}}
{{- define "immich.machineLearningLabels" -}}
{{ include "immich.commonLabels" . }}
{{ include "immich.machineLearningSelectorLabels" . }}
{{- end }}

{{/*
Machine learning selector labels
*/}}
{{- define "immich.machineLearningSelectorLabels" -}}
{{ include "immich.commonSelectorLabels" . }}
app.kubernetes.io/component: machine-learning
{{- end }}

{{/*
Return the correct PVC claimName based on whether the user specified an
existing claim or not
*/}}
{{- define "immich.persistence.claimName" }}
{{- if .Values.persistence.existingClaim }}
{{- .Values.persistence.existingClaim }}
{{- else }}
{{- include "immich.fullname" . }}-server
{{- end }}
{{- end }}

{{/*
Return contents of the config
*/}}
{{- define "immich.serverConfig" }}
immich-config.yaml: |
  {{ tpl (toYaml .Values.server.configuration) . | nindent 2 }}
{{- end }}

{{/*
Return contents of the secret used for environment variables
*/}}
{{- define "immich.secretEnv" }}
REDIS_HOSTNAME: {{ (include "valkey.fullname" .Subcharts.valkey ) | b64enc }}
{{- if .Values.postgres.enabled }}
DB_HOSTNAME: {{ printf "%s-%s" (include "immich.fullname" .) "database" | b64enc }}
{{- else }}
  {{- if .Values.database.host }}
DB_HOSTNAME: {{ .Values.database.host | b64enc }}
  {{- else }}
  {{ fail "Must provide database.host if using external database" }}
  {{- end }}
{{- end }}
DB_USERNAME: {{ .Values.database.username | b64enc }}
DB_PASSWORD: {{ .Values.database.password | b64enc }}
DB_DATABASE_NAME: {{ .Values.database.name | b64enc }}
{{- range $key, $value := .Values.env }}
{{ $key }}: {{ $value | b64enc }}
{{- end }}
{{- end }}
