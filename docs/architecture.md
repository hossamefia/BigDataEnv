# Big Data Environment - Architecture

## 🏗️ System Architecture

This document describes the technical architecture of the Big Data environment.

## 📊 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        Big Data Environment                     │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   Jupyter   │  │    Spark    │  │    Hive     │             │
│  │     Lab     │◄─┤   Master    │◄─┤  Server2    │             │
│  │             │  │             │  │             │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│         │                │                │                    │
│         │                ▼                ▼                    │
│         │         ┌─────────────┐  ┌─────────────┐             │
│         │         │    Spark    │  │    Hive     │             │
│         │         │   Worker    │  │ Metastore   │             │
│         │         │             │  │             │             │
│         │         └─────────────┘  └─────────────┘             │
│         │                │                │                    │
│         ▼                ▼                ▼                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                 Hadoop Ecosystem                       │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐│   │
│  │  │NameNode  │  │DataNode  │  │Resource  │  │   Node   ││   │
│  │  │   HDFS   │  │   HDFS   │  │ Manager  │  │ Manager  ││   │
│  │  │          │  │          │  │   YARN   │  │   YARN   ││   │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘│   │
│  └─────────────────────────────────────────────────────────┐   │
│                             │                               │   │
│                             ▼                               │   │
│                    ┌─────────────┐                         │   │
│                    │ PostgreSQL  │                         │   │
│                    │  Database   │                         │   │
│                    │             │                         │   │
│                    └─────────────┘                         │   │
└─────────────────────────────────────────────────────────────────┘
```

## 🔧 Component Details

### 1. Storage Layer - Hadoop HDFS

**Purpose**: Distributed file system for big data storage

**Components**:
- **NameNode**: Manages metadata and namespace
- **DataNode**: Stores actual data blocks

**Configuration**:
- Replication factor: 1 (development setup)
- Block size: 128MB (default)
- Permissions: Disabled for simplicity

**Ports**:
- NameNode UI: 9870
- NameNode RPC: 9000
- DataNode UI: 9864

### 2. Resource Management - YARN

**Purpose**: Cluster resource management and job scheduling

**Components**:
- **ResourceManager**: Global resource scheduler
- **NodeManager**: Per-node resource management

**Configuration**:
- Memory: 4GB per node
- CPU cores: 4 per node
- Scheduler: Capacity Scheduler

**Ports**:
- ResourceManager UI: 8088
- NodeManager UI: 8042

### 3. Processing Engine - Apache Spark

**Purpose**: Unified analytics engine for large-scale data processing

**Components**:
- **Spark Master**: Cluster coordinator
- **Spark Worker**: Execution nodes

**Configuration**:
- Memory per worker: 2GB
- Cores per worker: 2
- Dynamic allocation: Enabled

**Ports**:
- Spark Master UI: 8080
- Spark Worker UI: 8081
- Spark Master RPC: 7077

### 4. Data Warehouse - Apache Hive

**Purpose**: Data warehouse software for querying large datasets

**Components**:
- **Hive Metastore**: Metadata service
- **HiveServer2**: Query execution service

**Configuration**:
- Metastore DB: PostgreSQL
- Execution engine: Spark
- File format: Parquet (optimized)

**Ports**:
- HiveServer2: 10000
- HiveServer2 Web UI: 10002
- Metastore: 9083

### 5. Database - PostgreSQL

**Purpose**: Relational database for Hive metastore

**Configuration**:
- Version: 13-alpine
- Database: metastore
- User: hive
- Auto-initialization: Enabled

**Port**: 5432

### 6. Development Environment - Jupyter Lab

**Purpose**: Interactive development environment

**Features**:
- PySpark integration
- Pre-installed big data libraries
- Sample notebooks included
- Direct access to all services

**Port**: 8888

## 🔄 Data Flow Architecture

### 1. Data Ingestion Flow

```
External Data → Jupyter/Scripts → HDFS → Hive Tables → Spark Processing
```

### 2. Query Processing Flow

```
SQL Query → HiveServer2 → Spark Engine → HDFS Data → Results
```

### 3. Analytics Flow

```
Jupyter Notebook → Spark Session → Hive Metastore → HDFS → Visualization
```

## 🌐 Network Architecture

### Network Configuration

**Custom Bridge Network**: `bigdata-network`
- Enables service discovery by hostname
- Isolated from host network
- Internal communication optimized

### Service Communication

```
Jupyter ──► Spark Master ──► Spark Worker
   │              │              │
   ▼              ▼              ▼
HiveServer2 ──► HDFS ──────► YARN
   │              │              │
   ▼              ▼              ▼
Metastore ──► PostgreSQL ──► Logs
```

### Port Mappings

| Internal Port | External Port | Service |
|---------------|---------------|---------|
| 8888 | 8888 | Jupyter Lab |
| 9870 | 9870 | Hadoop NameNode |
| 8088 | 8088 | YARN ResourceManager |
| 8080 | 8080 | Spark Master |
| 10000 | 10000 | HiveServer2 |
| 10002 | 10002 | HiveServer2 Web UI |
| 5432 | 5432 | PostgreSQL |

## 💾 Storage Architecture

### Persistent Volumes

```
├── postgres_data          # PostgreSQL database files
├── hadoop_namenode       # HDFS metadata
├── hadoop_datanode       # HDFS data blocks
├── spark_master_data     # Spark master state
└── spark_worker_data     # Spark worker state
```

### Directory Structure in HDFS

```
/
├── user/
│   ├── data/             # Raw data storage
│   ├── hive/warehouse/   # Hive table data
│   ├── spark-logs/       # Spark application logs
│   └── analytics/        # Analysis results
└── tmp/                  # Temporary files
```

## 🔒 Security Architecture

### Development Security Model

**Current State**: Simplified for development
- No authentication required
- Permissive access controls
- Default passwords used

### Production Considerations

For production deployment, implement:
- Kerberos authentication
- HDFS permissions and ACLs
- SSL/TLS encryption
- Network security groups
- Secrets management

## 📊 Monitoring and Observability

### Built-in Monitoring

1. **Hadoop Monitoring**
   - NameNode UI: Cluster health, storage usage
   - DataNode UI: Node-specific metrics
   - YARN UI: Application monitoring

2. **Spark Monitoring**
   - Spark Master UI: Cluster status
   - Spark Worker UI: Worker metrics
   - Application UI: Job execution details

3. **Container Monitoring**
   - Docker health checks
   - Container resource usage
   - Service status monitoring

### Log Management

```
Service Logs Location:
├── Docker container logs (docker-compose logs)
├── Hadoop logs (/opt/hadoop/logs)
├── Spark logs (/opt/spark/logs)
└── Application logs (HDFS /spark-logs)
```

## ⚡ Performance Characteristics

### Resource Requirements

**Minimum**:
- RAM: 8GB
- CPU: 4 cores
- Storage: 20GB

**Recommended**:
- RAM: 16GB
- CPU: 8 cores
- Storage: 50GB SSD

### Scaling Considerations

**Horizontal Scaling**:
- Add more Spark workers
- Add more HDFS DataNodes
- Partition data appropriately

**Vertical Scaling**:
- Increase memory allocation
- Add more CPU cores
- Use faster storage

## 🔄 Deployment Architecture

### Container Orchestration

**Docker Compose Features**:
- Service dependencies with health checks
- Automatic restart policies
- Volume management
- Network isolation
- Environment variable management

### Startup Sequence

1. PostgreSQL (database initialization)
2. Hadoop NameNode (HDFS formatting)
3. Hadoop DataNode (storage registration)
4. YARN ResourceManager (resource management)
5. YARN NodeManager (node registration)
6. Hive Metastore (schema initialization)
7. HiveServer2 (query service)
8. Spark Master (cluster coordination)
9. Spark Worker (worker registration)
10. Jupyter Lab (development environment)

## 🛠️ Configuration Management

### Configuration Strategy

**Externalized Configuration**:
- Mount configuration files as volumes
- Environment variable overrides
- Runtime configuration updates

**Configuration Files**:
```
configs/
├── hadoop/               # Hadoop ecosystem configs
│   ├── core-site.xml
│   ├── hdfs-site.xml
│   ├── yarn-site.xml
│   └── mapred-site.xml
├── hive/                # Hive configurations
│   └── hive-site.xml
├── spark/               # Spark configurations
│   └── spark-defaults.conf
└── jupyter/             # Jupyter configurations
    └── jupyter_notebook_config.py
```

This architecture provides a robust, scalable foundation for big data learning and development! 🚀