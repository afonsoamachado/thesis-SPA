# trino-gateway

## Deploy

```bash
k create ns trino-gateway

kubectl create secret generic datastore-secret --from-file ./trino-gateway/datastore.yaml --dry-run=client -o yaml | kubectl apply -n trino-gateway -f -

kubectl create cm routing-rules -n trino-gateway --from-file ./trino-gateway/routing-rules.yaml

# Minikube
helm install trino-gateway -n trino-gateway --values ./trino-gateway/values-local.yaml ./trino-gateway/trino-gateway-8.tgz
# Cloud
helm install trino-gateway -n trino-gateway --values ./trino-gateway/values-sandbox.yaml ./trino-gateway/trino-gateway-8.tgz

```

## Clusters

```json
curl -X POST http://10.0.0.10:30786/gateway/backend/modify/add \
     -H "Content-Type: application/json" \
     -d '
           {
             "name": "trino",
             "proxyTo": "http://trino.trino.svc.cluster.local:8080",
             "active": true,
             "routingGroup": "adhoc",
             "externalUrl": "http://localhost:8080"
           }'


curl -X POST http://10.0.0.10:30786/gateway/backend/modify/add \
     -H "Content-Type: application/json" \
     -d '
           {
             "name": "starburst",
             "proxyTo": "http://starburst.sep.svc.cluster.local:8080",
             "active": true,
             "routingGroup": "java",
             "externalUrl": "http://localhost:8084"
           },

curl -X GET http://10.0.0.10:30786/entity/GATEWAY_BACKEND

```