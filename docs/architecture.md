# 🏗️ Architecture Guide

Comprehensive technical architecture documentation for the Big Data environment.

## 🎯 Overview

This Big Data environment implements a **production-ready, microservices-based architecture** using Docker containers to provide a complete Hadoop ecosystem with Spark and Hive integration.

## 🏛️ High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Big Data Environment                          │
├─────────────────────────────────────────────────────────────────┤
│  Development Layer                                              │
│  ┌─────────────────┐                                           │
│  │   Jupyter Lab   │ ←─── Interactive Development              │
│  │   (Port 8888)   │                                           │
│  └─────────────────┘                                           │
├─────────────────────────────────────────────────────────────────┤
│  Compute Layer                                                  │
│  ┌─────────────────┐    ┌─────────────────┐                   │
│  │   Spark Master  │    │   Spark Worker  │                   │
│  │   (Port 8080)   │    │   (Port 8081)   │                   │
│  └─────────────────┘    └─────────────────┘                   │
├─────────────────────────────────────────────────────────────────┤
│  Data Warehouse Layer                                           │
│  ┌─────────────────┐    ┌─────────────────┐                   │
│  │  HiveServer2    │    │ Hive Metastore  │                   │
│  │  (Port 10000)   │    │   (Port 9083)   │                   │
│  └─────────────────┘    └─────────────────┘                   │
├─────────────────────────────────────────────────────────────────┤
│  Resource Management Layer                                      │
│  ┌─────────────────┐    ┌─────────────────┐                   │
│  │YARN ResourceMgr │    │ YARN NodeMgr    │                   │
│  │  (Port 8088)    │    │  (Port 8042)    │                   │
│  └─────────────────┘    └─────────────────┘                   │
├─────────────────────────────────────────────────────────────────┤
│  Storage Layer                                                  │
│  ┌─────────────────┐    ┌─────────────────┐                   │
│  │Hadoop NameNode  │    │Hadoop DataNode  │                   │
│  │  (Port 9870)    │    │  (Port 9864)    │                   │
│  └─────────────────┘    └─────────────────┘                   │
├─────────────────────────────────────────────────────────────────┤
│  Metadata Layer                                                 │
│  ┌─────────────────┐                                           │
│  │   PostgreSQL    │ ←─── Hive Metastore Database              │
│  │   (Port 5432)   │                                           │
│  └─────────────────┘                                           │
└─────────────────────────────────────────────────────────────────┘
```

## 🔗 Service Dependencies

### Startup Dependency Graph
```
PostgreSQL
    ↓
Hadoop NameNode ──→ Hadoop DataNode
    ↓                      ↓
YARN ResourceManager ──→ YARN NodeManager
    ↓                      ↓
Hive Metastore ──────→ HiveServer2
    ↓                      ↓
Spark Master ─────────→ Spark Worker
    ↓                      ↓
    └──────→ Jupyter Lab ←─┘
```

### Service Interdependencies

| Service | Depends On | Required For |
|---------|------------|--------------|
| PostgreSQL | None | Hive Metastore |
| NameNode | PostgreSQL | DataNode, YARN RM |
| DataNode | NameNode | YARN NM, Spark |
| YARN ResourceManager | NameNode | YARN NodeManager |
| YARN NodeManager | YARN RM, DataNode | Spark, MapReduce |
| Hive Metastore | PostgreSQL, NameNode | HiveServer2 |
| HiveServer2 | Hive Metastore | Jupyter, Spark SQL |
| Spark Master | NameNode, YARN RM | Spark Worker |
| Spark Worker | Spark Master | Jupyter |
| Jupyter Lab | All services | None |

## 🔧 Component Details

### 1. PostgreSQL (Metastore Database)
**Role**: Reliable metadata storage for Hive
**Technology**: PostgreSQL 13
**Configuration**:
```yaml
Environment:
  - POSTGRES_DB=metastore
  - POSTGRES_USER=hive
  - POSTGRES_PASSWORD=hive123
Volume: postgres_data:/var/lib/postgresql/data
Health Check: pg_isready -U hive -d metastore
```

**Why PostgreSQL over Derby**:
- ✅ Multi-user concurrent access
- ✅ ACID compliance and reliability
- ✅ Better performance for metadata operations
- ✅ Production-ready (Derby is embedded/single-user)

### 2. Hadoop NameNode (HDFS Master)
**Role**: HDFS namespace management and metadata
**Technology**: Apache Hadoop 3.3.4
**Key Configurations**:
```xml
<property>
  <name>fs.defaultFS</name>
  <value>hdfs://namenode:9000</value>
</property>
<property>
  <name>dfs.replication</name>
  <value>1</value>
</property>
```

**Responsibilities**:
- File system namespace management
- Block location tracking
- Replication management
- Client request coordination

### 3. Hadoop DataNode (HDFS Storage)
**Role**: Actual data storage and retrieval
**Technology**: Apache Hadoop 3.3.4
**Configuration**:
```xml
<property>
  <name>dfs.datanode.data.dir</name>
  <value>/hadoop/dfs/data</value>
</property>
```

**Responsibilities**:
- Block storage and retrieval
- Block integrity checking
- Heartbeat to NameNode
- Data pipeline operations

### 4. YARN ResourceManager (Cluster Resources)
**Role**: Cluster resource management and job scheduling
**Technology**: Apache Hadoop 3.3.4 YARN
**Key Features**:
- Application lifecycle management
- Resource allocation and scheduling
- Node monitoring and health
- Security and isolation

### 5. YARN NodeManager (Node Resources)
**Role**: Per-node resource management
**Configuration**:
```xml
<property>
  <name>yarn.nodemanager.resource.memory-mb</name>
  <value>2048</value>
</property>
<property>
  <name>yarn.nodemanager.resource.cpu-vcores</name>
  <value>2</value>
</property>
```

**Responsibilities**:
- Container lifecycle management
- Resource monitoring
- Log aggregation
- Auxiliary services (e.g., Shuffle)

### 6. Hive Metastore (Metadata Service)
**Role**: Hive metadata service
**Technology**: Apache Hive 3.1.3
**Configuration**:
```xml
<property>
  <name>javax.jdo.option.ConnectionURL</name>
  <value>jdbc:postgresql://postgres:5432/metastore</value>
</property>
```

**Metadata Stored**:
- Database and table schemas
- Partition information
- Column statistics
- Storage format details

### 7. HiveServer2 (SQL Interface)
**Role**: SQL query processing and execution
**Technology**: Apache Hive 3.1.3
**Features**:
- JDBC/ODBC connectivity
- Spark execution engine integration
- Concurrent client support
- Web UI for monitoring

### 8. Spark Master (Cluster Coordinator)
**Role**: Spark cluster management
**Technology**: Apache Spark 3.4.1
**Configuration**:
```properties
spark.master=spark://spark-master:7077
spark.sql.catalogImplementation=hive
spark.serializer=org.apache.spark.serializer.KryoSerializer
```

**Responsibilities**:
- Application registration
- Worker node management
- Resource allocation
- Job scheduling

### 9. Spark Worker (Execution Nodes)
**Role**: Task execution and data processing
**Configuration**:
```bash
SPARK_WORKER_MEMORY=2g
SPARK_WORKER_CORES=2
```

**Responsibilities**:
- Executor process management
- Task execution
- Data caching
- Shuffle operations

### 10. Jupyter Lab (Development Environment)
**Role**: Interactive development and analytics
**Technology**: Jupyter Lab with PySpark integration
**Features**:
- Pre-configured PySpark kernel
- Hadoop/Hive integration
- Sample notebooks included
- Big Data libraries pre-installed

## 🌐 Network Architecture

### Docker Network Configuration
```yaml
networks:
  bigdata-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.25.0.0/16
```

### Service Communication
```
Jupyter Lab ─────┐
                 ├─── spark://spark-master:7077
Spark Master ────┘

Spark ──────────────── hdfs://namenode:9000 ─────── HDFS
     └─── thrift://hive-metastore:9083 ──── Hive Metastore

Hive Metastore ── jdbc:postgresql://postgres:5432/metastore ── PostgreSQL
```

### Port Mapping Strategy
| Internal Port | External Port | Protocol | Service |
|---------------|---------------|----------|---------|
| 5432 | 5432 | TCP | PostgreSQL |
| 9000 | - | TCP | HDFS NameNode RPC |
| 9870 | 9870 | HTTP | HDFS NameNode Web UI |
| 9864 | 9864 | HTTP | HDFS DataNode Web UI |
| 8032 | - | TCP | YARN ResourceManager RPC |
| 8088 | 8088 | HTTP | YARN ResourceManager Web UI |
| 8042 | 8042 | HTTP | YARN NodeManager Web UI |
| 9083 | - | TCP | Hive Metastore Thrift |
| 10000 | 10000 | TCP | HiveServer2 Thrift |
| 10002 | 10002 | HTTP | HiveServer2 Web UI |
| 7077 | - | TCP | Spark Master RPC |
| 8080 | 8080 | HTTP | Spark Master Web UI |
| 8081 | 8081 | HTTP | Spark Worker Web UI |
| 8888 | 8888 | HTTP | Jupyter Lab |

## 💾 Data Architecture

### Storage Hierarchy
```
├── HDFS (Distributed File System)
│   ├── /user/hive/warehouse     # Hive tables
│   ├── /user/demo/input         # Raw data
│   ├── /user/demo/output        # Processed data
│   ├── /spark-history           # Spark event logs
│   └── /app-logs               # Application logs
│
├── PostgreSQL (Metadata)
│   ├── Hive metastore schema
│   ├── Table/partition metadata
│   └── Column statistics
│
└── Docker Volumes (Persistence)
    ├── postgres_data
    ├── namenode_data
    ├── datanode_data
    ├── spark_logs
    └── jupyter_home
```

### Data Flow Architecture
```
Raw Data Sources
        ↓
    HDFS Storage ←─────── Jupyter Lab (Data Upload)
        ↓
    Spark Processing ←──── Jupyter Notebooks
        ↓
    Hive Tables ←───────── Hive Metastore (Schema)
        ↓
    Analytics Results ──→ Export (Parquet/CSV/JSON)
```

## ⚙️ Configuration Management

### Configuration Structure
```
configs/
├── hadoop/
│   ├── core-site.xml      # Core Hadoop settings
│   ├── hdfs-site.xml      # HDFS configuration
│   ├── yarn-site.xml      # YARN resource settings
│   └── mapred-site.xml    # MapReduce settings
├── hive/
│   ├── hive-site.xml      # Hive + PostgreSQL integration
│   └── init-metastore.sql # Database initialization
├── spark/
│   └── spark-defaults.conf # Spark optimization
└── jupyter/
    └── jupyter_notebook_config.py # PySpark integration
```

### Configuration Inheritance
```
Base Docker Images
        ↓
Environment Variables (docker-compose.yml)
        ↓
Configuration Files (configs/ directory)
        ↓
Runtime Parameters (startup commands)
```

## 🔒 Security Architecture

### Development Security Model
- **Authentication**: Disabled for ease of use
- **Authorization**: Basic/none
- **Encryption**: Disabled
- **Network**: Internal Docker network only

### Security Components
```
External Access (localhost only)
        ↓
Docker Network (isolated)
        ↓
Service-to-Service (internal hostnames)
        ↓
Data Storage (Docker volumes)
```

**⚠️ Note**: This is a development/learning environment. Production deployments require comprehensive security hardening.

## 📊 Monitoring Architecture

### Health Checks
Each service implements health checks:
```yaml
healthcheck:
  test: ["CMD-SHELL", "curl -f http://localhost:9870/ || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 5
```

### Monitoring Stack
```
Web UIs ──────────┐
                  ├─── Service Status
Docker Stats ─────┤
                  ├─── Resource Usage
Health Checks ────┤
                  └─── Availability
Log Aggregation ──┘
```

### Observability
- **Metrics**: Docker stats, service-specific web UIs
- **Logs**: Centralized via Docker logging
- **Traces**: Spark application tracking
- **Health**: Automated health checks

## 🚀 Performance Architecture

### Resource Allocation Strategy
```yaml
# Memory Distribution (8GB total recommended)
PostgreSQL:     512MB
NameNode:       1GB
DataNode:       1GB
ResourceMgr:    1GB
NodeManager:    1GB
Hive Services:  1GB
Spark Master:   512MB
Spark Worker:   2GB
Jupyter:        1GB
```

### Processing Optimization
- **Spark**: Kryo serialization, adaptive query execution
- **HDFS**: Single replication for development
- **Hive**: Spark execution engine
- **Caching**: Strategic DataFrame caching

### Scalability Considerations
- **Vertical**: Increase container resources
- **Horizontal**: Add more worker nodes
- **Storage**: Increase HDFS capacity
- **Network**: Optimize for high throughput

## 🔄 Lifecycle Management

### Startup Sequence
1. **Infrastructure**: PostgreSQL, networking
2. **Storage**: HDFS NameNode, DataNode
3. **Compute**: YARN ResourceManager, NodeManager
4. **Data Warehouse**: Hive Metastore, HiveServer2
5. **Processing**: Spark Master, Worker
6. **Development**: Jupyter Lab

### Shutdown Sequence
Reverse order with graceful termination:
1. Jupyter Lab
2. Spark cluster
3. Hive services
4. YARN cluster
5. HDFS cluster
6. PostgreSQL

### Maintenance Windows
- **Daily**: Normal stop/start cycle
- **Weekly**: Health validation
- **Monthly**: Cleanup and optimization
- **Quarterly**: Version updates

## 🔧 Extensibility

### Adding New Services
```yaml
# Template for new service
new-service:
  image: service-image:version
  container_name: bigdata-new-service
  environment:
    - CONFIG_VAR=value
  volumes:
    - ./configs/new-service:/etc/config
  networks:
    - bigdata-network
  depends_on:
    - required-service
```

### Integration Points
- **Data Sources**: HDFS, external databases
- **Processing**: Additional Spark applications
- **Storage**: Additional storage formats
- **APIs**: REST/GraphQL interfaces
- **Visualization**: BI tools integration

## 📚 Technology Choices Rationale

### Hadoop 3.3.4
- **Latest stable version** with security improvements
- **YARN federation** support for scaling
- **Erasure coding** for storage efficiency
- **Timeline Service v2** for better application tracking

### Spark 3.4.1
- **Adaptive Query Execution** for performance
- **Dynamic partition pruning** for better query optimization
- **Structured Streaming** improvements
- **Kubernetes support** for cloud deployment

### Hive 3.1.3
- **ACID transactions** support
- **Materialized views** for performance
- **Workload management** capabilities
- **Better Spark integration**

### PostgreSQL 13
- **ACID compliance** for metadata integrity
- **Concurrent access** support
- **Better performance** than Derby
- **Production readiness**

This architecture provides a **solid foundation for Big Data learning and development** while maintaining the flexibility to evolve into production-ready deployments.