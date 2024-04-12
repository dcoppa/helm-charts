{{/* vim: set filetype=mustache: */}}

{{- define "kyverno.background-controller.name" -}}
{{ template "kyverno.name" . }}-bg-cntlr
{{- end -}}

{{- define "kyverno.background-controller.labels" -}}
{{- template "kyverno.labels.merge" (list
  (include "kyverno.labels.common" .)
  (include "kyverno.background-controller.matchLabels" .)
) -}}
{{- end -}}

{{- define "kyverno.background-controller.matchLabels" -}}
{{- template "kyverno.labels.merge" (list
  (include "kyverno.matchLabels.common" .)
  (include "kyverno.labels.component" "background-controller")
) -}}
{{- end -}}

{{- define "kyverno.background-controller.image" -}}
{{- $imageRegistry := default .image.registry .globalRegistry -}}
{{- if $imageRegistry -}}
  {{ $imageRegistry }}/{{ required "An image repository is required" .image.repository }}:{{ default .defaultTag .image.tag }}
{{- else -}}
  {{ required "An image repository is required" .image.repository }}:{{ default .defaultTag .image.tag }}
{{- end -}}
{{- end -}}

{{- define "kyverno.background-controller.roleName" -}}
{{- printf "%s-role-%s-%s-%s-%s" .Values.k8sPrefix .Values.customer .Values.purpose (include "kyverno.background-controller.name" .) .Values.stage -}}
{{- end -}}

{{- define "kyverno.background-controller.serviceAccountName" -}}
{{- if .Values.backgroundController.rbac.create -}}
    {{ default (include "kyverno.background-controller.name" .) .Values.backgroundController.rbac.serviceAccount.name }}
{{- else -}}
    {{ required "A service account name is required when `rbac.create` is set to `false`" .Values.backgroundController.rbac.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "kyverno.background-controller.caCertificatesConfigMapName" -}}
{{ printf "%s-cm-%s-%s-%s-ca-cert-%s" .Values.k8sPrefix .Values.customer .Values.purpose (include "kyverno.background-controller.name" .) .Values.stage }}
{{- end -}}
