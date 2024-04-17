{{/*
Copyright VMware, Inc.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/*
Return the proper ZooKeeper image name
*/}}
{{- define "zookeeper.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "zookeeper.volumePermissions.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.volumePermissions.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "zookeeper.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.volumePermissions.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Check if there are rolling tags in the images
*/}}
{{- define "zookeeper.checkRollingTags" -}}
{{- include "common.warnings.rollingTag" .Values.image }}
{{- include "common.warnings.rollingTag" .Values.volumePermissions.image }}
{{- end -}}

{{/*
Return ZooKeeper Namespace to use
*/}}
{{- define "zookeeper.namespace" -}}
{{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
{{- else -}}
    {{- .Release.Namespace -}}
{{- end -}}
{{- end -}}

{{/*
 Create the name of the service account to use
 */}}
{{- define "zookeeper.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the ZooKeeper client-server authentication credentials secret
*/}}
{{- define "zookeeper.client.secretName" -}}
{{- if .Values.auth.client.existingSecret -}}
    {{- printf "%s" (tpl .Values.auth.client.existingSecret $) -}}
{{- else -}}
    {{- printf "%s-secret-%s-%s-%s-client-auth-%s" .Values.k8sPrefix .Values.customer .Values.purpose (include "common.names.fullname" .) .Values.stage -}}
{{- end -}}
{{- end -}}

{{/*
Return the ZooKeeper server-server authentication credentials secret
*/}}
{{- define "zookeeper.quorum.secretName" -}}
{{- if .Values.auth.quorum.existingSecret -}}
    {{- printf "%s" (tpl .Values.auth.quorum.existingSecret $) -}}
{{- else -}}
    {{- printf "%s-secret-%s-%s-%s-quorum-auth-%s" .Values.k8sPrefix .Values.customer .Values.purpose (include "common.names.fullname" .) .Values.stage -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a ZooKeeper client-server authentication credentials secret object should be created
*/}}
{{- define "zookeeper.client.createSecret" -}}
{{- if and .Values.auth.client.enabled (empty .Values.auth.client.existingSecret) -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a ZooKeeper server-server authentication credentials secret object should be created
*/}}
{{- define "zookeeper.quorum.createSecret" -}}
{{- if and .Values.auth.quorum.enabled (empty .Values.auth.quorum.existingSecret) -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Returns the available value for certain key in an existing secret (if it exists),
otherwise it generates a random value.
*/}}
{{- define "getValueFromSecret" }}
    {{- $len := (default 16 .Length) | int -}}
    {{- $obj := (lookup "v1" "Secret" .Namespace .Name).data -}}
    {{- if $obj }}
        {{- index $obj .Key | b64dec -}}
    {{- else -}}
        {{- randAlphaNum $len -}}
    {{- end -}}
{{- end }}

{{/*
Return the ZooKeeper configuration ConfigMap name
*/}}
{{- define "zookeeper.configmapName" -}}
{{- if .Values.existingConfigmap -}}
    {{- printf "%s" (tpl .Values.existingConfigmap $) -}}
{{- else -}}
    {{- printf "%s-cm-%s-%s-%s-%s" .Values.k8sPrefix .Values.customer .Values.purpose (include "common.names.fullname" .) .Values.stage -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a ConfigMap object should be created for ZooKeeper configuration
*/}}
{{- define "zookeeper.createConfigmap" -}}
{{- if and .Values.configuration (not .Values.existingConfigmap) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a TLS secret should be created for ZooKeeper quorum
*/}}
{{- define "zookeeper.quorum.createTlsSecret" -}}
{{- if and .Values.tls.quorum.enabled .Values.tls.quorum.autoGenerated (not .Values.tls.quorum.existingSecret) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret containing ZooKeeper quorum TLS certificates
*/}}
{{- define "zookeeper.quorum.tlsSecretName" -}}
{{- $secretName := .Values.tls.quorum.existingSecret -}}
{{- if $secretName -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s-secret-%s-%s-%s-quorum-crt-%s" .Values.k8sPrefix .Values.customer .Values.purpose (include "common.names.fullname" .) .Values.stage -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a secret containing the Keystore and Truststore password should be created for ZooKeeper quorum
*/}}
{{- define "zookeeper.quorum.createTlsPasswordsSecret" -}}
{{- if and .Values.tls.quorum.enabled (not .Values.tls.quorum.passwordsSecretName) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the name of the secret containing the Keystore and Truststore password
*/}}
{{- define "zookeeper.quorum.tlsPasswordsSecret" -}}
{{- $secretName := .Values.tls.quorum.passwordsSecretName -}}
{{- if $secretName -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s-secret-%s-%s-%s-quorum-tls-pass-%s" .Values.k8sPrefix .Values.customer .Values.purpose (include "common.names.fullname" .) .Values.stage -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a TLS secret should be created for ZooKeeper client
*/}}
{{- define "zookeeper.client.createTlsSecret" -}}
{{- if and .Values.tls.client.enabled .Values.tls.client.autoGenerated (not .Values.tls.client.existingSecret) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret containing ZooKeeper client TLS certificates
*/}}
{{- define "zookeeper.client.tlsSecretName" -}}
{{- $secretName := .Values.tls.client.existingSecret -}}
{{- if $secretName -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s-secret-%s-%s-%s-client-crt-%s" .Values.k8sPrefix .Values.customer .Values.purpose (include "common.names.fullname" .) .Values.stage -}}
{{- end -}}
{{- end -}}

{{/*
Get the quorum keystore key to be retrieved from tls.quorum.existingSecret.
*/}}
{{- define "zookeeper.quorum.tlsKeystoreKey" -}}
{{- if and .Values.tls.quorum.existingSecret .Values.tls.quorum.existingSecretKeystoreKey -}}
    {{- printf "%s" .Values.tls.quorum.existingSecretKeystoreKey -}}
{{- else -}}
    {{- printf "zookeeper.keystore.jks" -}}
{{- end -}}
{{- end -}}

{{/*
Get the quorum truststore key to be retrieved from tls.quorum.existingSecret.
*/}}
{{- define "zookeeper.quorum.tlsTruststoreKey" -}}
{{- if and .Values.tls.quorum.existingSecret .Values.tls.quorum.existingSecretTruststoreKey -}}
    {{- printf "%s" .Values.tls.quorum.existingSecretTruststoreKey -}}
{{- else -}}
    {{- printf "zookeeper.truststore.jks" -}}
{{- end -}}
{{- end -}}

{{/*
Get the client keystore key to be retrieved from tls.client.existingSecret.
*/}}
{{- define "zookeeper.client.tlsKeystoreKey" -}}
{{- if and .Values.tls.client.existingSecret .Values.tls.client.existingSecretKeystoreKey -}}
    {{- printf "%s" .Values.tls.client.existingSecretKeystoreKey -}}
{{- else -}}
    {{- printf "zookeeper.keystore.jks" -}}
{{- end -}}
{{- end -}}

{{/*
Get the client truststore key to be retrieved from tls.client.existingSecret.
*/}}
{{- define "zookeeper.client.tlsTruststoreKey" -}}
{{- if and .Values.tls.client.existingSecret .Values.tls.client.existingSecretTruststoreKey -}}
    {{- printf "%s" .Values.tls.client.existingSecretTruststoreKey -}}
{{- else -}}
    {{- printf "zookeeper.truststore.jks" -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a secret containing the Keystore and Truststore password should be created for ZooKeeper client
*/}}
{{- define "zookeeper.client.createTlsPasswordsSecret" -}}
{{- if and .Values.tls.client.enabled (not .Values.tls.client.passwordsSecretName) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the name of the secret containing the Keystore and Truststore password
*/}}
{{- define "zookeeper.client.tlsPasswordsSecret" -}}
{{- $secretName := .Values.tls.client.passwordsSecretName -}}
{{- if $secretName -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s-secret-%s-%s-%s-client-tls-pass-%s" .Values.k8sPrefix .Values.customer .Values.purpose (include "common.names.fullname" .) .Values.stage -}}
{{- end -}}
{{- end -}}

{{/*
Get the quorum keystore password key to be retrieved from tls.quorum.passwordSecretName.
*/}}
{{- define "zookeeper.quorum.tlsPasswordKeystoreKey" -}}
{{- if and .Values.tls.quorum.passwordsSecretName .Values.tls.quorum.passwordsSecretKeystoreKey -}}
    {{- printf "%s" .Values.tls.quorum.passwordsSecretKeystoreKey -}}
{{- else -}}
    {{- printf "keystore-password" -}}
{{- end -}}
{{- end -}}

{{/*
Get the quorum truststore password key to be retrieved from tls.quorum.passwordSecretName.
*/}}
{{- define "zookeeper.quorum.tlsPasswordTruststoreKey" -}}
{{- if and .Values.tls.quorum.passwordsSecretName .Values.tls.quorum.passwordsSecretTruststoreKey -}}
    {{- printf "%s" .Values.tls.quorum.passwordsSecretTruststoreKey -}}
{{- else -}}
    {{- printf "truststore-password" -}}
{{- end -}}
{{- end -}}

{{/*
Get the client keystore password key to be retrieved from tls.client.passwordSecretName.
*/}}
{{- define "zookeeper.client.tlsPasswordKeystoreKey" -}}
{{- if and .Values.tls.client.passwordsSecretName .Values.tls.client.passwordsSecretKeystoreKey -}}
    {{- printf "%s" .Values.tls.client.passwordsSecretKeystoreKey -}}
{{- else -}}
    {{- printf "keystore-password" -}}
{{- end -}}
{{- end -}}

{{/*
Get the client truststore password key to be retrieved from tls.client.passwordSecretName.
*/}}
{{- define "zookeeper.client.tlsPasswordTruststoreKey" -}}
{{- if and .Values.tls.client.passwordsSecretName .Values.tls.client.passwordsSecretTruststoreKey -}}
    {{- printf "%s" .Values.tls.client.passwordsSecretTruststoreKey -}}
{{- else -}}
    {{- printf "truststore-password" -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "zookeeper.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "zookeeper.validateValues.client.auth" .) -}}
{{- $messages := append $messages (include "zookeeper.validateValues.quorum.auth" .) -}}
{{- $messages := append $messages (include "zookeeper.validateValues.client.tls" .) -}}
{{- $messages := append $messages (include "zookeeper.validateValues.quorum.tls" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/*
Validate values of ZooKeeper - Authentication enabled
*/}}
{{- define "zookeeper.validateValues.client.auth" -}}
{{- if and .Values.auth.client.enabled (not .Values.auth.client.existingSecret) (or (not .Values.auth.client.clientUser) (not .Values.auth.client.serverUsers)) }}
zookeeper: auth.client.enabled
    In order to enable client-server authentication, you need to provide the list
    of users to be created and the user to use for clients authentication.
{{- end -}}
{{- end -}}

{{/*
Validate values of ZooKeeper - Authentication enabled
*/}}
{{- define "zookeeper.validateValues.quorum.auth" -}}
{{- if and .Values.auth.quorum.enabled (not .Values.auth.quorum.existingSecret) (or (not .Values.auth.quorum.learnerUser) (not .Values.auth.quorum.serverUsers)) }}
zookeeper: auth.quorum.enabled
    In order to enable server-server authentication, you need to provide the list
    of users to be created and the user to use for quorum authentication.
{{- end -}}
{{- end -}}

{{/*
Validate values of ZooKeeper - Client TLS enabled
*/}}
{{- define "zookeeper.validateValues.client.tls" -}}
{{- if and .Values.tls.client.enabled (not .Values.tls.client.autoGenerated) (not .Values.tls.client.existingSecret) }}
zookeeper: tls.client.enabled
    In order to enable Client TLS encryption, you also need to provide
    an existing secret containing the Keystore and Truststore or
    enable auto-generated certificates.
{{- end -}}
{{- end -}}

{{/*
Validate values of ZooKeeper - Quorum TLS enabled
*/}}
{{- define "zookeeper.validateValues.quorum.tls" -}}
{{- if and .Values.tls.quorum.enabled (not .Values.tls.quorum.autoGenerated) (not .Values.tls.quorum.existingSecret) }}
zookeeper: tls.quorum.enabled
    In order to enable Quorum TLS, you also need to provide
    an existing secret containing the Keystore and Truststore or
    enable auto-generated certificates.
{{- end -}}
{{- end -}}
