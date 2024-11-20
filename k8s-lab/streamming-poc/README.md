# Python Application

Build image:
```bash
docker build -t singlestore-cdc-out-python singlestore-trino-iceberg/python/

docker tag singlestore-cdc-out-python afonsoamachado/singlestore-cdc-out-python
docker push afonsoamachado/singlestore-cdc-out-python
```

# Singlestore

```sql
set global enable_observe_queries=1

OBSERVE * FROM customer BEGIN AT (<offset for partion_id=0>,<offset for partion_id=n>)
```