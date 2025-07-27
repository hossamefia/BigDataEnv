# Big Data Environment - Setup Guide

## 🚀 Quick Start

This guide will help you set up and run a complete Big Data environment with Hadoop, Spark, Hive, and Jupyter.

## 📋 Prerequisites

- **Docker Desktop** installed and running
- **Docker Compose** available (included with Docker Desktop)
- At least **8GB RAM** available for Docker
- **20GB free disk space** for images and data

## 🛠️ Installation Steps

### 1. Initial Setup

```bash
# Navigate to the project directory
cd BigDataEnv

# Run initial setup (Windows)
scripts\setup.bat

# Or manually pull images
docker-compose pull
```

### 2. Start the Environment

```bash
# Start all services (Windows)
scripts\start.bat

# Or manually start
docker-compose up -d
```

### 3. Validate Installation

```bash
# Check if everything is working (Windows)
scripts\validate.bat

# Or manually check
docker-compose ps
```

## 🌐 Access Points

Once the environment is running, you can access:

| Service | URL | Credentials |
|---------|-----|-------------|
| **Jupyter Lab** | http://localhost:8888 | Token: `bigdata123` |
| **Hadoop NameNode** | http://localhost:9870 | N/A |
| **YARN ResourceManager** | http://localhost:8088 | N/A |
| **Spark Master** | http://localhost:8080 | N/A |
| **HiveServer2 Web UI** | http://localhost:10002 | N/A |
| **PostgreSQL** | localhost:5432 | User: `hive`, Pass: `hive123` |

## 📊 Getting Started

### Step 1: Open Jupyter Lab
1. Go to http://localhost:8888
2. Use token: `bigdata123`
3. Navigate to the `work` folder

### Step 2: Try Sample Notebooks
1. **01-hadoop-basics.ipynb** - Learn HDFS operations
2. **02-spark-intro.ipynb** - Spark fundamentals
3. **03-hive-sql.ipynb** - SQL operations with Hive
4. **04-integration.ipynb** - Full stack integration

### Step 3: Explore Web UIs
- Check **Hadoop NameNode UI** at http://localhost:9870
- Monitor **Spark jobs** at http://localhost:8080
- View **YARN applications** at http://localhost:8088

## 🔧 Management Commands

### Windows Scripts

| Command | Purpose |
|---------|---------|
| `scripts\setup.bat` | Initial environment setup |
| `scripts\start.bat` | Start all services |
| `scripts\stop.bat` | Stop all services |
| `scripts\validate.bat` | Health check all services |
| `scripts\logs.bat [service]` | View service logs |
| `scripts\cleanup.bat` | Remove all data and images |

### Docker Compose Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f [service_name]

# Check status
docker-compose ps

# Remove everything
docker-compose down -v --rmi all
```

## 📁 Directory Structure

```
BigDataEnv/
├── docker-compose.yml          # Main orchestration file
├── configs/                    # Configuration files
│   ├── hadoop/                # Hadoop configurations
│   ├── hive/                  # Hive configurations
│   ├── spark/                 # Spark configurations
│   └── jupyter/               # Jupyter configurations
├── scripts/                   # Management scripts
├── notebooks/                 # Sample Jupyter notebooks
├── data/samples/             # Sample datasets
└── docs/                     # Documentation
```

## 🐛 Troubleshooting

### Common Issues

**1. Port Conflicts**
```bash
# Check what's using the ports
netstat -ano | findstr :8888
netstat -ano | findstr :9870

# Stop conflicting services or change ports in docker-compose.yml
```

**2. Memory Issues**
```bash
# Increase Docker memory allocation in Docker Desktop settings
# Recommended: 8GB+ RAM for Docker
```

**3. Services Not Starting**
```bash
# Check logs for specific service
scripts\logs.bat namenode
scripts\logs.bat spark-master

# Or view all logs
docker-compose logs
```

**4. Connection Refused Errors**
```bash
# Wait for services to fully start (can take 2-3 minutes)
# Check service health
scripts\validate.bat
```

### Service Startup Order

Services start in this order with health checks:
1. PostgreSQL (database)
2. Hadoop NameNode
3. Hadoop DataNode
4. YARN ResourceManager
5. YARN NodeManager
6. Hive Metastore
7. HiveServer2
8. Spark Master
9. Spark Worker
10. Jupyter Lab

## 📈 Performance Tuning

### Memory Settings

Edit `docker-compose.yml` to adjust memory:

```yaml
environment:
  - SPARK_WORKER_MEMORY=2G    # Increase worker memory
  - YARN_CONF_yarn_nodemanager_resource_memory___mb=4096
```

### Storage Settings

Data is persisted in Docker volumes:
- `postgres_data` - PostgreSQL data
- `hadoop_namenode` - HDFS metadata
- `hadoop_datanode` - HDFS data blocks
- `spark_master_data` - Spark master data
- `spark_worker_data` - Spark worker data

## 🔒 Security Notes

- This is a **development environment** - not production-ready
- Default passwords are used - change them for production
- No authentication is enabled - add security for production use
- All services run with elevated privileges for simplicity

## 🆘 Getting Help

1. Check the **troubleshooting.md** file
2. View service logs: `scripts\logs.bat [service_name]`
3. Validate environment: `scripts\validate.bat`
4. Check Docker status: `docker-compose ps`

## 🎯 Next Steps

After setup:
1. Complete all sample notebooks
2. Try uploading your own data
3. Create custom Spark applications
4. Explore Hive SQL operations
5. Build data pipelines

Happy Big Data Learning! 🚀