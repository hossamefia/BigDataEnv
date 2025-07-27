# 📖 Setup Guide

Complete step-by-step guide to set up your Big Data testing environment.

## 🔧 Prerequisites

### System Requirements
- **Operating System**: Windows 10/11 (scripts optimized for Windows)
- **RAM**: 8GB minimum, 16GB recommended
- **Disk Space**: 10GB free space
- **CPU**: 4+ cores recommended

### Required Software
1. **Docker Desktop for Windows**
   - Download from: https://www.docker.com/products/docker-desktop
   - Version: Latest stable (20.10+)
   - **Important**: Enable WSL 2 backend if using Windows 10/11

2. **Git** (optional, for cloning)
   - Download from: https://git-scm.com/download/windows
   - Any recent version

## 🚀 Installation Steps

### Step 1: Download the Project

#### Option A: Clone with Git
```bash
git clone https://github.com/hossamefia/BigDataEnv.git
cd BigDataEnv
```

#### Option B: Download ZIP
1. Go to: https://github.com/hossamefia/BigDataEnv
2. Click "Code" → "Download ZIP"
3. Extract to desired location
4. Open Command Prompt in the extracted folder

### Step 2: Docker Configuration

#### Configure Docker Desktop
1. **Open Docker Desktop**
2. **Go to Settings** (gear icon)
3. **Resources** → **Advanced**
   - Memory: Set to **8GB or more**
   - CPUs: Use **4 or more** cores
   - Disk image size: **60GB or more**
4. **Apply & Restart**

#### Enable Required Features
1. **WSL 2** (Windows 10/11):
   - Settings → General → "Use WSL 2 based engine" ✅
2. **File Sharing**:
   - Resources → File Sharing → Add your project directory
3. **Enable BuildKit**:
   - Features in development → "Use Docker Compose V2" ✅

### Step 3: Initial Setup

#### Run Setup Script
```bash
# Navigate to project directory
cd BigDataEnv

# Run initial setup (this may take 15-30 minutes)
scripts\setup.bat
```

#### What the Setup Does:
- ✅ Verifies Docker installation
- ✅ Pulls all required Docker images (~8GB download)
- ✅ Creates necessary directories
- ✅ Validates image compatibility
- ✅ Prepares the environment for first run

### Step 4: Start the Environment

#### Start All Services
```bash
# Start the Big Data stack
scripts\start.bat
```

#### Startup Process:
1. **PostgreSQL** starts first (metastore database)
2. **Hadoop NameNode** initializes HDFS
3. **Hadoop DataNode** connects to NameNode
4. **YARN ResourceManager** starts cluster management
5. **YARN NodeManager** registers with ResourceManager
6. **Hive Metastore** connects to PostgreSQL
7. **HiveServer2** starts SQL interface
8. **Spark Master** starts cluster coordinator
9. **Spark Worker** registers with Master
10. **Jupyter Lab** starts development environment

**⏱️ Total startup time: 2-3 minutes**

### Step 5: Validation

#### Verify Installation
```bash
# Check all services are healthy
scripts\validate.bat
```

#### Expected Output:
```
✅ PostgreSQL is healthy
✅ NameNode Web UI is accessible
✅ DataNode Web UI is accessible
✅ ResourceManager Web UI is accessible
✅ NodeManager Web UI is accessible
✅ Spark Master Web UI is accessible
✅ Spark Worker Web UI is accessible
✅ HiveServer2 Web UI is accessible
✅ Jupyter Lab is accessible
✅ HDFS is accessible
✅ Hive Metastore is accessible
```

## 🌐 Access Your Environment

### Service URLs
Once setup is complete, access these services:

| Service | URL | Purpose |
|---------|-----|---------|
| **Jupyter Lab** | http://localhost:8888 | Interactive development |
| **Hadoop NameNode** | http://localhost:9870 | HDFS management |
| **YARN ResourceManager** | http://localhost:8088 | Cluster resources |
| **Spark Master** | http://localhost:8080 | Spark cluster |
| **HiveServer2** | http://localhost:10002 | Hive SQL interface |
| **Spark Application** | http://localhost:4040 | Active Spark apps |

### Default Credentials
- **Jupyter Lab Token**: `bigdata123`
- **Database User**: `hive`
- **Database Password**: `hive123`

## 📚 First Steps

### 1. Open Jupyter Lab
1. Navigate to: http://localhost:8888
2. Enter token: `bigdata123`
3. You'll see the notebook directory with 4 learning notebooks

### 2. Start with Hadoop Basics
1. Open `notebooks/01-hadoop-basics.ipynb`
2. Run through the cells to learn HDFS operations
3. Explore file upload/download and directory management

### 3. Explore the Sample Data
The environment includes realistic sample datasets:
- `data/samples/users.csv` - User demographics
- `data/samples/transactions.json` - E-commerce transactions
- `data/samples/logs.txt` - Application logs

### 4. Follow the Learning Path
Complete the notebooks in order:
1. **01-hadoop-basics.ipynb** - HDFS fundamentals
2. **02-spark-intro.ipynb** - Spark DataFrames and SQL
3. **03-hive-sql.ipynb** - Data warehousing with Hive
4. **04-integration.ipynb** - Full stack integration

## 🔧 Configuration Customization

### Memory and CPU Tuning
Edit `docker-compose.yml` to adjust resources:

```yaml
# Example: Increase Spark worker memory
spark-worker:
  environment:
    SPARK_WORKER_MEMORY: 4g  # Change from 2g to 4g
    SPARK_WORKER_CORES: 4    # Change from 2 to 4
```

### Port Changes
If you have port conflicts, modify the port mappings:

```yaml
# Example: Change Jupyter port
jupyter:
  ports:
    - "9999:8888"  # Change from 8888:8888
```

### Data Persistence
All data is automatically persisted in Docker volumes:
- `postgres_data` - Database data
- `namenode_data` - HDFS metadata
- `datanode_data` - HDFS storage
- `spark_logs` - Spark application logs
- `jupyter_home` - Jupyter user data

## 🧹 Management

### Daily Operations
```bash
# Start environment
scripts\start.bat

# Check health
scripts\validate.bat

# Monitor services
scripts\monitor.bat

# Stop environment
scripts\stop.bat
```

### Maintenance
```bash
# View service logs
scripts\monitor.bat

# Complete reset (if needed)
scripts\cleanup.bat
scripts\setup.bat
```

## 🆘 Troubleshooting

### Common Setup Issues

#### Docker Not Starting
```bash
# Check Docker Desktop is running
# Restart Docker Desktop
# Check Windows services (Docker Desktop Service)
```

#### Insufficient Memory
```bash
# Increase Docker memory to 8GB+
# Close other applications
# Consider upgrading system RAM
```

#### Port Conflicts
```bash
# Check what's using required ports:
netstat -an | findstr :8888
netstat -an | findstr :9870

# Stop conflicting services or change ports in docker-compose.yml
```

#### Slow Downloads
```bash
# Docker images are large (~8GB total)
# Ensure stable internet connection
# Consider running setup during off-peak hours
```

#### Permission Issues
```bash
# Run Command Prompt as Administrator
# Ensure Docker has permission to access drive
# Check Windows Defender exclusions
```

### Getting Help
1. **Check logs**: `scripts\monitor.bat`
2. **Validate health**: `scripts\validate.bat`
3. **Review troubleshooting guide**: `docs\troubleshooting.md`
4. **GitHub Issues**: https://github.com/hossamefia/BigDataEnv/issues

## ✅ Setup Verification Checklist

Before proceeding, ensure:

- [ ] Docker Desktop is running and configured (8GB+ memory)
- [ ] All ports are available (8888, 9870, 8080, 8088, 10002)
- [ ] Setup script completed without errors
- [ ] All services pass validation checks
- [ ] Jupyter Lab accessible with token
- [ ] Sample notebooks visible in Jupyter
- [ ] Web UIs accessible for all services

## 🎯 Next Steps

Once setup is complete:

1. **📚 Learn**: Work through the sample notebooks
2. **🔍 Explore**: Check out the web UIs
3. **🛠️ Experiment**: Try your own data and queries
4. **📊 Analyze**: Build analytics and visualizations
5. **🚀 Scale**: Add more data sources and processing

**🎉 Welcome to your Big Data journey!**