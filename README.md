# k8s-mongodb-cluster-demo
Helm chart to deploy MongoDB cluster as Kubernetes Statefulsets for dev/learning/testing purpose (not for production use, please make use of K8s operator instead). Prometheus exporter and sidecar containers used. Required Helm version is 3.3+ (due to lookup function).

## What it will do when deployed
This chart will create StatefullSets for:
- ConfigServer replicaset (of 3),
- 2 DB Shards each as replicaset (of 3),
- 3 instances of mongos router
Then it will configure:
- 3 LoadBalacer services for each mongos router (in case of microk8s we can just run metallb addon with LAN adresses configured to get ExternalIP working)
- Shards replica info will be added with K8s Job (in case it was not done earlier and not listed in sh.status() output)
Among other things configured:
- Secret with passwords for mongodb (not used yet)
- Secret with MongoDB KeyFile (used in mongo instances), existing one will be reused on re-deployment

## Default values explanation
- PVC size set to 2GB by default for each cfg/db mongod container (adjust storage.*.claimSize value accordingly)
- To support microk8s "hostpath" storage class value of storage.*.className is empty - set appropriate SC name if needed.
- Set Shards count as needed with shardsCount variable (min is 1).
- Number of replicaSet member of database shards and config servers defined with replicas.*.count, change it if needed.

# Deployment instructions
1. Verify values.yaml to meet your environment
   - Adjust Prometheus operator namespace name if needed.
In case you namespace name differs from "monitoring" (microk8s addon default) - just override it with:
```
serviceMonitor.namespace="<Prometheus namespacename>"
```
   - In case you Prometheus deployed not with operator, ServiceMonitor need to be disabled and annotations will be populated with:
```
serviceMonitor.enabled=false
```

2. Create K8s namespace if needed
3. Deploy Helm chart with command like:
```
helm upgrade --install --debug <release name> ./mongodb-cluster-demo --namespace <namespace> --wait
```

# Teardown instructions
1. Uninstall Helm release with:
```
helm uninstall --debug <release name> [--namespace <namespacename>]
```
2. Check and delete Persistent storage resources with:
```
kubectl get pvc [-n <namespace name>]
kubectl delete pvc --all [-n <namespace name>]
```

## This work inspired by this projects:
- https://github.com/pkdone/minikube-mongodb-demo
- https://github.com/cvallance/mongo-k8s-sidecar
- https://github.com/steven-sheehy/mongodb_exporter ( extended fork of https://github.com/percona/mongodb_exporter )
- https://github.com/helm/charts/tree/master/stable/prometheus-mongodb-exporter

as well by this publications:
- http://blog.kubernetes.io/2017/01/running-mongodb-on-kubernetes-with-statefulsets.html
- http://pauldone.blogspot.com/2017/06/deploying-mongodb-on-kubernetes-gke25.html


## Tested on Ubuntu Linux using https://microk8s.io/ snap (v1.18.6) singe node and multi-node cluster (https://microk8s.io/docs/clustering) made with LXD
microk8s add-ons list:
- dns
- metallb
- metrics-server
- prometheus
- rbac
- storage

optional add-ons:
- ingress
- dashboard

## Usefull hints
How-to check pod affinity : kubectl get pod -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName -n mongodb