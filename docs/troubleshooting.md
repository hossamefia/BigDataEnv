# Big Data Environment - Troubleshooting Guide

## 🚨 Common Issues and Solutions

This guide covers the most common issues you might encounter and how to solve them.

## 🔧 Environment Issues

### Issue: Docker not found
```
Error: docker: command not found
```

**Solution:**
1. Install Docker Desktop from https://www.docker.com/products/docker-desktop
2. Ensure Docker Desktop is running
3. Restart your terminal/command prompt

### Issue: Port conflicts
```
Error: Port 8888 is already in use
```

**Solution:**
```bash
# Check what's using the port
netstat -ano | findstr :8888

# Kill the process using the port (Windows)
taskkill /PID <PID_NUMBER> /F

# Or change the port in docker-compose.yml
ports:
  - "8889:8888"  # Use different external port
```

### Issue: Insufficient memory
```
Error: Container killed due to out of memory
```

**Solution:**
1. Increase Docker Desktop memory allocation:
   - Open Docker Desktop Settings
   - Go to Resources → Advanced
   - Increase Memory to 8GB or more
   - Apply & Restart

2. Reduce memory usage in docker-compose.yml:
```yaml
environment:
  - SPARK_WORKER_MEMORY=1G  # Reduce from 2G
  - YARN_CONF_yarn_nodemanager_resource_memory___mb=2048
```

## 🐳 Container Issues

### Issue: Services not starting
```
Error: Container exits immediately
```

**Diagnostic Steps:**
```bash
# Check container status
docker compose ps

# View logs for specific service
scripts\logs.bat namenode
# or
docker compose logs namenode

# Check all container logs
docker compose logs
```

**Common Solutions:**
1. **Missing dependencies**: Ensure all volumes are properly mounted
2. **Permission issues**: On Linux, check file permissions
3. **Configuration errors**: Validate XML configuration files

### Issue: Health check failures
```
Warning: Service unhealthy
```

**Solution:**
```bash
# Check health status
docker compose ps

# Wait for full startup (services can take 2-3 minutes)
timeout /t 120  # Wait 2 minutes

# Re-run validation
scripts\validate.bat
```

### Issue: Network connectivity problems
```
Error: Connection refused
```

**Solution:**
1. **Check service startup order**: Services have dependencies
2. **Verify network**: All services should be on `bigdata-network`
3. **Wait for initialization**: HDFS formatting takes time on first run

```bash
# Check network
docker network ls | findstr bigdata

# Inspect network
docker network inspect bigdata-network
```

## 📊 Service-Specific Issues

### Hadoop NameNode Issues

**Issue: NameNode UI not accessible**
```bash
# Check NameNode logs
scripts\logs.bat namenode

# Common issues:
# 1. HDFS not formatted
# 2. Insufficient disk space
# 3. Port conflicts
```

**Solution:**
```bash
# Recreate namenode volume
docker compose down
docker volume rm bigdataenv_hadoop_namenode
docker compose up -d namenode
```

### Spark Issues

**Issue: Spark jobs failing with memory errors**

**Solution:**
1. Reduce dataset size for testing
2. Increase Spark memory allocation:
```python
spark = SparkSession.builder \
    .appName("MyApp") \
    .config("spark.executor.memory", "2g") \
    .config("spark.driver.memory", "1g") \
    .getOrCreate()
```

**Issue: Cannot connect to Spark Master**

**Solution:**
```bash
# Check Spark Master logs
scripts\logs.bat spark-master

# Verify Spark Master is running
curl http://localhost:8080
```

### Hive Issues

**Issue: Hive metastore connection failure**
```
Error: Could not connect to meta store
```

**Solution:**
```bash
# Check PostgreSQL is running
scripts\logs.bat postgres

# Check Hive Metastore logs
scripts\logs.bat hive-metastore

# Restart Hive services
docker compose restart hive-metastore hiveserver2
```

**Issue: Hive tables not found**

**Solution:**
```sql
-- Check current database
SELECT current_database();

-- List databases
SHOW DATABASES;

-- Use correct database
USE analytics;

-- List tables
SHOW TABLES;
```

### Jupyter Issues

**Issue: Jupyter Lab not starting**

**Solution:**
```bash
# Check Jupyter logs
scripts\logs.bat jupyter

# Common issues:
# 1. Port 8888 in use
# 2. Volume mount problems
# 3. Permission issues
```

**Issue: PySpark not working in Jupyter**

**Solution:**
```python
# Manual PySpark setup
import findspark
findspark.init()

from pyspark.sql import SparkSession
spark = SparkSession.builder \
    .appName("JupyterApp") \
    .config("spark.master", "spark://spark-master:7077") \
    .getOrCreate()
```

## 💾 Data Issues

### Issue: Data not persisting
```
Error: Data lost after container restart
```

**Solution:**
1. **Verify volumes are defined** in docker-compose.yml
2. **Check volume mounts** are correct
3. **Ensure data is written to persistent locations**:
   - HDFS: `hdfs://namenode:9000/...`
   - Hive tables: Use `saveAsTable()` not temporary views

### Issue: Cannot access HDFS
```
Error: No route to host
```

**Solution:**
```bash
# Check HDFS is running
curl http://localhost:9870

# Test HDFS connection from Jupyter
# Use correct HDFS URL: hdfs://namenode:9000
```

### Issue: File permission errors
```
Error: Permission denied
```

**Solution:**
```bash
# In Jupyter, create directories first
hadoop_fs = spark.sparkContext._jvm.org.apache.hadoop.fs.FileSystem.get(
    spark.sparkContext._jsc.hadoopConfiguration()
)
path = spark.sparkContext._jvm.org.apache.hadoop.fs.Path("/user/data")
hadoop_fs.mkdirs(path)
```

## 🔍 Diagnostic Commands

### Health Check Script
```bash
# Run comprehensive validation
scripts\validate.bat

# Manual health checks
curl -s http://localhost:9870/jmx | findstr "NameNode"
curl -s http://localhost:8088/ws/v1/cluster/info
curl -s http://localhost:8080/json/ | findstr "status"
```

### Log Analysis
```bash
# View all logs with timestamps
docker compose logs -f -t

# Filter logs by service
docker compose logs namenode | findstr ERROR
docker compose logs spark-master | findstr WARN

# Follow logs in real-time
scripts\logs.bat all
```

### Resource Monitoring
```bash
# Check Docker resource usage
docker stats

# Check container resource limits
docker compose ps
docker inspect bigdata-namenode | findstr -i memory

# Monitor disk usage
docker system df
```

## 🛠️ Recovery Procedures

### Complete Reset
```bash
# Stop everything
scripts\stop.bat

# Remove all data (WARNING: Data loss!)
scripts\cleanup.bat

# Fresh start
scripts\setup.bat
scripts\start.bat
```

### Partial Reset (Keep Data)
```bash
# Stop services
docker compose down

# Remove only containers (keep volumes)
docker compose down --remove-orphans

# Restart
docker compose up -d
```

### Service-Specific Restart
```bash
# Restart specific service
docker compose restart namenode

# Restart dependent services
docker compose restart namenode datanode

# Check dependency chain
docker compose ps
```

## 📊 Performance Issues

### Issue: Slow performance
**Causes:**
1. Insufficient RAM allocation
2. Using HDD instead of SSD
3. Too many parallel operations
4. Large datasets without partitioning

**Solutions:**
1. **Increase Docker memory allocation**
2. **Use SSD storage for Docker volumes**
3. **Optimize Spark configuration**:
```python
spark = SparkSession.builder \
    .config("spark.sql.adaptive.enabled", "true") \
    .config("spark.sql.adaptive.coalescePartitions.enabled", "true") \
    .config("spark.executor.memory", "2g") \
    .config("spark.executor.cores", "2") \
    .getOrCreate()
```

### Issue: Out of disk space
```bash
# Check disk usage
docker system df

# Clean up unused resources
docker system prune -f

# Remove unused volumes (be careful!)
docker volume prune
```

## 🔒 Security Issues

### Issue: Cannot connect to PostgreSQL
```bash
# Check PostgreSQL logs
scripts\logs.bat postgres

# Test connection
docker compose exec postgres psql -U hive -d metastore -c "\l"
```

### Issue: Hive authentication errors
**Solution:**
The environment uses simplified authentication. For production:
1. Enable Kerberos authentication
2. Configure proper user management
3. Set up HDFS permissions

## 🆘 Getting Additional Help

### When to Seek Help
1. **Error persists** after trying solutions
2. **Multiple services failing** simultaneously
3. **System-wide performance issues**
4. **Data corruption suspected**

### Information to Gather
Before seeking help, collect:

```bash
# Environment information
docker --version
docker compose version
systeminfo | findstr "Total Physical Memory"

# Service status
docker compose ps > status.txt

# Recent logs
docker compose logs --tail=100 > logs.txt

# Resource usage
docker stats --no-stream > resources.txt
```

### Debug Mode
Enable debug logging:
```yaml
# In docker-compose.yml, add:
environment:
  - SPARK_LOG_LEVEL=DEBUG
  - HADOOP_LOG_LEVEL=DEBUG
```

### Contact Support
1. **GitHub Issues**: Create issue with diagnostic information
2. **Documentation**: Check all documentation files
3. **Community Forums**: Spark, Hadoop, Docker communities

## ✅ Prevention Tips

### Best Practices
1. **Always run validation** after changes
2. **Monitor resource usage** regularly
3. **Keep backups** of important data
4. **Test with small datasets** first
5. **Update Docker Desktop** regularly

### Maintenance Schedule
- **Daily**: Check service health
- **Weekly**: Clean up unused Docker resources
- **Monthly**: Update Docker images
- **Quarterly**: Review and optimize configurations

---

**Remember**: This is a development environment. Many issues can be resolved with a fresh restart! 🔄

For complex issues, don't hesitate to use the complete reset procedure and start fresh. 🚀