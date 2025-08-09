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
postgres-wal-cdc-clickhouse/
├── terraform/
│   ├── environments/dev/
│   └── modules/
│       ├── vpc/
│       ├── eks/
│       ├── iam/
│       └── argocd/
├── apps/
│   ├── postgres.yaml
│   ├── redpanda.yaml
│   ├── debezium.yaml
│   ├── clickhouse.yaml
│   └── ingestion-service.yaml
├── helm/
│   └── ingestion-service/     # Supports --mode override
├── clickhouse/
│   └── init.sql               # Schema and table definitions
├── go-wal-consumer/           # Dual-mode Go ingestion service
└── README.md
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


helpful commands:
how to get argocd ui password:
```wal-cdc-platform % kubectl -n wal-cdc-argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo```