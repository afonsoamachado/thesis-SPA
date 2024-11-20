# MinIO

## NFS directory permissions:

```
for i in $(seq -w 1 16); do
    rm -r pv-32-00$i/warehouse
    rm -r pv-32-00$i/.minio.sys
done

sudo chown 1000:1000 -R /datadrives/datadrive02
```

## K8s Helm Installation [(link)](https://min.io/docs/minio/kubernetes/upstream/index.html)


Add helm repo:
```bash
helm repo add minio-operator https://operator.min.io
```

Install Operator:
```bash
kubectl create namespace minio
helm install operator minio-operator/operator -n minio -f ~/minIO/operator-values.yaml
```

Console NodePort:
```bash
kubectl patch svc console -n minio --type='json' -p='[
    {"op": "replace", "path": "/spec/ports/0/nodePort", "value": 30090},
    {"op": "replace", "path": "/spec/type", "value": "NodePort"}
]'
```

Secret to access Operator
```bash
kubectl -n minio  get secret console-sa-secret -o jsonpath="{.data.token}" | base64 --decode
```

Install Tenant:
```bash
helm install tenant minio-operator/tenant -f  ~/minIO/tenant-values.yaml -n minio
```

# Tenant 
- CPU Request: 2
- Memory  Request: 8 GB

## Test MinIO connection

```bash
apiVersion: v1
kind: Pod
metadata:
  name: minio-client
spec:
  restartPolicy: Never
  containers:
  - name: minio-clientfor i in $(seq -w 1 16); do
    rm -r pv-32-00$i/data
done
    image: minio/mc
    command: ["/bin/sh", "-c"]
    args: ["mc alias set myminio http://minio.minio.svc.cluster.local:80 nVX8HZCRMRFrjkL8faFA MwqzkHmuOp4zlOHWekZDJTaA6xJNhtfOtNdOCIR7 --api s3v4 && mc ls myminio"]
```