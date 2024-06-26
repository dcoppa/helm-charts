{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "snapscheduler.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "snapscheduler.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "snapscheduler" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "snapscheduler-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "snapscheduler.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "snapscheduler.labels" -}}
helm.sh/chart: {{ include "snapscheduler.chart" . }}
{{ include "snapscheduler.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "snapscheduler.selectorLabels" -}}
app.kubernetes.io/name: {{ include "snapscheduler.name" . }}
app.kubernetes.io/instance: snapscheduler
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "snapscheduler.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (printf "%s-sa-%s-%s-%s-%s" .Values.k8sPrefix .Values.customer .Values.purpose (include "snapscheduler.fullname" .) .Values.stage) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "snapscheduler.image" -}}
{{- with .Values.image }}
{{- if .image -}}
{{ .image }}
{{- else -}}
{{ .repository }}:{{ default $.Chart.AppVersion .tagOverride }}
{{- end -}}
{{- end -}}
{{- end }}

{{- define "rbacproxy.image" -}}
{{- with .Values.rbacProxy.image }}
{{- if .image -}}
{{ .image }}
{{- else -}}
{{ .repository }}:{{ .tag }}
{{- end -}}
{{- end -}}
{{- end }}
