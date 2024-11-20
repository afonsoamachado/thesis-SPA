# Deploy k8

0. PVs Directories
```
for i in $(seq -w 0 2); do
    sudo rm -r pv-cockroachdb-0$i
    sudo mkdir pv-cockroachdb-0$i
    sudo chmod -R 777 -R pv-cockroachdb-0$i
done
```

1. Operator
``` bash
# CRDs
kubectl apply -f https://raw.githubusercontent.com/cockroachdb/cockroach-operator/v2.15.1/install/crds.yaml

kubectl apply -f https://raw.githubusercontent.com/cockroachdb/cockroach-operator/v2.15.1/install/operator.yaml
```

2. Cluster

```bash
helm install my-release --values values.yaml cockroachdb/cockroachdb -n cockroach-operator-system

kubectl apply -f cluster-dym.yml -n cockroach-operator-system
```

```bash
k expose -n cockroach service cockroachdb-public --type=NodePort --name=cockroachdb-public-external
```

3. Create User

```bash
kubectl create -f https://raw.githubusercontent.com/cockroachdb/cockroach-operator/v2.15.1/examples/client-secure-operator.yaml  -n cockroach-operator-system

kubectl exec -n cockroach-operator-system -it pods/cockroachdb-client-secure  -- bash

./cockroach sql --certs-dir=/cockroach/cockroach-certs --host=cockroachdb-public

CREATE USER roach WITH PASSWORD 'roach';
GRANT admin TO roach;
```