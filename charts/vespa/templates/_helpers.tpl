# Copyright (c) Walmart Inc.

# This source code is licensed under the Apache 2.0 license found in the
# LICENSE file in the root directory of this source tree.
{{- define "pdbMinPods" -}}
{{- $currentReplicas := index . 0 }}
{{- $minPodsPercentage := index . 1 }}
{{- $minPodsCount := index . 2 }}
{{- if ( gt ( int $currentReplicas ) ( int 5 ) ) -}}
{{ $minPodsPercentage }}
{{- else if and ( gt ( int $currentReplicas ) ( int 2 ) ) ( le ( int $currentReplicas ) ( int 5 ) ) -}}
{{- if eq (int $currentReplicas) (int $minPodsCount) -}}
{{- fail "When less than 5 replicas, replica must be greater than minPodsCount" -}}
{{- end -}}
{{ $minPodsCount }}
{{- else -}}
{{ "1" }}
{{- end -}}
{{- end -}}

{{- define "dnsHostname" -}}
{{ .Values.clusterName }}-{{ .Values.deployEnv }}.{{ .Values.dnsSuffix }}
{{- end -}}

{{- define "vespaConfigServers" -}}
{{ range untilStep 0 ( .Values.configserver.replicas | int) 1 }}
{{- if . -}}
,
{{- end -}}
config-{{ . }}.config-hs.{{ $.Values.namespace }}.svc.cluster.local
{{- end -}}
{{- end -}}

{{- define "vespaHosts" -}}
  {{- $service := index . 0 }}
  {{- $replicas := index . 1 }}
  {{- $ := index . 2 }}
  {{- range untilStep 0 ( $replicas | int) 1 }}
      <host name="{{ $service }}-{{ . }}.{{ $service }}-hs.{{ $.Values.namespace }}.svc.cluster.local">
        <alias>{{ $service }}-{{ . }}</alias>
      </host>
  {{- end -}}
{{- end -}}


{{- define "hostAliases" -}}
  {{- $element := index . 0 }}
  {{- $service := index . 1 }}
  {{- $replicas := index . 2 }}
  {{- $ := index . 3 }}
  {{- range untilStep 0 ( $replicas | int) 1 }}
    {{- if eq $service "content" }}
              <{{ $element }} hostalias="{{ $service }}-{{ . }}" distribution-key="{{ . }}" />
    {{- else }}
              <{{ $element }} hostalias="{{ $service }}-{{ . }}" />         
    {{- end }}
  {{- end -}}
{{- end -}}

{{- define "contentStart" -}}
{{- $schemaName := index . 0 }}
{{- $schemaProperties := index . 1 }}
<content id="{{ $schemaName }}" version="1.0">
  <redundancy>{{ $schemaProperties.replicas }}</redundancy>
  <documents {{ if $schemaProperties.garbageCollection }}garbage-collection="true"{{end}} >
      <document type="{{ $schemaName }}" mode="index" {{ if $schemaProperties.selection }}selection="{{ $schemaProperties.selection }}"{{end}} />
      <document-processing cluster="feed" />
  </documents>
{{- end -}}

{{- define "contentEnd" -}}
{{- $root := index . 0 }}
{{- $schemaName := index . 1 }}
{{- $schemaProperties := index . 2 }}
  <engine>
    <proton>
      <searchable-copies>{{ if ($schemaProperties.dedicatedContentNodes).numberOfGroups }}{{ $schemaProperties.dedicatedContentNodes.numberOfGroups }}{{ else }}{{ $schemaProperties.replicas }}{{ end }}</searchable-copies>
      <tuning>
        <searchnode>
          <removed-db>
              <prune>
                  <age>{{ $root.contentserver.tuning.searchnode.removedDb.pruneAge }}</age>
              </prune>
          </removed-db>
          <lidspace>
              <max-bloat-factor>{{ $root.contentserver.tuning.searchnode.lidspace.maxBloatFactor }}</max-bloat-factor>
          </lidspace>
          <requestthreads>
              {{- $normalizedCpuCores := ( include "cpuCores" ( list $root.contentserver.resources.pod.limits.cpu ) ) }}
              <search>{{ round ( printf "%d.%02d" ( div ( mul $normalizedCpuCores 2 ) 1000) ( mod ( mul $normalizedCpuCores 2 ) 1000 ) | float64 ) 0 }}</search>
              <persearch>{{ $root.contentserver.tuning.searchnode.requestthreads.persearch | int }}</persearch>
              <summary>{{ round ( printf "%d.%02d" ( div $normalizedCpuCores 1000) ( mod $normalizedCpuCores 1000 ) | float64 ) 0 }}</summary>
          </requestthreads>
          <summary>
            <io>
              <read>directio</read>
            </io>
            <store>
              <cache>
                <maxsize-percent>{{ $root.contentserver.tuning.searchnode.summaryCachePercentage }}</maxsize-percent>
              </cache>
            </store>
          </summary>
        </searchnode>
      </tuning>
      <resource-limits>
        <disk>{{ $root.contentserver.proton.resourceLimits.disk }}</disk>
        <memory>{{ $root.contentserver.proton.resourceLimits.memory }}</memory>
      </resource-limits>
    </proton>
  </engine>
</content>
{{- end -}}

{{- define "contentDivisionAliases" -}}
  {{- $start := index . 0 }}
  {{- $end := index . 1 }}
  {{- $ := index . 2 }}
  {{- range untilStep ( $start | int) ( $end | int) 1 }}
              <node hostalias="content-{{ . }}" distribution-key="{{ . }}" />
  {{- end -}}
{{- end -}}

{{- define "cpuCores" }}
  {{- /* This will allow inputs of: integer, float, or millicpu format */ -}}
  {{- /* This will output millcpu count as an integer */ -}}
  {{- $cpuDefinition := index . 0 -}}

  {{- if and (kindIs "string" $cpuDefinition) (hasSuffix "m" ( toString $cpuDefinition ) ) -}}
    {{- trimSuffix "m" ( toString $cpuDefinition ) -}}
  {{- end -}}
  {{- if (kindIs "float64" $cpuDefinition) -}}
    {{- $splitArray := regexSplit "\\." (toString $cpuDefinition) 2 -}}
    {{ if gt (len $splitArray ) 1 }}{{- /* we have  floating point number  */ -}}
      {{- if eq ( len ( index $splitArray 1 ) ) 1 -}}
        {{- add (mul ( index $splitArray 0 ) 1000) (mul ( index $splitArray 1 ) 100) -}}
      {{- else if eq ( len ( index $splitArray 1 ) ) 2 -}}
        {{- add (mul ( index $splitArray 0 ) 1000) (mul ( index $splitArray 1 ) 10) -}}
      {{- else if eq ( len ( index $splitArray 1 ) ) 3 -}}
        {{- add (mul ( index $splitArray 0 ) 1000) (mul ( index $splitArray 1 ) 1) -}}
      {{- end -}}
    {{- else -}}
      {{- mul $cpuDefinition 1000 -}}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{- define "slobrokPorts" -}}
{{- /* ports needed: 19100-19899 */ -}}
{{- $ := index . 0 }}
{{- $podSpecCheck := index . 1 }}
{{- include "dynamicPort" (list $  $.Values.slobrok.ports.http.start $.Values.slobrok.ports.http.end "sb" $podSpecCheck ) }}
{{- end -}}

{{- define "protonPorts" -}}
{{- /* ports needed: 19100-19899 */ -}}
{{- $ := index . 0 }}
{{- $podSpecCheck := index . 1 }}
{{- include "dynamicPort" (list $ $.Values.contentserver.ports.http.start $.Values.contentserver.ports.http.end "cs" $podSpecCheck ) }}
{{- end -}}

{{- define "clusterControllerPorts" -}}
{{- /* ports needed: 19100-19899 */ -}}
{{- $ := index . 0 }}
{{- $podSpecCheck := index . 1 }}
{{- include "dynamicPort" (list $ $.Values.clustercontroller.ports.http.start $.Values.clustercontroller.ports.http.end "cc" $podSpecCheck ) }}
{{- end -}}

{{- define "metricsPorts" -}}
{{- /* ports needed: 19092-19095 */ -}}
{{- $ := index . 0 }}
{{- $podSpecCheck := index . 1 }}
{{- include "dynamicPort" (list $ $.Values.vespa.globalPorts.metricsProxy.start $.Values.vespa.globalPorts.metricsProxy.end "metrics" $podSpecCheck ) }}
{{- end -}}


{{- define "dynamicPort" -}}
{{- $ := index . 0 -}}
{{- $start := index . 1 -}}
{{- $end := index . 2 -}}
{{- $baseName := index . 3 -}}
{{- $podSpecCheck := index . 4 -}}
{{- range $idx, $portNumber := untilStep ( $start | int ) ( $end | int ) 1 }}
- name: {{ $baseName }}-{{ $idx }}
  {{ if eq ( $podSpecCheck ) ( "pod" ) -}}
    containerPort
  {{- else -}}
    port
  {{- end -}}
  : {{ $portNumber }}
{{- end -}}
{{- end -}}