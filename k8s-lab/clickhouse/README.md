# Deploy K8s


## Storage
User:
```bash
uid=101(clickhouse) gid=101(clickhouse) groups=101(clickhouse)
```

Directories init:
```bash
for i in {00..03}; do
    sudo mkdir -p ./pv-clickhouse-$i/tmp
    sudo mkdir -p ./pv-clickhouse-$i/user_files
    sudo mkdir -p ./pv-clickhouse-$i/format_schemas
    sudo chown -R 101:101 ./pv-clickhouse-$i
    sudo chmod -R 777 ./pv-clickhouse-$i
done 
```

## Helm
([Link](https://github.com/Altinity/clickhouse-operator/blob/master/docs/operator_installation_details.md))
```
helm repo add clickhouse-operator https://docs.altinity.com/clickhouse-operator/
```

Operator:
```bash
helm install clickhouse-operator clickhouse-operator/altinity-clickhouse-operator  -n clickhouse --values values.yml

helm upgrade clickhouse-operator clickhouse-operator/altinity-clickhouse-operator -n clickhouse --values values.yml
```

[Example Deployment](
https://github.com/Altinity/clickhouse-operator/blob/master/docs/quick_start.md#custom-deployment-with-pod-and-volumeclaim-templates)

## Expose 8193 port

Reference: https://github.com/Altinity/clickhouse-operator/issues/823

Extra configuration:
```yml
users:
    default/networks/ip: "::/0"
```

```bash
k expose -n clickhouse service clickhouse-clickhouse-cluster --type=NodePort --name=clickhouse-cluster-external
```
