{{/*
Default always defined top-level variables for helm charts
*/}}
{{- define "clustergroup.app.globalvalues.helmparameters" -}}
- name: global.repoURL
  value: $ARGOCD_APP_SOURCE_REPO_URL
- name: global.targetRevision
  value: $ARGOCD_APP_SOURCE_TARGET_REVISION
- name: global.namespace
  value: $ARGOCD_APP_NAMESPACE
- name: global.pattern
  value: {{ $.Values.global.pattern }}
- name: global.clusterDomain
  value: {{ $.Values.global.clusterDomain }}
- name: global.clusterVersion
  value: "{{ $.Values.global.clusterVersion }}"
- name: global.clusterPlatform
  value: "{{ $.Values.global.clusterPlatform }}"
- name: global.hubClusterDomain
  value: {{ $.Values.global.hubClusterDomain }}
- name: global.localClusterDomain
  value: {{ coalesce $.Values.global.localClusterDomain $.Values.global.hubClusterDomain }}
- name: global.privateRepo
  value: {{ $.Values.global.privateRepo | quote }}
{{- end }} {{/* clustergroup.globalvaluesparameters */}}


{{/*
Default always defined valueFiles to be included in Applications
*/}}
{{- define "clustergroup.app.globalvalues.valuefiles" -}}
- "/values-global.yaml"
- "/values-{{ $.Values.clusterGroup.name }}.yaml"
{{- if $.Values.global.clusterPlatform }}
- "/values-{{ $.Values.global.clusterPlatform }}.yaml"
  {{- if $.Values.global.clusterVersion }}
- "/values-{{ $.Values.global.clusterPlatform }}-{{ $.Values.global.clusterVersion }}.yaml"
  {{- end }}
- "/values-{{ $.Values.global.clusterPlatform }}-{{ $.Values.clusterGroup.name }}.yaml"
{{- end }}
{{- if $.Values.global.clusterVersion }}
- "/values-{{ $.Values.global.clusterVersion }}-{{ $.Values.clusterGroup.name }}.yaml"
{{- end }}
{{- if $.Values.global.extraValueFiles }}
{{- range $.Values.global.extraValueFiles }}
- {{ . | quote }}
{{- end }} {{/* range $.Values.global.extraValueFiles */}}
{{- end }} {{/* if $.Values.global.extraValueFiles */}}
{{- end }} {{/* clustergroup.app.globalvalues.valuefiles */}}

{{/*
Default always defined valueFiles to be included in Applications but with a prefix called $patternref
*/}}
{{- define "clustergroup.app.globalvalues.prefixedvaluefiles" -}}
- "$patternref/values-global.yaml"
- "$patternref/values-{{ $.Values.clusterGroup.name }}.yaml"
{{- if $.Values.global.clusterPlatform }}
- "$patternref/values-{{ $.Values.global.clusterPlatform }}.yaml"
  {{- if $.Values.global.clusterVersion }}
- "$patternref/values-{{ $.Values.global.clusterPlatform }}-{{ $.Values.global.clusterVersion }}.yaml"
  {{- end }}
- "$patternref/values-{{ $.Values.global.clusterPlatform }}-{{ $.Values.clusterGroup.name }}.yaml"
{{- end }}
{{- if $.Values.global.clusterVersion }}
- "$patternref/values-{{ $.Values.global.clusterVersion }}-{{ $.Values.clusterGroup.name }}.yaml"
{{- end }}
{{- if $.Values.global.extraValueFiles }}
{{- range $.Values.global.extraValueFiles }}
- "$patternref/{{ . }}"
{{- end }} {{/* range $.Values.global.extraValueFiles */}}
{{- end }} {{/* if $.Values.global.extraValueFiles */}}
{{- end }} {{/* clustergroup.app.globalvalues.prefixedvaluefiles */}}

{{- /* Helper function to generate AppProject from a map object */ -}}
{{- /* Called from common/clustergroup/templates/plumbing/projects.yaml */ -}}
{{- define "clustergroup.template.plumbing.projects.map" -}}
{{- $temp := index . 0 }}
{{- $projects := index $temp 0 }}
{{- $namespace := index . 1 }}
{{- $enabled := index . 2 }}
{{- range $k, $v := $projects}}
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: {{ $k }}
{{- if (eq $enabled "plumbing") }}
  namespace: openshift-gitops
{{- else }}
  namespace: {{ $namespace }}
{{- end }}
spec:
  description: "Pattern {{ . }}"
  destinations:
  - namespace: '*'
    server: '*'
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
  namespaceResourceWhitelist:
  - group: '*'
    kind: '*'
  sourceRepos:
  - '*'
status: {}
---
{{- end }}
{{- end }}

{{- /* Helper function to generate AppProject from a list object */ -}}
{{- /* Called from common/clustergroup/templates/plumbing/projects.yaml */ -}}
{{- define "clustergroup.template.plumbing.projects.list" -}}
{{- $temp := index . 0 }}
{{- $projects := index $temp 0 }}
{{- $namespace := index . 1 }}
{{- $enabled := index . 2 }}
{{- range $projects}}
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: {{ . }}
{{- if (eq $enabled "plumbing") }}
  namespace: openshift-gitops
{{- else }}
  namespace: {{ $namespace }}
{{- end }}
spec:
  description: "Pattern {{ . }}"
  destinations:
  - namespace: '*'
    server: '*'
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
  namespaceResourceWhitelist:
  - group: '*'
    kind: '*'
  sourceRepos:
  - '*'
status: {}
{{- end }}
{{- end }}

{{- /* Helper function to generate namespace from a list object */ -}}
{{- define "clustergroup.template.core.namespaces.list" -}}
{{- $tempns := index . 0}}
{{- $clusterGroupName := index . 1}}
{{- $patternName := index . 2}}
{{- range $ns := $tempns }}
apiVersion: v1
kind: Namespace
metadata:
  {{- if kindIs "map" $ns }}
  {{- range $k, $v := $ns }}{{- /* We loop here even though the map has always just one key */}}
  name: {{ $k }}
  labels:
    argocd.argoproj.io/managed-by: {{ $patternName }}-{{ $clusterGroupName }}
    {{- if $v.labels }}
    {{- range $key, $value := $v.labels }} {{- /* We loop here even though the map has always just one key */}}
    {{ $key }}: {{ $value | default "" | quote }}
    {{- end }}
    {{- end }}
  {{- if $v.annotations }}
  annotations:
    {{- range $key, $value := $v.annotations }} {{- /* We loop through the map to get key/value pairs */}}
    {{ $key }}: {{ $value | default "" | quote }}
    {{- end }}
  {{- end }}{{- /* if $v.annotations */}}
  {{- end }}{{- /* range $k, $v := $ns */}}

  {{- else if kindIs "string" $ns }}
  labels:
    argocd.argoproj.io/managed-by: {{ $patternName }}-{{ $clusterGroupName }}
  name: {{ $ns }}
  {{- end }} {{- /* if kindIs "string" $ns */}}
spec:
---
{{- end }}
{{- end }}
