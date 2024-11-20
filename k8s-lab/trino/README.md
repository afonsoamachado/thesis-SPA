# Trino

## Deploy [Trino Helm](https://trino.io/docs/current/installation/kubernetes.html)

- Add helm repo
```bash
helm repo add trino https://trinodb.github.io/charts/
```

- Create namespace and install:
```bash
kubectl create namespace trino
helm install -f trino-values.yaml trino trino/trino -n trino
```

- Change port number
```bash
kubectl patch svc trino -n trino --type='json' -p='[
    {"op": "replace", "path": "/spec/ports/0/nodePort", "value": 31404}
]'
```

- Update values:
```bash
helm upgrade trino trino/trino -f trino-values.yaml -n trino
```

View hell *yaml*'s:
```bash
helm template trino trino/trino
```

## Sandbox

Create cache directories in every node:
```bash
ssh spauser@10.0.0.34 mkdir /tmp/trino-cache
ssh spauser@10.0.0.39 mkdir /tmp/trino-cache
ssh spauser@10.0.0.44 mkdir /tmp/trino-cache
ssh spauser@10.0.0.46 mkdir /tmp/trino-cache
ssh spauser@10.0.0.47 mkdir /tmp/trino-cache
```

Dynamic Catalogos PV:
```bash
sudo rm -r pv-catalogs
sudo mkdir pv-catalogs
sudo chown -R 1001:1001 ./pv-catalogs
sudo chmod -R 777 ./pv-catalogs
```

# Kafka Table Definition

```json
      {
        "tableName": "customer",
        "schemaName": "test",
        "topicName": "test.customer",
        "key": {
          "dataFormat": "raw",
          "fields": [
            {
                "name": "kafka_key",
                "mapping": "0",
                "type": "VARCHAR",
                "hidden": "false"
            }
          ]
        },
        "message": {
          "dataFormat": "json",
          "fields": [
            {
                "name": "custkey",
                "mapping": "custkey",
                "type": "INTEGER"
            },
            {
                "name": "name",
                "mapping": "name",
                "type": "VARCHAR"
            }
          ]
        }
      }
```