```bash
#!/bin/bash

set -e

echo "=== Checking Kubernetes nodes ==="
kubectl get nodes --show-labels

echo ""
echo "=== Checking existing taints ==="
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints}{'\n'}"

echo ""
echo "=== Applying MySQL taint ==="
kubectl taint nodes kind-worker app=mysql:NoSchedule --overwrite
kubectl taint nodes kind-worker2 app=mysql:NoSchedule --overwrite

echo ""
echo "=== Checking MySQL taints ==="
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints}{'\n'}"

echo ""
echo "=== Creating namespaces ==="
kubectl create namespace mysql --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace todoapp --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "=== Applying Kubernetes manifests ==="
kubectl apply -f .

echo ""
echo "=== Checking cluster ==="
kubectl get nodes -o wide

echo ""
echo "=== Checking all Pods ==="
kubectl get pods -A -o wide

echo ""
echo "=== Checking StatefulSets ==="
kubectl get statefulsets -A

echo ""
echo "=== Checking Deployments ==="
kubectl get deployments -A

echo ""
echo "=== Bootstrap completed ==="
```
