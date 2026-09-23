```bash
#!/bin/bash

set -e

echo "=== Checking nodes and labels ==="
kubectl get nodes --show-labels

echo ""
echo "=== Applying MySQL taint to nodes labeled app=mysql ==="
kubectl get nodes -l app=mysql -o name | \
  xargs -r -n1 kubectl taint nodes app=mysql:NoSchedule --overwrite

echo ""
echo "=== Checking node taints ==="
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints}{'\n'}"

echo ""
echo "=== Creating namespaces ==="
kubectl create namespace mysql --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace todoapp --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "=== Applying MySQL resources ==="
kubectl apply -f mysql/

echo ""
echo "=== Applying TodoApp resources ==="
kubectl apply -f todoapp/

echo ""
echo "=== Cluster status ==="
kubectl get nodes -o wide

echo ""
echo "=== Pods ==="
kubectl get pods -A -o wide

echo ""
echo "=== StatefulSets ==="
kubectl get statefulsets -A

echo ""
echo "=== Deployments ==="
kubectl get deployments -A

echo ""
echo "=== Bootstrap completed successfully ==="
```
