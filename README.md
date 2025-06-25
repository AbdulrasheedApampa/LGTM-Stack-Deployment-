# LGTM Stack Deployment on GKE with Terraform and ArgoCD

This project demonstrates the deployment of the **LGTM stack** (Loki, Grafana, Tempo, Mimir) on a **GKE Standard Cluster** using **Terraform for Infrastructure as Code** and **ArgoCD for GitOps**.

---

## 🌐 Live URLs

| Service      | URL                                     | Username | Password     |
|--------------|------------------------------------------|----------|--------------|
| ArgoCD UI    | [gitops.one.codcn.com](https://gitops.one.codcn.com/) | `admin`  | `password`   ` |
| Grafana UI   | [grafana.one.codcn.com](https://grafana.one.codcn.com/) | `admin`  | `password` |

---

## ✅ Requirements Met

- ✅ Created **GCS buckets** for Loki and Mimir.
- ✅ Provisioned **GKE Standard Cluster** with 4 `e2-standard-4` nodes.
- ✅ Created **VPC**, subnets, Cloud NAT, and other networking resources.
- ✅ Configured **IAM** roles and Workload Identity.
- ✅ Deployed **ArgoCD** and bootstrapped GitOps pipeline.
- ✅ Installed **LGTM stack** using **Helm** and ArgoCD.
- ✅ Configured **Grafana** to display metrics/logs from the cluster.
- ✅ Served UIs over HTTPS using custom subdomains via **Cloud DNS**.
- ✅ Secured ArgoCD and Grafana with **basic authentication**.

---

## 🔧 Tools & Technologies

- **Terraform** – Infrastructure provisioning (GCP resources, IAM, networking, GKE, GCS buckets).
- **ArgoCD** – GitOps controller for Kubernetes.
- **Helm** – For LGTM stack deployment via ArgoCD.
- **GKE (Google Kubernetes Engine)** – Hosts the Kubernetes workloads.
- **Cloud DNS** – DNS for subdomains.
- **Workload Identity** – IAM binding for GKE workloads to access GCS.

---
 *Thank You*
---

### 📊 Architecture Diagram

![LGTM Stack Architecture](ltgm-Page-1.png)
