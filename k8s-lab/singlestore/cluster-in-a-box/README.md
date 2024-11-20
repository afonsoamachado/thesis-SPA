# SingleStore Cluster in a Box

```
k create ns sdb
kubectl apply -f ./cluster-in-a-box/singlestore-deployment.yaml  -n sdb
kubectl apply -f ./cluster-in-a-box/singlestore-service.yaml -n sdb
```