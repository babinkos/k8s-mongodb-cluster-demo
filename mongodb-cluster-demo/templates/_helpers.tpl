{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mongodb-cluster-demo.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mongodb-cluster-demo.fullname" -}}
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
{{- define "mongodb-cluster-demo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "mongodb-cluster-demo.labels" -}}
helm.sh/chart: {{ include "mongodb-cluster-demo.chart" . }}
{{ include "mongodb-cluster-demo.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "mongodb-cluster-demo.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mongodb-cluster-demo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "mongodb-cluster-demo.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "mongodb-cluster-demo.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the configdb replica info
*/}}
{{- define "mongodb-cluster-demo.configstr" -}}
{{- $confstr := printf "%s/" .Values.config_rs -}}
{{- $name := (include "mongodb-cluster-demo.fullname" . ) -}}
{{- $port := ( .Values.service.cfg.ports.port | int ) -}}
{{- range $i, $e := until ( .Values.replicas.cfg.count | int ) -}}
    {{- $confstr = printf "%s%s," $confstr ( printf "%s-cfg-%d.%s-cfgsvc.%s.svc.cluster.local:%d" $name $i $name $.Release.Namespace $port ) -}}
{{- end -}}
{{-  $confstr | trimSuffix "," -}}
{{- end -}}

{{/*
Create the db replica info
*/}}
{{- define "mongodb-cluster-demo.dbstr" -}}
{{- $shIndex := ( .shardIndex | int ) -}}
{{- $confstr := printf "%s%d/" .Values.db_rs $shIndex }}
{{- $name := (include "mongodb-cluster-demo.fullname" . ) -}}
{{- $port := ( .Values.service.db.ports.port | int ) -}}
{{- range $i, $e := until ( .Values.replicas.db.count | int ) -}}
    {{- $confstr = printf "%s%s," $confstr ( printf "%s-shard%d-db-%d.%s-shard%d-dbsvc.%s.svc.cluster.local:%d" $name $shIndex $i $name $shIndex $.Release.Namespace $port ) -}}
{{- end -}}
{{-  $confstr | trimSuffix "," -}}
{{- end -}}