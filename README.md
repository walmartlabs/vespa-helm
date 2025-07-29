# Vesp Helm Charts

Helm chart for deploying Vespa to a Kubernetes cluster.

## Usage

### Prerequisite 
1. Helm
2. Istio

[Helm](https://helm.sh) must be installed in order to use the Vespa chart.
Please refer to Helm's [documentation](https://helm.sh/docs/) on how to get started.

```bash
$ brew install helm
```

Once Helm is set up properly, add the repo as follows:
```bash
$ helm repo add vespa https://walmart.github.io/vespa-helm
$ helm install vespa
```

[Istio]() should be configured on the Kubernetes cluster in order to deploy Vespa. 
Please refer to Istio's [documentation](https://istio.io/latest/docs/setup/) on how to setup Istio control plane on Kubernetes. 

This repository has unit tests for the charts. All charts are also linted.

### Linting

Linting is done with `helm lint`. To lint all charts:

```bash
$ make lint
```

### Unit tests

Unit tests are in the `./test` directory.

To run the tests:

```bash
$ make test
```

### Rendering template
To render the current changes of templates

```bash
$ make render
```

## Features

### Embedded application package deployments

#### Schema definitions 

Schema's can be configured within the `vespa.schemas` section of the helm values.

The `key` within this dictionary will be the name of the schema provided.

Other schema configuration parameters within the schema section:
|key|description|
|---|---|
|replicas|the redundancy configuration for the schema. Default of `2` is recommended.|
|dedicatedContentNodes|This section being present enables configuration for group distribution of the schema|
|dedicatedContentNodes.numberOfGroups|number of groups to spread distribute node allocation across|
|dedicatedContentNodes.totalContentNodes|total number of nodes to use for this schema specifically|
|garbageCollection|true/false to enable garbage collection|
|selection|when garbage collection is enabled, provide a selection query to determine the documents to remove|
|definition|the schema definition itself as a multi-line string|

NOTE: The `totalContentNodes` value MUST be less or equal to (if no other schemas are present) than the total number of contentserver replicas (`contentserver.replicas`)

Example schema:
```
vespa:
  schemas:
    music:
      replicas: 2
      dedicatedContentNodes:
        numberOfGroups: 2
        totalContentNodes: 8 #total number of content nodes, across as many groups as possible
      garbageCollection: true
      selection: "music.year &gt; 2000"   #enables garbage collection based on selection query
      definition: |
        schema music {

          document music {

            field artist type string {
                indexing: summary | index
            }

            field album type string {
                indexing: summary | index
            }

            field year type int {
                indexing: summary | attribute
            }

            field category_scores type tensor<float>(cat{}) {
                indexing: summary | attribute
            }
          }
        }
```

#### Query Profiles

To include query profiles in the helm chart, use the `vespa.queryProfiles` section in the values.yaml.

Example:

```
vespa:
  queryProfiles:
    query-profile-1: |
      <query-profile id="MyProfile">
          <field name="hits">20</field>
          <field name="maxHits">2000</field>
          <field name="unique">merchantid</field>
      </query-profile>
```

The keys within `vespa.queryProfiles` will be used in file names and should only include alphanumeric character and hyphens/dash/underscores (`-`/`_`).  Do not include a file extension- it is assumed these will be xml. 

Any query profiles will be automatically captured and included in the application package when deployed.

### Memory Backed Storage

To reduce any potential I/O impacts on the feed and query pods you can enable a feature to provide a memory-backed emptyDir to use for Vespa scratch space:

```
querycontainer:
  resources:
    memoryStorageLimit: 2Gi

feedcontainer:
  resources:
    memoryStorageLimit: 5Gi
```

This implementation is only enabled when the  `memoryStorageLimit` configuration is present. If not, it will default to the k8s node local disk usage.
