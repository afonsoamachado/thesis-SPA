# Deploy without operator (Session Mode)

```bash
k create namespace flink
kubectl create -n flink -f flink-configuration-configmap.yml
kubectl create -n flink -f jobmanager-service.yaml
kubectl create -n flink -f jobmanager-session-deployment-non-ha.yaml
kubectl create -n flink -f taskmanager-session-deployment.yaml
```
## Reactive mode

[Docs](https://nightlies.apache.org/flink/flink-docs-master/docs/deployment/resource-providers/standalone/kubernetes/#using-standalone-kubernetes-with-reactive-mode).

Add following to config.yaml:
```yaml
    scheduler-mode: reactive
    execution.checkpointing.interval: 10s   
```

## Submit Jobs
```bash
./bin/flink run -m localhost:8081 ./examples/streaming/TopSpeedWindowing.jar
```
# Deploy with operator ([Helm](https://nightlies.apache.org/flink/flink-kubernetes-operator-docs-release-1.9/docs/operations/helm/))

Add repo:
```bash
helm repo add flink-kubernetes-operator-1.9.0 https://downloads.apache.org/flink/flink-kubernetes-operator-1.9.0/
```

Install
```bash
k create ns flink

helm install flink-operator flink-kubernetes-operator-1.9.0/flink-kubernetes-operator --set webhook.create=false --namespace flink -f values.yml

k apply -n flink -f cfg-map-hive.yml
k apply -n flink -f session-cluster-deployment.yml

kubectl patch service session-cluster-1-rest -p '{"spec": {"type": "NodePort"}}' -n flink
kubectl patch service session-cluster-1-rest -p '{"spec": {"type": "ClusterIP"}}' -n flink

k apply -n flink -f session-job.yml
```

Force Job delete:
```bash
kubectl get flinksessionjobs.flink.apache.org basic-session-job-example -o=json -n flink | jq '.metadata.finalizers = null' | kubectl apply -f -
```

# Flink Image

```bash
docker build -t afonsoamachado/flink:1.17.2-stable .
docker push afonsoamachado/flink:1.17.2-stable
```