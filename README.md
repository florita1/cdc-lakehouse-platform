# WAL-Based PostgreSQL CDC Platform

This project implements a real-time Change Data Capture (CDC) platform using PostgreSQL's Write-Ahead Log (WAL) as the data source and ClickHouse as the OLAP sink. It supports both synthetic and CDC-based ingestion, and is deployed Kubernetes-first via GitOps using Terraform and Argo CD.

> 🚀 Designed for low-latency OLAP analytics, developer extensibility, and full teardown support.

---

## 🧱 Architecture

```
PostgreSQL (WAL)
     ↓
Debezium (CDC connector)
     ↓
Redpanda (Kafka-compatible broker)
     ↓
Go Ingestion Service (dual mode: synthetic | cdc)
     ↓
ClickHouse (ReplacingMergeTree)
```

### Component Summary

| Component             | Role                                                                 |
|----------------------|----------------------------------------------------------------------|
| **PostgreSQL**        | Source of truth; emits logical replication events (WAL)             |
| **Debezium**          | Captures WAL events and publishes to Redpanda                       |
| **Redpanda**          | Kafka-compatible message broker for CDC buffering                   |
| **Go Ingestion Service** | Dual-mode: generates synthetic data or consumes CDC events from Redpanda |
| **ClickHouse**        | Real-time OLAP storage; uses `ReplacingMergeTree` for versioning    |

---

## 🔧 Infrastructure

- **Cluster Name:** `postgres-wal-cdc-cluster`
- **Provisioning:** Terraform (modular, destroyable)
- **Delivery:** GitOps via Argo CD
- **Infrastructure Stack:**
  - VPC
  - EKS
  - IAM
  - Argo CD
- **Teardown:** Full `terraform destroy` support

---

## 📦 Project Structure
```
wal-cdc-platform/
├── README.md
├── apps
│   ├── clickhouse-operator.yaml
│   ├── clickhouse.yaml
│   ├── debezium.yaml
│   ├── postgres.yaml
│   ├── redpanda.yaml
│   ├── root.yaml
│   └── wal-cdc-namespaces.yaml
├── clickhouse
│   ├── clickhouseinstallation.yaml
│   ├── init-configmap.yaml
│   └── init-job.yaml
├── kustomize
│   ├── debezium
│   │   ├── configmap-connector.json.yaml
│   │   ├── deployment.yaml
│   │   ├── job-register-connector.yaml
│   │   ├── kustomization.yaml
│   │   ├── secret-postgres.yaml
│   │   └── service.yaml
│   └── postgres
│       ├── configmap-init.sql.yaml
│       ├── deployment.yaml
│       ├── kustomization.yaml
│       └── service.yaml
├── namespaces
│   ├── clickhouse-operator.yaml
│   ├── clickhouse.yaml
│   ├── debezium.yaml
│   ├── postgres.yaml
│   └── redpanda.yaml
└── terraform
    ├── environments
    │   └── dev
    │       ├── argocd.tf
    │       ├── eks.tf
    │       ├── iam.tf
    │       ├── providers.tf
    │       ├── variables.tf
    │       └── vpc.tf
    └── modules
        ├── argocd
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── values.yaml
        ├── eks
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        ├── iam
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        └── vpc
            ├── main.tf
            ├── outputs.tf
            └── variables.tf

```

---

## 🔍 Under the Hood — How It Works

This project simulates a real-time OLAP analytics flow using PostgreSQL WAL-based change data capture, Redpanda buffering, and dual-mode ingestion into ClickHouse — all deployed Kubernetes-first using GitOps.

- **Infrastructure** is provisioned with Terraform, including an EKS cluster, VPC, IAM roles, and Argo CD. Modules support full teardown via `terraform destroy`.
- **PostgreSQL** is patched to support logical replication. Any inserts or updates trigger WAL events.
- **Debezium** captures those WAL changes and emits structured CDC events to a Redpanda topic using Kafka-compatible protocols.
- **Redpanda** buffers the stream and allows the ingestion service to consume events asynchronously.
- **ClickHouse** is initialized via `init.sql` and stores CDC data using the `ReplacingMergeTree` engine for versioned, deduplicated OLAP analytics.
- **Go-based Ingestion Service** supports two modes:
  - `--mode=synthetic` (default): emits mock `UserEvent` payloads for pipeline testing and observability.
  - `--mode=cdc`: parses Debezium envelopes from Redpanda, transforms them into normalized `UserEvent` structs, and inserts into ClickHouse.
- **Helm chart** for the ingestion service includes configurable mode support and is deployed via Argo CD alongside other components.

> Everything runs inside Kubernetes with GitOps delivery, enabling reproducibility, modular debugging, and real-time insert visibility — whether you're streaming from Postgres or generating synthetic test traffic.

---

## 🖥️ CDC Verification

![Argo CD UI Applications](screenshots/argocd.png)


### **1. PostgreSQL WAL Settings**
Snippet from kustomize/postgres/deployment.yaml
```bash
          args:
            - "-c"
            - "wal_level=logical"
            - "-c"
            - "max_wal_senders=10"
            - "-c"
            - "max_replication_slots=10"
```

---

### **2. Verify Debezium Connector Status**
```bash
# Replace host with your Debezium service DNS or port-forwarded localhost
curl -s http://connect:8083/connectors/postgres-appdb-connector/status
```
``` json
# Expected RUNNING status:
{
  "name": "postgres-appdb-connector",
  "connector": {
    "state": "RUNNING",
    "worker_id": "10.2.0.250:8083"
  },
  "tasks": [
    {
      "id": 0,
      "state": "RUNNING",
      "worker_id": "10.2.0.250:8083"
    }
  ],
  "type": "source"
}
```

---

### **3. Verify Redpanda CDC Events**
```bash

# Consume a few messages from the CDC topic
 kubectl -n redpanda run kafkactl --restart=Never -it --image=bitnami/kafka:3.7.0 -- \                         
  kafka-topics.sh --list --bootstrap-server redpanda.redpanda.svc.cluster.local:9093

```
Example output:
```json
{
  "topic": "dbserver1.app.users",
  "key": "{\"id\":2}",
  "value": "{\"before\":null,\"after\":{\"id\":2,\"name\":\"TestUser\",\"email\":\"test+upd@example.com\"},\"source\":{\"version\":\"2.6.2.Final\",\"connector\":\"postgresql\",\"name\":\"dbserver1\",\"ts_ms\":1754816578832,\"snapshot\":\"false\",\"db\":\"appdb\",\"sequence\":\"[\\\"26619888\\\",\\\"26619888\\\"]\",\"ts_us\":1754816578832901,\"ts_ns\":1754816578832901000,\"schema\":\"app\",\"table\":\"users\",\"txId\":759,\"lsn\":26619888,\"xmin\":null},\"op\":\"u\",\"ts_ms\":1754816579296,\"ts_us\":1754816579296122,\"ts_ns\":1754816579296122309,\"transaction\":null}",
  "timestamp": 1754816579456,
  "partition": 0,
  "offset": 2
}

```

---

## 🔑 Helpful Commands

### Get Argo CD UI Password
```bash
kubectl -n wal-cdc-argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d; echo
```

