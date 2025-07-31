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

Once Helm is set up properly, add the repository and install the chart:

```bash
# Add the Vespa Helm repository
$ helm repo add vespa https://walmartlabs.github.io/vespa-helm
$ helm repo update

# Install Vespa with default values
$ helm install my-vespa vespa/vespa

# Or install with custom values
$ helm install my-vespa vespa/vespa -f my-values.yaml
```

**Alternative: Install from source**

If you prefer to install directly from the source repository:

```bash
# Clone the repository
$ git clone https://github.com/walmartlabs/vespa-helm.git
$ cd vespa-helm

# Install the chart from local files
$ helm install my-vespa ./charts/vespa -f my-values.yaml
```

## Istio Installation

[Istio](https://istio.io/) should be configured on the Kubernetes cluster in order to deploy Vespa. 
This chart uses Istio for service mesh capabilities including ingress gateways, virtual services, and traffic management.

### Prerequisites
- Kubernetes cluster
- kubectl configured to access your cluster
- Helm 3.x installed

### Installation Steps

1. **Create the Istio system namespace:**
   ```bash
   kubectl create namespace istio-system
   ```

2. **Add the Istio Helm repository:**
   ```bash
   helm repo add istio https://istio-release.storage.googleapis.com/charts
   helm repo update
   ```

3. **Install Istio base (CRDs and cluster roles):**
   ```bash
   helm install istio-base istio/base -n istio-system --set defaultRevision=default
   ```

4. **Install Istiod (control plane):**
   
   For public Docker Hub (recommended for most users):
   ```bash
   helm install istiod istio/istiod -n istio-system \
     --set tag=1.26.2 \
     --timeout='7200s' \
     --wait \
     --debug
   ```
   
   For private registries (enterprise environments):
   ```bash
   helm install istiod istio/istiod -n istio-system \
     --set hub=your-private-registry.com/istio \
     --set tag=1.26.2 \
     --timeout='7200s' \
     --wait \
     --debug
   ```

5. **Create Istio Ingress Gateway configuration file (`igw.yaml`):**
   
   Choose the appropriate configuration based on your environment:
   
   **For public Docker Hub (default):**
   ```yaml
   labels:
     app: istio-ingressgateway
   # hub: docker.io/istio (uses default)
   tag: 1.25.3

   service:
     # For external/public load balancer (AWS, GCP, Azure public)
     type: LoadBalancer
     # annotations: {} # Add cloud-specific annotations as needed
   **For private registry (enterprise environments):**
   ```yaml
   labels:
     app: istio-ingressgateway
   hub: your-private-registry.com/istio  # Replace with your registry
   tag: 1.25.3

   service:
     # For internal/private load balancer
     type: LoadBalancer
     annotations:
       # Azure internal load balancer
       service.beta.kubernetes.io/azure-load-balancer-internal: "true"
       # AWS internal load balancer
       # service.beta.kubernetes.io/aws-load-balancer-internal: "true"
       # GCP internal load balancer  
       # cloud.google.com/load-balancer-type: "Internal"
     ports:
       - name: status-port
         port: 15021
         targetPort: 15020 
         protocol: TCP
       - name: http2
         port: 80
         targetPort: 80
         protocol: TCP
       - name: https
         port: 443
         targetPort: 443
         protocol: TCP

   podAnnotations:
     prometheus.io/scrape: "true"
     prometheus.io/port: "15020" 
     prometheus.io/path: "/stats/prometheus"

   resources:
     requests:
       cpu: 1000m    # Adjust based on your cluster capacity
       memory: 1024Mi
     limits:
       cpu: 2000m
       memory: 2048Mi
   
   autoscaling:
     enabled: true
     minReplicas: 2      # Adjust based on your needs
     maxReplicas: 10     # Adjust based on your cluster capacity
     targetCPUUtilizationPercentage: 80

   # Add environment-specific scheduling rules if needed
   affinity: {}
   tolerations: []
   ```

   **Common cloud provider load balancer annotations:**
   ```yaml
   # AWS
   # service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
   # service.beta.kubernetes.io/aws-load-balancer-internal: "true"
   
   # Azure
   # service.beta.kubernetes.io/azure-load-balancer-internal: "true"
   
   # GCP
   # cloud.google.com/load-balancer-type: "Internal"
   ```

6. **Install Istio Ingress Gateway:**
   ```bash
   helm install istio-ingressgateway istio/gateway -n istio-system \
     -f igw.yaml \
     --timeout='7200s' \
     --wait \
     --debug
   ```

### Verify Installation

After installation, verify that all Istio components are running:

```bash
kubectl get pods -n istio-system
```

You should see pods for:
- `istio-proxy` (injected into application pods)
- `istiod-*` (control plane)
- `istio-ingressgateway-*` (ingress gateway)

### Configuration Notes

- **Load Balancer**: Configuration supports both public and internal load balancers depending on your requirements
  - Public: Remove annotations for external access (default LoadBalancer behavior)
  - Internal: Add cloud-specific annotations for internal-only access
- **Docker Images**: 
  - Default configuration uses public Docker Hub (`docker.io/istio`)
  - For enterprise environments, configure private registry in the `hub` parameter
- **Resource allocation**: Adjust CPU/memory requests and limits based on your cluster capacity and expected traffic
- **Autoscaling**: Configure min/max replicas and CPU thresholds based on your traffic patterns
- **Prometheus metrics**: Enabled by default on port 15020 for monitoring integration

### Vespa Integration

Once Istio is installed, the Vespa chart will automatically configure:
- Virtual Services for ingress routing
- Gateways for external access
- Service mesh integration for inter-service communication

The ingress gateway label selectors in `values.yaml` are configured to match the Istio ingress gateway:
```yaml
istio:
  configserver:
    ingressGatewayLabelSelector: 
      istio: ingressgateway
      app: istio-ingressgateway
```

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
