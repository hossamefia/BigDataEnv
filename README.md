# Big Data Environment - Main Documentation

## 🚀 Welcome to the Big Data Environment

A complete, production-ready Big Data environment using Docker containers with Hadoop, Spark, Hive, and Jupyter Lab integration.

## ✨ Features

- **🐳 Containerized**: Full Docker-based deployment
- **🔧 Production-Ready**: Uses proven, maintained Docker images
- **🌐 Web Interfaces**: Rich UIs for all services
- **📊 Integrated Analytics**: Jupyter Lab with PySpark
- **💾 Persistent Storage**: Data survives container restarts
- **🛠️ Easy Management**: Windows batch scripts for all operations
- **📚 Learning Ready**: Sample notebooks and datasets included

## 🏗️ Architecture

### Core Components

| Component | Version | Purpose | Image |
|-----------|---------|---------|-------|
| **Hadoop** | 3.2.1 | Distributed storage (HDFS) | `bde2020/hadoop-namenode:2.0.0-hadoop3.2.1-java8` |
| **Spark** | 3.4.1 | Distributed processing | `bitnami/spark:3.4.1` |
| **Hive** | 2.3.2 | Data warehousing | `bde2020/hive:2.3.2-postgresql-metastore` |
| **PostgreSQL** | 13 | Metastore database | `postgres:13-alpine` |
| **Jupyter** | Latest | Development environment | `jupyter/pyspark-notebook:latest` |

### Service Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Jupyter   │───▶│    Spark    │───▶│    Hive     │
│     Lab     │    │   Cluster   │    │  Server2    │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────────────────────────────────────────────┐
│              Hadoop HDFS + YARN                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │NameNode  │  │DataNode  │  │Resource  │        │
│  │          │  │          │  │ Manager  │        │
│  └──────────┘  └──────────┘  └──────────┘        │
└─────────────────────────────────────────────────────┘
                       │
                       ▼
                ┌─────────────┐
                │ PostgreSQL  │
                │  Database   │
                └─────────────┘
```

## 🌐 Access Points

Once running, access these web interfaces:

| Service | URL | Description |
|---------|-----|-------------|
| **Jupyter Lab** | http://localhost:8888 | Development environment (token: `bigdata123`) |
| **Hadoop NameNode** | http://localhost:9870 | HDFS management and monitoring |
| **YARN ResourceManager** | http://localhost:8088 | Cluster resource management |
| **Spark Master** | http://localhost:8080 | Spark cluster monitoring |
| **Spark Worker** | http://localhost:8081 | Worker node monitoring |
| **HiveServer2** | http://localhost:10002 | Hive query interface |

## 🚀 Quick Start

### 1. Prerequisites
- Docker Desktop installed and running
- At least 8GB RAM available for Docker
- 20GB free disk space

### 2. Clone and Setup
```bash
git clone <repository-url>
cd BigDataEnv
scripts\setup.bat
```

### 3. Start Environment
```bash
scripts\start.bat
```

### 4. Validate Installation
```bash
scripts\validate.bat
```

### 5. Open Jupyter Lab
Navigate to http://localhost:8888 and use token: `bigdata123`

## 📚 Learning Path

### Beginner Path
1. **Start Here**: `notebooks/01-hadoop-basics.ipynb`
   - Learn HDFS operations
   - Understand distributed storage
   - Practice file operations

2. **Next**: `notebooks/02-spark-intro.ipynb`
   - Master Spark DataFrames
   - Learn transformations and actions
   - Practice data processing

3. **Then**: `notebooks/03-hive-sql.ipynb`
   - SQL operations on big data
   - Data warehousing concepts
   - Table management

4. **Finally**: `notebooks/04-integration.ipynb`
   - Full stack integration
   - End-to-end data pipeline
   - Production patterns

### Advanced Topics
- Custom Spark applications
- Performance tuning
- Data pipeline development
- Streaming data processing
- Machine learning with MLlib

## 🛠️ Management

### Windows Scripts

| Script | Purpose |
|--------|---------|
| `setup.bat` | Initial environment setup |
| `start.bat` | Start all services |
| `stop.bat` | Stop all services |
| `validate.bat` | Health check all services |
| `logs.bat [service]` | View service logs |
| `cleanup.bat` | Complete environment reset |

### Manual Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View all logs
docker-compose logs -f

# Check status
docker-compose ps

# Scale workers
docker-compose up -d --scale spark-worker=3
```

## 📊 Sample Data

The environment includes sample datasets in `data/samples/`:

- **users.csv**: User demographic data
- **transactions.json**: Financial transaction data  
- **logs.txt**: System log entries

Use these datasets to practice:
- Data loading and processing
- Schema inference and validation
- Joins and aggregations
- Data visualization

## 🔧 Configuration

### Memory Settings

Default memory allocation per service:
- Spark Master: 1GB
- Spark Worker: 2GB  
- YARN NodeManager: 4GB
- Jupyter Lab: 2GB

To adjust memory, edit `docker-compose.yml`:

```yaml
environment:
  - SPARK_WORKER_MEMORY=4G  # Increase worker memory
  - YARN_CONF_yarn_nodemanager_resource_memory___mb=8192
```

### Storage Locations

Data persists in Docker volumes:
- `postgres_data`: PostgreSQL database
- `hadoop_namenode`: HDFS metadata
- `hadoop_datanode`: HDFS data blocks  
- `spark_master_data`: Spark master state
- `spark_worker_data`: Spark worker state

### Custom Configuration

Mount your own config files:
```yaml
volumes:
  - ./my-configs/spark:/opt/bitnami/spark/conf
  - ./my-configs/hadoop:/opt/hadoop-3.2.1/etc/hadoop
```

## 🐛 Troubleshooting

### Common Issues

**Services won't start**
```bash
# Check Docker resources
docker system df
docker system prune

# Verify ports aren't in use
netstat -ano | findstr :8888
```

**Out of memory errors**
```bash
# Increase Docker memory in Docker Desktop settings
# Recommended: 8GB+ for smooth operation
```

**Connection refused**
```bash
# Wait for full startup (2-3 minutes)
scripts\validate.bat

# Check specific service logs
scripts\logs.bat namenode
```

**Performance issues**
- Allocate more memory to Docker
- Use SSD storage for better I/O
- Ensure sufficient CPU cores (4+ recommended)

### Getting Help

1. Check service logs: `scripts\logs.bat [service]`
2. Validate environment: `scripts\validate.bat`
3. Review the troubleshooting guide: `docs/troubleshooting.md`
4. Check container status: `docker-compose ps`

## 📈 Performance Tips

### Development Optimization
- Use smaller datasets for learning
- Adjust Spark parallelism based on your CPU cores
- Enable adaptive query execution
- Use appropriate file formats (Parquet for analytics)

### Production Considerations
- Increase cluster size with more workers
- Implement proper security and authentication
- Use external metastore database
- Configure monitoring and alerting
- Implement backup strategies

## 🎯 Use Cases

This environment is perfect for:

### Learning & Education
- Big Data concepts and technologies
- Spark programming (Python, Scala, SQL)
- Data engineering practices
- SQL on big data with Hive

### Development & Prototyping
- Data pipeline development
- Analytics application prototyping
- Algorithm testing and validation
- Performance benchmarking

### Data Science Projects  
- Large dataset analysis
- Machine learning model training
- Feature engineering at scale
- Data visualization and reporting

## 🔒 Security Notes

**Development Focus**: This environment prioritizes ease of use for learning
- Default passwords used (change for production)
- No authentication enabled (add for production)
- Services run with elevated privileges
- Network security simplified

**Production Checklist**:
- [ ] Enable Kerberos authentication
- [ ] Configure HDFS permissions
- [ ] Use SSL/TLS encryption
- [ ] Implement proper secrets management
- [ ] Set up network security groups
- [ ] Configure audit logging

## 🆕 What's New

### Version 2.0 Features
- ✅ **Working Docker Images**: Replaced broken images with verified alternatives
- ✅ **bde2020 Ecosystem**: Uses proven Big Data Docker images
- ✅ **PostgreSQL Metastore**: Reliable database backend
- ✅ **Health Checks**: Proper service dependency management
- ✅ **Windows Scripts**: Complete automation for Windows users
- ✅ **Sample Notebooks**: Ready-to-use learning materials
- ✅ **Comprehensive Documentation**: Detailed guides and troubleshooting

### Fixes from Previous Version
- ❌ `apache/hadoop:3.3.4` → ✅ `bde2020/hadoop-namenode:2.0.0-hadoop3.2.1-java8`
- ❌ `apache/spark:3.4.1` → ✅ `bitnami/spark:3.4.1`
- ❌ Derby database issues → ✅ PostgreSQL metastore
- ❌ Service startup failures → ✅ Proper dependency management
- ❌ Windows compatibility → ✅ Native batch scripts

## 🤝 Contributing

We welcome contributions! Please:
1. Fork the repository
2. Create a feature branch
3. Test your changes thoroughly
4. Submit a pull request with clear description

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **bde2020** team for excellent Big Data Docker images
- **Apache Foundation** for Hadoop, Spark, and Hive
- **Bitnami** for reliable Spark containers
- **Jupyter Project** for the amazing notebook environment

---

**Happy Big Data Learning!** 🚀📊✨

For detailed setup instructions, see [setup-guide.md](docs/setup-guide.md)

For architecture details, see [architecture.md](docs/architecture.md)

For troubleshooting help, see [troubleshooting.md](docs/troubleshooting.md)