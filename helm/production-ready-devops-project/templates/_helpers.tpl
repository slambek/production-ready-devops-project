{{- define "devops-project.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "devops-project.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name (include "devops-project.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "devops-project.labels" -}}
app.kubernetes.io/name: {{ include "devops-project.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end }}

{{- define "devops-project.selectorLabels" -}}
app.kubernetes.io/name: {{ include "devops-project.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
