# Deploy

* Host configuration
```bash
sudo sysctl -w vm.max_map_count=2000000
echo "vm.max_map_count=2000000" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

* Change 
    *```/usr/lib/systemd/system/containerd.service```
    *```/etc/systemd/system/containerd.service```
```bash
LimitNOFILE=655350:655350
```


* [K8s Quickstart](https://doris.apache.org/docs/install/cluster-deployment/k8s-deploy/install-quickstart)

```bash
# CRD
kubectl create -f https://raw.githubusercontent.com/selectdb/doris-operator/master/config/crd/bases/doris.selectdb.com_dorisclusters.yaml
# Namespace and Operator
kubectl apply -f https://raw.githubusercontent.com/selectdb/doris-operator/master/config/operator/operator.yaml

# Cluster
k apply -n doris -f doriscluster.yml
#   OR
helm install -f values.yml doriscluster doris-1.6.1.tgz -n doris
```



## Volumes NFS

NFS directory permissions:
```bash
# Remove old directories
for i in $(seq -w 00 11); do
    sudo rm -R pv-doris-$i
done
# Create directories
for i in $(seq -w 00 11); do
    sudo mkdir pv-doris-$i
    sudo chown -R 1001:1001 ./pv-doris-$i
    sudo chmod -R 777 ./pv-doris-$i
done
```
