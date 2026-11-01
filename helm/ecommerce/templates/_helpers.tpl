{{/* Labels on every object. */}}
{{- define "ecommerce.labels" -}}
app.kubernetes.io/part-of: mern-shop
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{/* The commit SHA is required, so a deployment can always be traced to its commit. */}}
{{- define "ecommerce.tag" -}}
{{- required "set image.tag to the commit SHA of the images" .Values.image.tag -}}
{{- end }}

{{/* Container hardening shared by the API and Nginx. */}}
{{- define "ecommerce.containerSecurity" -}}
allowPrivilegeEscalation: false
readOnlyRootFilesystem: true
capabilities:
  drop: ["ALL"]
{{- end }}
