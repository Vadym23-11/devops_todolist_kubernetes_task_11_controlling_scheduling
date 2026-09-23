# Kubernetes Scheduling Validation

## 1. Prerequisites

Make sure the following tools are installed:

* Docker
* kubectl
* kind

Check:

```bash
docker --version
kubectl version --client
kind version
```

Make sure Docker is running.

---

## 2. Create the Kubernetes cluster

Create the cluster using the provided `cluster.yml`:

```bash
kind create cluster --config cluster.yml
```

Check the Nodes:

```bash
kubectl get nodes -o wide
```

---

## 3. Check Node labels

Display all Node labels:

```bash
kubectl get nodes --show-labels
```

Check which Nodes have the `app=mysql` label:

```bash
kubectl get nodes -l app=mysql
```

Check which Nodes have the `app=todoapp` label:

```bash
kubectl get nodes -l app=todoapp
```

The expected result is that the required Nodes are returned by these commands.

---

## 4. Check Node taints

Display all taints:

```bash
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints}{'\n'}"
```

The MySQL Nodes should have:

```text
app=mysql:NoSchedule
```

You can also inspect an individual Node:

```bash
kubectl describe node <node-name>
```

Look for the `Taints` section.

---

## 5. Deploy the application

Run:

```bash
./bootstrap.sh
```

Check all resources:

```bash
kubectl get all -A
```

---

## 6. Validate MySQL StatefulSet

Check the StatefulSet:

```bash
kubectl get statefulset -n mysql
```

Check MySQL Pods:

```bash
kubectl get pods -n mysql -o wide
```

The MySQL Pods must be scheduled only on Nodes with:

```text
app=mysql
```

Check the Node where each Pod is running:

```bash
kubectl get pods -n mysql -o wide
```

Verify that the MySQL Pods are running on different Nodes.

This validates the Pod Anti-Affinity rule.

---

## 7. Validate MySQL toleration

Because the MySQL Nodes have the following taint:

```text
app=mysql:NoSchedule
```

the MySQL Pods must have a matching toleration.

Inspect the Pod:

```bash
kubectl describe pod -n mysql <mysql-pod-name>
```

Check the Node:

```bash
kubectl get pod -n mysql <mysql-pod-name> -o wide
```

The MySQL Pod should be able to run on the tainted MySQL Node.

---

## 8. Validate MySQL Node Affinity

Check the Nodes:

```bash
kubectl get nodes -l app=mysql
```

Then check where the MySQL Pods are running:

```bash
kubectl get pods -n mysql -o wide
```

The Pods should be scheduled on Nodes labeled:

```text
app=mysql
```

---

## 9. Validate TodoApp Deployment

Check the Deployment:

```bash
kubectl get deployment -n todoapp
```

Check the Pods:

```bash
kubectl get pods -n todoapp -o wide
```

Check the Node where the Pods are running:

```bash
kubectl get pods -n todoapp -o wide
```

The Deployment has a preferred Node Affinity rule for Nodes labeled:

```text
app=todoapp
```

Because this is:

```text
preferredDuringSchedulingIgnoredDuringExecution
```

the rule is a preference rather than a strict requirement.

---

## 10. Validate TodoApp Pod Anti-Affinity

Check the Pods:

```bash
kubectl get pods -n todoapp -o wide
```

The TodoApp Pods should not be scheduled on the same Node when the Pod Anti-Affinity rule can be satisfied.

The rule uses:

```text
kubernetes.io/hostname
```

which means the anti-affinity is applied at the Node level.

---

## 11. Inspect Pod scheduling

For more detailed scheduling information:

```bash
kubectl describe pod -n mysql <mysql-pod-name>
```

and:

```bash
kubectl describe pod -n todoapp <todoapp-pod-name>
```

Check the `Events` section for scheduling information.

---

## 12. Verify the complete cluster state

Run:

```bash
kubectl get nodes -o wide
```

```bash
kubectl get pods -A -o wide
```

```bash
kubectl get statefulsets -A
```

```bash
kubectl get deployments -A
```

The expected result is:

* MySQL Pods run on Nodes labeled `app=mysql`.
* MySQL Pods tolerate the `app=mysql:NoSchedule` taint.
* MySQL Pods are distributed between different Nodes when possible/required by anti-affinity.
* TodoApp has a preferred affinity for Nodes labeled `app=todoapp`.
* TodoApp has Pod Anti-Affinity preventing its Pods from sharing a Node when the rule can be satisfied.

---

## 13. Cleanup

Delete the Kind cluster:

```bash
kind delete cluster
```

```
```
