{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "orchestrator.computedValues" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: values-debug
data:
  debug: 1
  values: |
    {{- toYaml .Values | nindent 4 }}
  release: |
    {{- toYaml .Release | nindent 4 }}
  chart: |
    {{- toYaml .Chart | nindent 4 }}
{{ end -}}
