{{/*
Expand the name of the chart.
*/}}
{{- define "console-banner.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Select a deterministic color based on cluster name
*/}}
{{- define "console-banner.selectColor" -}}
{{- $clusterName := .clusterName | default "" }}
{{- $colors := list "#0066CC" "#CC0000" "#FFA500" "#00CC66" "#9933CC" "#FF3366" "#00CCCC" "#CC9900" "#006699" "#CC0066" }}
{{- if $clusterName }}
  {{- $nameLen := len $clusterName | int }}
  {{- $encoded := $clusterName | b64enc }}
  {{- $encodedLen := len $encoded | int }}
  {{- $sum := add $encodedLen $nameLen }}
  {{- $colorsLen := len $colors | int }}
  {{- $index := mod $sum $colorsLen }}
  {{- index $colors $index }}
{{- else }}
  {{- index $colors 0 }}
{{- end }}
{{- end }}
