{{- define "skygear.skygear-server.name" }}
{{- printf "%s-skygear-server" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "skygear.skygear-server.master.name" }}
{{- printf "%s-skygear-server-master" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "skygear.skygear-server.slave.name" }}
{{- printf "%s-skygear-server-slave" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "skygear.secret.name" }}
{{- printf "%s-secret" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "skygear.pgbouncer.name" }}
{{- printf "%s-pgbouncer" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "skygear.forgotpassword.name" }}
{{- printf "%s-forgotpassword" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "skygear.chat.name" }}
{{- printf "%s-chat" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "skygear.cms.name" }}
{{- printf "%s-cms" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "skygear.staticfiles.name" }}
{{- printf "%s-staticfiles" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "skygear.pluginpython.name" }}
{{- printf "%s-pluginpython" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "skygear.pluginnodejs.name" }}
{{- printf "%s-pluginnodejs" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "skygear.common.env-vars" }}
- name: APP_NAME
  value: {{ .Values.appName | quote }}
- name: LOG_LEVEL
  value: {{ .Values.skygearServer.logLevel | quote }}
- name: DEV_MODE
  value: {{ .Values.skygearServer.devMode | quote }}
- name: DB_IMPL_NAME
  value: "pq"
- name: TOKEN_STORE
  value: "jwt"
- name: ASSET_STORE
  value: "fs"
- name: API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "skygear.secret.name" . | quote }}
      key: API_KEY
- name: MASTER_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "skygear.secret.name" . | quote }}
      key: MASTER_KEY
- name: TOKEN_STORE_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "skygear.secret.name" . | quote }}
      key: TOKEN_STORE_SECRET
{{- if .Values.customTokenSecret }}
- name: CUSTOM_TOKEN_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "skygear.secret.name" . | quote }}
      key: CUSTOM_TOKEN_SECRET
{{- end }}
{{- if .Values.fcmSecretName }}
- name: FCM_SERVICE_ACCOUNT_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.fcmSecretName | quote }}
      key: FCM_SERVICE_ACCOUNT_KEY
{{- end }}
{{- if .Values.apnsSecretName }}
- name: APNS_CERTIFICATE
  valueFrom:
    secretKeyRef:
      name: {{ .Values.apnsSecretName | quote }}
      key: APNS_CERTIFICATE
- name: APNS_PRIVATE_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.apnsSecretName | quote }}
      key: APNS_PRIVATE_KEY
{{- end }}
{{- end }}

{{- define "skygear.skygear-server.env-vars" }}
- name: DATABASE_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "skygear.secret.name" . | quote }}
      key: DATABASE_URL_SESSION
{{- $plugins := (list) }}
{{- if .Values.forgotpassword.enabled }}
{{- $plugins = append $plugins "forgotpassword" }}
- name: forgotpassword_TRANSPORT
  value: http
- name: forgotpassword_PATH
  value: http://{{ include "skygear.forgotpassword.name" . }}:5000
{{- end }}
{{- if .Values.cms.enabled }}
{{- $plugins = append $plugins "cms" }}
- name: cms_TRANSPORT
  value: http
- name: cms_PATH
  value: http://{{ include "skygear.cms.name" . }}:5001
{{- end }}
{{- if .Values.chat.enabled }}
{{- $plugins = append $plugins "chat" }}
- name: chat_TRANSPORT
  value: http
- name: chat_PATH
  value: http://{{ include "skygear.chat.name" . }}:5002
{{- end }}
{{- if .Values.pluginpython.enabled }}
{{- $plugins = append $plugins "pluginpython" }}
- name: pluginpython_TRANSPORT
  value: http
- name: pluginpython_PATH
  value: http://{{ include "skygear.pluginpython.name" . }}:5003
{{- end }}
{{- if .Values.pluginnodejs.enabled }}
{{- $plugins = append $plugins "pluginnodejs" }}
- name: pluginnodejs_TRANSPORT
  value: http
- name: pluginnodejs_PATH
  value: http://{{ include "skygear.pluginnodejs.name" . }}:5004
{{- end }}
{{- if not (empty $plugins) }}
- name: PLUGINS
  value: {{ join "," $plugins }}
{{- end }}
{{- end }}

{{- define "skygear.plugin.env-vars" }}
- name: HTTP
  value: "true"
- name: SKYGEAR_ENDPOINT
  value: http://{{ include "skygear.skygear-server.name" . }}:3000
- name: DATABASE_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "skygear.secret.name" . | quote }}
      key: DATABASE_URL_TRANSACTION
{{- end }}

{{- define "skygear.skygear-server.service.ports" }}
- name: http
  protocol: TCP
  port: 3000
  targetPort: http
- name: forgotpassword
  protocol: TCP
  port: 5000
  targetPort: forgotpassword
- name: cms
  protocol: TCP
  port: 5001
  targetPort: cms
- name: chat
  protocol: TCP
  port: 5002
  targetPort: chat
- name: pluginpython
  protocol: TCP
  port: 5003
  targetPort: pluginpython
- name: pluginnodejs
  protocol: TCP
  port: 5004
  targetPort: pluginnodejs
{{- end }}

{{- define "skygear.skygear-server.ports" }}
- name: http
  protocol: TCP
  containerPort: 3000
- name: forgotpassword
  protocol: TCP
  containerPort: 5000
- name: cms
  protocol: TCP
  containerPort: 5001
- name: chat
  protocol: TCP
  containerPort: 5002
- name: pluginpython
  protocol: TCP
  containerPort: 5003
- name: pluginnodejs
  protocol: TCP
  containerPort: 5004
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "skygear.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "skygear.fullname" -}}
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
{{- define "skygear.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "skygear.labels" -}}
helm.sh/chart: {{ include "skygear.chart" . }}
{{ include "skygear.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "skygear.selectorLabels" -}}
app.kubernetes.io/name: {{ include "skygear.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
