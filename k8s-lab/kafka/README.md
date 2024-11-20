# Confluent Tutorials

- [quick-start-using-kraft](https://docs.confluent.io/operator/current/co-quickstart.html#quick-start-using-kraft)
- [kraft-quickstart (github)](https://github.com/confluentinc/confluent-kubernetes-examples/tree/master/quickstart-deploy/kraft-quickstart)

# Deploy k8s

- Grant permissions on PV directores
```bash
sudo mkdir pv-kafka-05
sudo chown -R 1001:0 ./pv-kafka-05
sudo chmod -R 755 ./pv-kafka-05



for i in {00..06}; do
  dir="pv-kafka-$i"
  sudo rm -r ./pv-kafka-$i/logs
  sudo rm -r ./pv-kafka-$i/0
done
```
- install helm
```bash
helm pull confluentinc/confluent-for-kubernetes --untar --untardir=cfk
```

```bash
k create namespace confluent


helm upgrade --install confluent-operator ./confluent-for-kubernetes -n confluent --set kRaftEnabled=true

k apply -f kafka/kraftbroker_controller.yaml
k apply -f kafka/topics.yaml
```

# Topics (pod kafka-0)

```bash
kafka-topics --create --bootstrap-server kafka.confluent.svc.cluster.local:9092 --replication-factor 1 --partitions 1 --topic customerStream


kafka-topics --delete --topic customerStream --bootstrap-server kafka.confluent.svc.cluster.local:9092
```

# Publish Log

```bash
echo '<json-object>' | kafka-console-producer --broker-list kafka.confluent.svc.cluster.local:9092 --topic <topic>
kafka-console-consumer --from-beginning --topic <topic> --bootstrap-server  kafka.confluent.svc.cluster.local:9092


<echo '0:{"custkey":1,"name":"Customer#000000001"}' | kafka-console-producer --broker-list kafka.confluent.svc.cluster.local:9092 --topic customerStream   --property parse.key=true --property key.separator=:

echo '{"name":"kafka"}' | kafka-console-producer --broker-list kafka.confluent.svc.cluster.local:9092 --topic customerStream


echo '{"description": "Customer#000000002"}' | kafka-avro-console-producer \
  --broker-list kafka.confluent.svc.cluster.local:9092 \
  --topic customerStream \
  --property schema.registry.url=http://schemaregistry.confluent.svc.cluster.local:8081 \
  --property value.schema.id=2

  '{"type":"record","name":"customerStream","fields":[{"name":"description","type":"string"}]}'
```
# Consume Logs

```bash
 kafka-console-consumer --bootstrap-server  kafka.confluent.svc.cluster.local:9092 --topic customerStream --from-beginning

 kafka-avro-console-consumer \
  --bootstrap-server kafka.confluent.svc.cluster.local:9092 \
  --topic customerStream \
  --from-beginning \
  --property schema.registry.url=http://schemaregistry.confluent.svc.cluster.local:8081
```

# Publish Schema
```bash
curl -X POST -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  --data '{
    "schema": "{\"namespace\": \"iceberg.tpch\", \"type\": \"record\", \"name\": \"customerAvro\", \"fields\": [{\"name\": \"custkey\", \"type\": \"int\"}, {\"name\": \"name\", \"type\": \"string\"}]}"
  }' \
  http://schemaregistry.confluent.svc.cluster.local:8081/subjects/text.customers-value/versions


  curl -X GET  http://schemaregistry.confluent.svc.cluster.local:8081/subjects/text.customers-value/versions
```