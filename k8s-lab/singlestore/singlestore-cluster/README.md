# Deploy [(link)](https://docs.singlestore.com/db/v7.3/deploy/kubernetes/deploy-a-singlestore-cluster/)

1. Create Persistant Volumes
2. Create **sdb** namaspace
3. *sdb-rbac.yaml*
4. *sdb-cluster-crd.yaml*
5. *sdb-operator.yaml*

**WAIT FOR OPERATOR -> Running**

Create root secret [(link)](https://docs.singlestore.com/db/v8.5/reference/singlestore-operator-reference/specify-and-rotate-the-root-password/):
```bash
kubectl create secret generic rootpw --from-literal=password='root123'
```

6. sdb-cluster.yaml

## Volumes NFS

NFS directory permissions:
```
for i in $(seq -w 1 5); do
    sudo rm -r pv-sdb-000$i
    sudo mkdir pv-sdb-000$i
    sudo chown 999 -R pv-sdb-000$i
done

sudo chown 999 -R /datadrives/datadrive01
```
## Resources
- 0.5 = 4 vCPU cores, 16 GB of RAM

## Check Cluster 

```bash
kubectl get  memsqlclusters.memsql.com
```

## Get Root Password
```bash
kubectl get secret sdb-cluster -n sdb -o jsonpath="{.data.ROOT_PASSWORD}" | base64 --decode
```

# Queries
## Clear Cache
```sql
DROP ALL FROM PLANCACHE;
```