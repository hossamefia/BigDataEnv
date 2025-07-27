# 🔧 Troubleshooting Guide

Comprehensive troubleshooting guide for the Big Data environment.

## 🚨 Quick Diagnosis

### Health Check Command
```bash
scripts\validate.bat
```

If all services show ✅, your environment is healthy. If you see ❌, continue with the relevant section below.

## 🐳 Docker Issues

### Docker Desktop Not Running
**Symptoms:**
- `docker: command not found`
- `Cannot connect to the Docker daemon`

**Solutions:**
```bash
# 1. Start Docker Desktop manually
# 2. Check Windows Services
services.msc → Docker Desktop Service → Start

# 3. Restart Docker Desktop
# Right-click Docker Desktop system tray → Restart

# 4. Check Docker status
docker info
```

### Insufficient Memory
**Symptoms:**
- Services failing to start
- Out of memory errors
- Slow performance

**Solutions:**
```bash
# 1. Increase Docker memory allocation
# Docker Desktop → Settings → Resources → Advanced → Memory: 8GB+

# 2. Close other applications
# 3. Check memory usage
docker stats

# 4. Reduce parallel services (if needed)
# Edit docker-compose.yml to start fewer services
```

### Docker Image Issues
**Symptoms:**
- `image not found`
- `failed to pull image`

**Solutions:**
```bash
# 1. Re-run setup to pull images
scripts\setup.bat

# 2. Manually pull problematic image
docker pull postgres:13
docker pull apache/hadoop:3.3.4
docker pull apache/spark:3.4.1-scala2.12-java11-python3-ubuntu

# 3. Check Docker Hub connectivity
ping registry-1.docker.io

# 4. Clear Docker cache
docker system prune -a
```

## 🌐 Network and Port Issues

### Port Already in Use
**Symptoms:**
- `port is already allocated`
- `bind: address already in use`

**Solutions:**
```bash
# 1. Find what's using the port
netstat -ano | findstr :8888
netstat -ano | findstr :9870

# 2. Stop the conflicting service
# Use Task Manager to end the process

# 3. Change ports in docker-compose.yml
# Edit port mappings like "9999:8888" instead of "8888:8888"

# 4. Restart with new configuration
scripts\stop.bat
scripts\start.bat
```

### Network Connectivity Issues
**Symptoms:**
- Services can't communicate
- `connection refused` errors

**Solutions:**
```bash
# 1. Check Docker network
docker network ls
docker network inspect bigdataenv_bigdata-network

# 2. Restart networking
scripts\stop.bat
docker network prune
scripts\start.bat

# 3. Check firewall settings
# Windows Defender Firewall → Allow app through firewall → Docker Desktop
```

## 🗄️ Service-Specific Issues

### PostgreSQL Issues
**Symptoms:**
- Hive metastore connection failures
- Database connection errors

**Diagnosis:**
```bash
# Check PostgreSQL status
docker exec bigdata-postgres pg_isready -U hive -d metastore

# View PostgreSQL logs
docker logs bigdata-postgres
```

**Solutions:**
```bash
# 1. Restart PostgreSQL
docker restart bigdata-postgres

# 2. Check database initialization
docker exec -it bigdata-postgres psql -U hive -d metastore -c "\dt"

# 3. Reset database (if needed)
scripts\stop.bat
docker volume rm bigdataenv_postgres_data
scripts\start.bat
```

### Hadoop HDFS Issues
**Symptoms:**
- NameNode not accessible
- HDFS file operations failing

**Diagnosis:**
```bash
# Check NameNode status
curl -f http://localhost:9870/

# Check HDFS health
docker exec bigdata-namenode hdfs dfsadmin -report

# View NameNode logs
docker logs bigdata-namenode
```

**Solutions:**
```bash
# 1. Restart Hadoop services
docker restart bigdata-namenode
docker restart bigdata-datanode

# 2. Format NameNode (if corrupted)
scripts\stop.bat
docker volume rm bigdataenv_namenode_data
docker volume rm bigdataenv_datanode_data
scripts\start.bat

# 3. Check HDFS directories
docker exec bigdata-namenode hdfs dfs -ls /
```

### Spark Issues
**Symptoms:**
- Spark jobs failing
- Master/Worker not connecting

**Diagnosis:**
```bash
# Check Spark Master status
curl -f http://localhost:8080/

# Check worker registration
# View Spark Master UI → Workers tab

# View Spark logs
docker logs bigdata-spark-master
docker logs bigdata-spark-worker
```

**Solutions:**
```bash
# 1. Restart Spark cluster
docker restart bigdata-spark-master
docker restart bigdata-spark-worker

# 2. Check resource allocation
# Spark Master UI → Applications tab

# 3. Increase worker resources
# Edit docker-compose.yml → spark-worker → SPARK_WORKER_MEMORY
```

### Hive Issues
**Symptoms:**
- Hive queries failing
- Metastore connection errors

**Diagnosis:**
```bash
# Check Hive Metastore
docker exec bigdata-hive-metastore /opt/hive/bin/hive --version

# Check HiveServer2
curl -f http://localhost:10002/

# View Hive logs
docker logs bigdata-hive-metastore
docker logs bigdata-hiveserver2
```

**Solutions:**
```bash
# 1. Restart Hive services
docker restart bigdata-hive-metastore
docker restart bigdata-hiveserver2

# 2. Reinitialize schema
docker exec bigdata-hive-metastore /opt/hive/bin/schematool -dbType postgres -initSchema

# 3. Check PostgreSQL connection
docker exec bigdata-hive-metastore /opt/hive/bin/hive --service hiveserver2 --hiveconf hive.server2.enable.doAs=false
```

### Jupyter Issues
**Symptoms:**
- Can't access Jupyter Lab
- Kernel connection issues
- PySpark not working

**Diagnosis:**
```bash
# Check Jupyter status
curl -f http://localhost:8888/

# View Jupyter logs
docker logs bigdata-jupyter

# Check available kernels
docker exec bigdata-jupyter jupyter kernelspec list
```

**Solutions:**
```bash
# 1. Restart Jupyter
docker restart bigdata-jupyter

# 2. Reset Jupyter token
# Edit docker-compose.yml → jupyter → command → change token

# 3. Check PySpark configuration
# In Jupyter notebook:
import pyspark
print(pyspark.__version__)

# 4. Clear browser cache and cookies
```

## 📊 Performance Issues

### Slow Startup
**Symptoms:**
- Services take too long to start
- Timeouts during initialization

**Solutions:**
```bash
# 1. Increase Docker resources
# Memory: 8GB+, CPU: 4+ cores

# 2. Check system resources
# Task Manager → Performance tab

# 3. Sequential startup (if needed)
# Edit docker-compose.yml → add longer depends_on delays

# 4. Close unnecessary applications
```

### Slow Query Performance
**Symptoms:**
- Spark jobs taking too long
- Hive queries slow

**Solutions:**
```bash
# 1. Increase Spark executor memory
# Edit configs/spark/spark-defaults.conf

# 2. Enable caching for frequently used data
# In notebooks: df.cache()

# 3. Optimize data partitioning
# Use partitioned tables in Hive

# 4. Check resource allocation
# Spark Master UI → Executors tab
```

### Memory Issues
**Symptoms:**
- Out of memory errors
- Containers being killed

**Solutions:**
```bash
# 1. Monitor memory usage
docker stats

# 2. Increase container memory limits
# Edit docker-compose.yml → services → mem_limit

# 3. Optimize Spark memory settings
# configs/spark/spark-defaults.conf → executor.memory

# 4. Use data sampling for large datasets
# In notebooks: df.sample(0.1)
```

## 🧹 Data Issues

### Data Not Persisting
**Symptoms:**
- Data lost after restart
- Volumes empty

**Solutions:**
```bash
# 1. Check Docker volumes
docker volume ls

# 2. Inspect volume mounts
docker inspect bigdata-namenode

# 3. Backup important data
# Export from Jupyter before major changes

# 4. Ensure proper volume configuration
# Check docker-compose.yml → volumes section
```

### Corrupted Data
**Symptoms:**
- HDFS corruption errors
- Database consistency issues

**Solutions:**
```bash
# 1. Check HDFS integrity
docker exec bigdata-namenode hdfs fsck /

# 2. Repair HDFS (if possible)
docker exec bigdata-namenode hdfs dfsadmin -safemode enter
docker exec bigdata-namenode hdfs dfsadmin -safemode leave

# 3. Reset data (last resort)
scripts\cleanup.bat
scripts\setup.bat
```

## 🆘 Emergency Procedures

### Complete Reset
When all else fails:
```bash
# 1. Stop everything
scripts\stop.bat

# 2. Complete cleanup
scripts\cleanup.bat

# 3. Fresh start
scripts\setup.bat
scripts\start.bat
```

### Backup Before Reset
```bash
# 1. Export Jupyter notebooks
# Download from Jupyter Lab interface

# 2. Export important data
# Use HDFS commands or Spark to save data externally

# 3. Note custom configurations
# Copy any modified config files
```

### Partial Reset
Reset specific components:
```bash
# Reset only PostgreSQL
docker stop bigdata-postgres
docker volume rm bigdataenv_postgres_data
docker-compose up -d postgres

# Reset only HDFS
docker stop bigdata-namenode bigdata-datanode
docker volume rm bigdataenv_namenode_data bigdataenv_datanode_data
docker-compose up -d namenode datanode
```

## 📞 Getting Help

### Self-Diagnosis Steps
1. **Run validation**: `scripts\validate.bat`
2. **Check logs**: `scripts\monitor.bat`
3. **Review system resources**: Task Manager
4. **Check Docker status**: `docker info`
5. **Verify ports**: `netstat -an`

### Information to Provide
When asking for help, include:
- **Error messages** (exact text)
- **Validation output** (from validate.bat)
- **System specs** (RAM, CPU, Windows version)
- **Docker version** (`docker --version`)
- **Steps to reproduce** the issue

### Support Channels
- **GitHub Issues**: https://github.com/hossamefia/BigDataEnv/issues
- **Documentation**: Check all files in `docs/` folder
- **Logs**: Always check `scripts\monitor.bat` first

## 🔍 Advanced Diagnostics

### Container Inspection
```bash
# Check container status
docker ps -a

# Inspect specific container
docker inspect bigdata-namenode

# Check container resources
docker stats --no-stream

# View container processes
docker exec bigdata-namenode ps aux
```

### Network Diagnostics
```bash
# Test container connectivity
docker exec bigdata-jupyter ping namenode
docker exec bigdata-spark-master ping hive-metastore

# Check DNS resolution
docker exec bigdata-jupyter nslookup postgres

# Inspect network configuration
docker network inspect bigdataenv_bigdata-network
```

### Log Analysis
```bash
# Real-time log monitoring
docker logs -f bigdata-namenode

# Search logs for errors
docker logs bigdata-postgres 2>&1 | findstr ERROR

# Export logs for analysis
docker logs bigdata-spark-master > spark-master.log
```

## ⚠️ Prevention Tips

### Regular Maintenance
- **Weekly**: Run `scripts\validate.bat`
- **Monthly**: Check for Docker updates
- **Before important work**: Backup notebooks and data
- **After changes**: Validate all services

### Best Practices
- **Monitor resources**: Keep Docker stats handy
- **Clean regularly**: Use `docker system prune` monthly
- **Update gradually**: Test updates in separate environment
- **Document changes**: Note any customizations made

**🎯 Remember: Most issues are resolved by restarting services or resetting the environment!**