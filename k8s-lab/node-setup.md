# k8s cluster

## VM config
```bash
sudo nano /etc/default/grub
```

Edit grub
``` 
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_pstate=disable cgroup_disable=memory swapaccount=1"
```

```bash
sudo update-grub
sudo reboot
```
- set swappinees  and overcommit_memory:
```bash
sudo sysctl vm.swappiness=10 # recomended 0 and 10
sudo sysctl vm.overcommit_memory=0
```
This change is temporary and will be lost after a reboot. To make it permanent, add the following line to the `/etc/sysctl.conf` file:

```nano
vm.swappiness=10
vm.overcommit_memory=0
```

- Install [Helm](https://helm.sh/docs/intro/install/):
```bash
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

## Installations
1. [Forwarding IPv4 and letting iptables see bridged traffic](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#forwarding-ipv4-and-letting-iptables-see-bridged-traffic)

```bash
sudo modprobe br_netfilter
echo '1' | sudo tee /proc/sys/net/bridge/bridge-nf-call-iptables
echo '1' | sudo tee /proc/sys/net/bridge/bridge-nf-call-ip6tables

sudo nano /etc/sysctl.conf

net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
```

2. [Container Runtime](https://kubernetes.io/docs/setup/production-environment/container-runtimes/)
    - [containerd](https://github.com/containerd/containerd/blob/main/docs/getting-started.md) (all steps take place on *home/user*)

    Step 1: Installing containerd
    ```bash
    curl -L "https://github.com/containerd/containerd/releases/download/v1.7.14/containerd-1.7.14-linux-amd64.tar.gz" -o containerd-1.7.14-linux-amd64.tar.gz
    
    sudo tar Cxzvf /usr/local containerd-1.7.14-linux-amd64.tar.gz
    
    sudo curl -L "https://raw.githubusercontent.com/containerd/containerd/main/containerd.service" --output /etc/systemd/system/containerd.service

    systemctl daemon-reload
    systemctl enable --now containerd
    ```
    Step 2: Installing runc
    ```bash
    sudo curl -L "https://github.com/opencontainers/runc/releases/download/v1.1.12/runc.amd64" -o runc.amd64

    sudo install -m 755 runc.amd64 /usr/local/sbin/runc
    ```

    Check runc version:
    ```bash
    /usr/local/sbin/runc --version
    ```

    Step 3: Installing CNI plugins

    ```bash
    curl -L "https://github.com/containernetworking/plugins/releases/download/v1.4.1/cni-plugins-linux-amd64-v1.4.1.tgz" -o cni-plugins-linux-amd64-v1.4.1.tgz


    sudo mkdir -p /opt/cni/bin
    sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.4.1.tgz
    ```

    Step 4: Generate default configuration for */etc/containerd/config.toml*.
    ```
    containerd config default > config.toml

    sudo mkdir /etc/containerd
    sudo mv config.toml /etc/containerd
    ```
    Step 5: Alter configuration */etc/containerd/config.toml* to use *systemmd* as *cgroup driver*:
    ```toml
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
        ...
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true
    ```
    Step 6: Enable containerd
    ```bash
    systemctl daemon-reload
    systemctl enable --now containerd
    ```

3. [kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) & Kubelet (without package manager)

4. [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

5. conntrack
```
sudo apt-get install conntrack
```


## Starting Nodes

### Master Node

Pull images:
```
sudo kubeadm config images pull
```

Initialize :
```
kubeadm init
```
Result:
```bash
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:
```


Config kubectl:
```bash
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Config pod network [Weave Net](https://github.com/weaveworks/weave/blob/master/site/kubernetes/kube-addon.md#-installation) add-on:
```bash
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
```

Configure [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress) Controller -  [ingress-nginxkj](https://kubernetes.github.io/ingress-nginx/deploy) on [Azure](https://learft.com/en-us/azure/aks/ingress-basic?tabs=azure-cli#create-an-ingress-controller-using-an-internal-ip-address);
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/cloud/deploy.yaml

kubectl patch svc ingress-nginx-controller -n ingress-nginx -p '{"spec": {"externalIPs":["10.0.12.1"]}}'
```

Configure [Load Balacers](https://romanglushach.medium.com/kubernetes-networking-load-balancing-techniques-and-algorithms-5da85c5c7253):

### Worker node

If new token needed, run on master:
```bash
kubeadm token create --print-join-command
```
Add Worker node:
```bash
kubeadm join 10.0.0.10:6443 --token <token> --discovery-token-ca-cert-hash <sha256>
```
E.g:
```bash
sudo kubeadm join 10.0.0.10:6443 --token ljl7h0.h3pfua4hzrpshhvb --discovery-token-ca-cert-hash sha256:a7b04bf422af2dd8dd821a179daaaa68a3b6abd96c82210e43dd94f4595401c5
```



Configure kubectl (optitional):
```
scp root@10.0.0.10:/etc/kubernetes/admin.conf ~/.kube/config2
```

[sachedule on contrlo  plane node](https://medium.com/@shyamsandeep28/scheduling-pods-on-master-nodes-7e948f9cb02c)

## Storage - NFS Server (with XFS)

1. Create [NFS Server](https://ubuntu.com/server/docs/service-nfs)
  - [Attache new Disk](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/attach-disk-portal?tabs=ubuntu)

2. Add NFS to k8s cluster [link](https://medium.com/@shatoddruh/kubernetes-how-to-install-the-nfs-server-and-nfs-dynamic-provisioning-on-azure-virtual-machines-e85f918c7f4b)

3. Allow K8s Node on NFS Server
```bash
sudo ufw allow from <ip-of-node> to any port nfs
```

4. Install nfs common:
```bash
sudo apt install nfs-common
```

5. Mount NFS drive on Node
```bash
sudo mount <nfs-server-ip>:<dir-nfs-server> <dir-k8s-node>
```
E.g.
```bash
sudo mount 10.0.0.38:/datadrives /nfs/datadrive
```

6.  Setup auto mount on file */etc/fstab* of Node
```bash
sudo nano /etc/fstab
<nfs-server-ip>:<dir-nfs-server> <dir-k8s-node> nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
```
E.g.
```bash
10.0.0.38:/datadrives nfs/datadrives nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
```

## Extras

Check disks:
```bash
lsblk -o NAME,HCTL,SIZE,MOUNTPOINT,FSTYPE | grep -i "sd"
```
Check mounted NFS:
```bash
mount -l | grep nfs
```

```bash
showmount -e
```

K8s IPs:
```bash
kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{.status.podIP}{end}'
```

Enter Pod:
```bash
k exec -i -t -n <n> <pod> -- sh -c "clear; (bash || ash || sh)"
```

Curl:
```bash
kubectl exec -it hive-7cddf8785c-7t5jt -n trino -- curl -v tenant-00-hl.minio.svc.cluster.local:9000/warehouse

```

kubectl exec -it aws-cli -n trino -- sh -c "AWS_ACCESS_KEY_ID=minio AWS_SECRET_ACCESS_KEY=minio123 aws --endpoint-url http://tenant-00-hl.minio.svc.cluster.local:9000 --region us-east-1 s3 ls s3://warehouse"

export AWS_ACCESS_KEY_ID=minio
export AWS_SECRET_ACCESS_KEY=minio123
aws s3 ls s3://warehouse --region <region>


k apply -n trino -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: aws-cli
  namespace: trino
spec:
  containers:
    - name: aws-cli
      image: amazon/aws-cli
      command: ["sleep", "infinity"]
EOF



kubectl exec -it aws-cli -n trino -- \
    aws --endpoint-url http://tenant-00-hl.minio.svc.cluster.local:9000 \
    --region us-east-1 \
    s3 ls s3://warehouse \
    --access-key xOgzxnz5cyHS6tTlRGct \
    --secret-key zdNENzRo9dnhgywjiDqsG3cloYmzHyoekFeUYZaS

kubectl get pv | grep Released | awk '{print $1}' | xargs kubectl delete pv

kubectl -n ? exec -it ? -- bash

kubectl patch <resource-type> <resource-name> -p '{"metadata":{"finalizers":[]}}' --type=merge