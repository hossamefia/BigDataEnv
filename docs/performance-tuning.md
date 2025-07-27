# ⚡ Performance Tuning Guide

Comprehensive guide to optimize performance in your Big Data environment.

## 🎯 Performance Overview

### Performance Goals
- **Startup Time**: < 3 minutes for all services
- **Query Response**: Sub-second for simple queries
- **Data Processing**: Efficient resource utilization
- **Memory Usage**: Optimal allocation across services
- **Storage I/O**: Minimized disk bottlenecks

## 🏗️ System-Level Optimization

### Docker Configuration
```yaml
# Recommended Docker Desktop settings
Memory: 12-16GB (minimum 8GB)
CPUs: 6-8 cores (minimum 4)
Disk: 100GB+ free space
Swap: 2GB
```

### Host System Optimization
```bash
# Windows Performance Settings
# 1. Disable Windows Search indexing for Docker directories
# 2. Add Docker directories to Windows Defender exclusions
# 3. Enable High Performance power plan
# 4. Increase virtual memory if needed
```

### Docker Engine Tuning
```json
// %USERPROFILE%\.docker\daemon.json
{
  "storage-driver": "windowsfilter",
  "max-concurrent-downloads": 6,
  "max-concurrent-uploads": 6,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

## 🐳 Container-Level Optimization

### Memory Allocation Strategy
```yaml
# Optimized memory allocation for 12GB system
services:
  postgres:
    mem_limit: 1g
    
  namenode:
    mem_limit: 1.5g
    environment:
      - HDFS_NAMENODE_OPTS=-Xmx1200m
    
  datanode:
    mem_limit: 1g
    environment:
      - HDFS_DATANODE_OPTS=-Xmx800m
    
  resourcemanager:
    mem_limit: 1.5g
    environment:
      - YARN_RESOURCEMANAGER_OPTS=-Xmx1200m
    
  nodemanager:
    mem_limit: 1.5g
    environment:
      - YARN_NODEMANAGER_OPTS=-Xmx1200m
      - YARN_CONF_yarn_nodemanager_resource_memory_mb=3072
    
  spark-master:
    mem_limit: 1g
    environment:
      - SPARK_MASTER_OPTS=-Xmx800m
    
  spark-worker:
    mem_limit: 4g
    environment:
      - SPARK_WORKER_MEMORY=3g
      - SPARK_WORKER_CORES=4
      - SPARK_WORKER_OPTS=-Xmx800m
    
  jupyter:
    mem_limit: 2g
```

### CPU Allocation
```yaml
# CPU limits and affinity
services:
  spark-worker:
    cpus: '3.0'
    
  namenode:
    cpus: '1.0'
    
  resourcemanager:
    cpus: '1.0'
    
  jupyter:
    cpus: '2.0'
```

## ⚙️ Hadoop Optimization

### HDFS Performance Tuning
```xml
<!-- configs/hadoop/hdfs-site.xml -->
<configuration>
  <!-- Increase block size for large files -->
  <property>
    <name>dfs.blocksize</name>
    <value>268435456</value> <!-- 256MB -->
  </property>
  
  <!-- Enable short-circuit reads -->
  <property>
    <name>dfs.client.read.shortcircuit</name>
    <value>true</value>
  </property>
  
  <!-- Optimize DataNode -->
  <property>
    <name>dfs.datanode.max.transfer.threads</name>
    <value>8192</value>
  </property>
  
  <!-- Increase handler threads -->
  <property>
    <name>dfs.namenode.handler.count</name>
    <value>20</value>
  </property>
  
  <!-- Enable async disk service -->
  <property>
    <name>dfs.datanode.fsdataset.volume.choosing.policy</name>
    <value>org.apache.hadoop.hdfs.server.datanode.fsdataset.AvailableSpaceVolumeChoosingPolicy</value>
  </property>
</configuration>
```

### YARN Resource Management
```xml
<!-- configs/hadoop/yarn-site.xml -->
<configuration>
  <!-- Increase memory allocation -->
  <property>
    <name>yarn.nodemanager.resource.memory-mb</name>
    <value>4096</value>
  </property>
  
  <!-- Increase CPU allocation -->
  <property>
    <name>yarn.nodemanager.resource.cpu-vcores</name>
    <value>4</value>
  </property>
  
  <!-- Optimize scheduler -->
  <property>
    <name>yarn.scheduler.maximum-allocation-mb</name>
    <value>4096</value>
  </property>
  
  <!-- Enable preemption -->
  <property>
    <name>yarn.resourcemanager.scheduler.monitor.enable</name>
    <value>true</value>
  </property>
  
  <!-- Optimize container launch -->
  <property>
    <name>yarn.nodemanager.container-executor.class</name>
    <value>org.apache.hadoop.yarn.server.nodemanager.DefaultContainerExecutor</value>
  </property>
</configuration>
```

## ⚡ Spark Optimization

### Spark Configuration Tuning
```properties
# configs/spark/spark-defaults.conf - Performance Optimized
# Memory Management
spark.executor.memory               3g
spark.executor.cores                2
spark.executor.instances            2
spark.driver.memory                 1g
spark.driver.cores                  2

# Dynamic Allocation
spark.dynamicAllocation.enabled              true
spark.dynamicAllocation.minExecutors         1
spark.dynamicAllocation.maxExecutors         4
spark.dynamicAllocation.initialExecutors     2
spark.dynamicAllocation.executorIdleTimeout  60s

# Serialization (Performance Critical)
spark.serializer                    org.apache.spark.serializer.KryoSerializer
spark.kryo.unsafe                   true
spark.kryo.referenceTracking        false

# SQL Optimizations
spark.sql.adaptive.enabled                    true
spark.sql.adaptive.coalescePartitions.enabled true
spark.sql.adaptive.skewJoin.enabled           true
spark.sql.adaptive.localShuffleReader.enabled true

# Shuffle Optimization
spark.shuffle.compress              true
spark.shuffle.spill.compress        true
spark.io.compression.codec          snappy

# Network and Communication
spark.network.timeout               300s
spark.executor.heartbeatInterval    30s
spark.rpc.askTimeout               120s

# Garbage Collection
spark.executor.extraJavaOptions     -XX:+UseG1GC -XX:+UnlockDiagnosticVMOptions -XX:+G1UseAdaptiveIHOP
spark.driver.extraJavaOptions       -XX:+UseG1GC

# Event Logging
spark.eventLog.enabled              true
spark.eventLog.dir                  hdfs://namenode:9000/spark-history
spark.eventLog.compress             true

# Caching
spark.sql.cache.serializer          org.apache.spark.sql.execution.columnar.InMemoryTableScanExec
```

### Spark Job Optimization Patterns
```python
# Notebook optimization examples

# 1. DataFrame Caching Strategy
def optimize_caching(df):
    """Intelligent caching based on data size"""
    estimated_size = df.count() * len(df.columns) * 8  # Rough estimate
    if estimated_size < 1_000_000:  # < 1MB
        return df.cache()
    elif estimated_size < 100_000_000:  # < 100MB
        return df.persist(StorageLevel.MEMORY_AND_DISK)
    else:
        return df  # Don't cache very large datasets

# 2. Partition Optimization
def optimize_partitions(df, target_partition_size_mb=128):
    """Optimize DataFrame partitioning"""
    current_partitions = df.rdd.getNumPartitions()
    estimated_size_mb = df.count() * len(df.columns) * 8 / 1024 / 1024
    optimal_partitions = max(1, int(estimated_size_mb / target_partition_size_mb))
    
    if abs(current_partitions - optimal_partitions) > 2:
        return df.repartition(optimal_partitions)
    return df

# 3. Broadcast Join Optimization
spark.conf.set("spark.sql.autoBroadcastJoinThreshold", "50MB")

# 4. Column Pruning and Predicate Pushdown
# Always select only needed columns early
df_optimized = df.select("col1", "col2", "col3") \
                .filter(col("date") >= "2024-01-01") \
                .cache()
```

## 🗄️ Hive Optimization

### Hive Configuration Tuning
```xml
<!-- configs/hive/hive-site.xml - Performance additions -->
<configuration>
  <!-- Enable Cost-Based Optimizer -->
  <property>
    <name>hive.cbo.enable</name>
    <value>true</value>
  </property>
  
  <!-- Optimize JOIN operations -->
  <property>
    <name>hive.auto.convert.join</name>
    <value>true</value>
  </property>
  
  <property>
    <name>hive.auto.convert.join.noconditionaltask.size</name>
    <value>52428800</value> <!-- 50MB -->
  </property>
  
  <!-- Enable vectorization -->
  <property>
    <name>hive.vectorized.execution.enabled</name>
    <value>true</value>
  </property>
  
  <!-- Optimize GROUP BY -->
  <property>
    <name>hive.groupby.skewindata</name>
    <value>true</value>
  </property>
  
  <!-- Enable predicate pushdown -->
  <property>
    <name>hive.optimize.ppd</name>
    <value>true</value>
  </property>
  
  <!-- Connection pooling -->
  <property>
    <name>datanucleus.connectionPool.maxPoolSize</name>
    <value>25</value>
  </property>
</configuration>
```

### Hive Query Optimization
```sql
-- 1. Use partitioned tables for large datasets
CREATE TABLE sales_partitioned (
    product_id INT,
    amount DECIMAL(10,2),
    customer_id INT
)
PARTITIONED BY (year INT, month INT)
STORED AS PARQUET;

-- 2. Enable statistics collection
ANALYZE TABLE sales_partitioned COMPUTE STATISTICS;
ANALYZE TABLE sales_partitioned COMPUTE STATISTICS FOR COLUMNS;

-- 3. Use appropriate file formats
-- Parquet for analytics (columnar)
-- ORC for transactional workloads
-- Avro for schema evolution

-- 4. Optimize JOINs
SET hive.auto.convert.join=true;
SET hive.mapjoin.smalltable.filesize=50000000;

-- 5. Use bucketing for frequently joined tables
CREATE TABLE customers_bucketed (
    customer_id INT,
    name STRING,
    country STRING
)
CLUSTERED BY (customer_id) INTO 4 BUCKETS
STORED AS PARQUET;
```

## 💾 Storage Optimization

### HDFS Storage Optimization
```bash
# 1. Regular HDFS maintenance
docker exec bigdata-namenode hdfs dfsadmin -report
docker exec bigdata-namenode hdfs fsck / -files -blocks -locations

# 2. Balance HDFS blocks (if multiple DataNodes)
docker exec bigdata-namenode hdfs balancer -threshold 5

# 3. Clean up trash regularly
docker exec bigdata-namenode hdfs dfs -expunge

# 4. Optimize small files
# Use Parquet or ORC for better compression
# Combine small files using Spark
```

### Data Format Optimization
```python
# Performance comparison of formats
import time

# 1. CSV (slowest, largest)
start = time.time()
df_csv = spark.read.option("header", "true").csv("hdfs://namenode:9000/data.csv")
df_csv.count()
csv_time = time.time() - start

# 2. Parquet (fastest for analytics)
start = time.time()
df_parquet = spark.read.parquet("hdfs://namenode:9000/data.parquet")
df_parquet.count()
parquet_time = time.time() - start

# 3. Delta Lake (best for updates)
# df.write.format("delta").save("hdfs://namenode:9000/data_delta")

print(f"CSV read time: {csv_time:.2f}s")
print(f"Parquet read time: {parquet_time:.2f}s")
print(f"Speedup: {csv_time/parquet_time:.1f}x")
```

## 📊 Query Optimization

### Spark SQL Optimization
```python
# 1. Use explain() to understand query plans
df.explain(extended=True)

# 2. Enable adaptive query execution
spark.conf.set("spark.sql.adaptive.enabled", "true")
spark.conf.set("spark.sql.adaptive.coalescePartitions.enabled", "true")

# 3. Optimize window functions
from pyspark.sql.window import Window

# Instead of multiple window functions, use one
windowSpec = Window.partitionBy("category").orderBy("date")
df_optimized = df.withColumn("row_number", row_number().over(windowSpec)) \
                .withColumn("rank", rank().over(windowSpec))

# 4. Use broadcast joins for small tables
from pyspark.sql.functions import broadcast
result = large_df.join(broadcast(small_df), "key")

# 5. Optimize aggregations
# Use approx functions when exact precision isn't needed
df.select(approx_count_distinct("user_id")).show()
```

### Database Query Patterns
```sql
-- 1. Use appropriate indexes (in PostgreSQL metastore)
CREATE INDEX idx_hive_tables_db_name ON "TBLS"("DB_ID", "TBL_NAME");

-- 2. Optimize WHERE clauses
-- Push filters down to storage layer
SELECT * FROM large_table 
WHERE partition_date >= '2024-01-01'  -- Partition pruning
  AND status = 'active'              -- Early filtering

-- 3. Use LIMIT for exploration
SELECT * FROM large_table LIMIT 1000;

-- 4. Optimize JOINs
-- Join order matters - put largest table last
SELECT a.*, b.name 
FROM small_table a
JOIN large_table b ON a.id = b.id;
```

## 🔍 Monitoring and Profiling

### Performance Monitoring Setup
```python
# Jupyter notebook performance monitoring
import time
import psutil
import matplotlib.pyplot as plt

def monitor_performance(func):
    """Decorator to monitor function performance"""
    def wrapper(*args, **kwargs):
        start_time = time.time()
        start_memory = psutil.virtual_memory().used / 1024 / 1024
        
        result = func(*args, **kwargs)
        
        end_time = time.time()
        end_memory = psutil.virtual_memory().used / 1024 / 1024
        
        print(f"Execution time: {end_time - start_time:.2f} seconds")
        print(f"Memory usage: {end_memory - start_memory:.2f} MB")
        
        return result
    return wrapper

# Usage
@monitor_performance
def process_large_dataset():
    df = spark.read.parquet("hdfs://namenode:9000/large_dataset.parquet")
    return df.groupBy("category").sum("amount").collect()
```

### Resource Monitoring Commands
```bash
# Container resource usage
docker stats --no-stream

# HDFS usage
docker exec bigdata-namenode hdfs dfs -df -h

# YARN resource usage
# Check ResourceManager UI: http://localhost:8088

# Spark application metrics
# Check Spark Master UI: http://localhost:8080
# Check Spark Application UI: http://localhost:4040
```

## 🚀 Advanced Optimizations

### JVM Tuning
```yaml
# Advanced JVM options for better performance
services:
  namenode:
    environment:
      - HDFS_NAMENODE_OPTS=-Xmx2g -XX:+UseG1GC -XX:MaxGCPauseMillis=200
  
  spark-worker:
    environment:
      - SPARK_WORKER_OPTS=-Xmx1g -XX:+UseG1GC -XX:+UnlockDiagnosticVMOptions
```

### Network Optimization
```yaml
# Docker network optimization
networks:
  bigdata-network:
    driver: bridge
    driver_opts:
      com.docker.network.driver.mtu: 1500
    ipam:
      driver: default
      config:
        - subnet: 172.25.0.0/16
```

### Disk I/O Optimization
```bash
# Use faster storage for Docker volumes
# 1. Move Docker data directory to SSD
# 2. Use direct I/O when possible
# 3. Monitor disk queue length

# Windows disk optimization
# 1. Disable drive indexing for Docker directories
# 2. Enable write caching
# 3. Use NTFS compression judiciously
```

## 🎯 Performance Testing

### Benchmark Scripts
```python
# Create benchmark data
def create_benchmark_data(spark, num_records=1000000):
    """Create benchmark dataset"""
    from pyspark.sql.functions import rand, randn
    
    df = spark.range(num_records) \
        .withColumn("value", rand()) \
        .withColumn("category", (rand() * 10).cast("int")) \
        .withColumn("amount", randn() * 1000)
    
    return df

# Performance tests
def run_performance_tests(spark):
    """Run comprehensive performance tests"""
    # Create test data
    df = create_benchmark_data(spark, 5000000)
    
    # Test 1: Caching performance
    start = time.time()
    df.cache().count()
    cache_time = time.time() - start
    
    # Test 2: Aggregation performance
    start = time.time()
    df.groupBy("category").sum("amount").collect()
    agg_time = time.time() - start
    
    # Test 3: Join performance
    df2 = spark.range(10).withColumn("category", col("id"))
    start = time.time()
    df.join(df2, "category").count()
    join_time = time.time() - start
    
    print(f"Cache time: {cache_time:.2f}s")
    print(f"Aggregation time: {agg_time:.2f}s")
    print(f"Join time: {join_time:.2f}s")
```

## 📈 Performance Baselines

### Expected Performance Metrics
```
Startup Times (on 8GB/4-core system):
- PostgreSQL: 10-15 seconds
- HDFS services: 30-45 seconds
- YARN services: 20-30 seconds
- Hive services: 45-60 seconds
- Spark cluster: 20-30 seconds
- Jupyter Lab: 15-20 seconds
- Total: 2-3 minutes

Query Performance:
- Simple SELECT: < 1 second
- GROUP BY aggregation: 2-5 seconds
- JOIN operations: 3-10 seconds
- Complex analytics: 10-60 seconds

Data Processing:
- CSV to Parquet (1GB): 30-60 seconds
- Large aggregations (10M rows): 10-30 seconds
- ML feature preparation: 30-120 seconds
```

## 🔧 Troubleshooting Performance Issues

### Common Performance Problems
1. **Slow startup**: Increase Docker memory/CPU
2. **Out of memory**: Optimize Spark executor memory
3. **Slow queries**: Check partition strategy and caching
4. **High disk I/O**: Use columnar formats (Parquet)
5. **Network bottlenecks**: Optimize data locality

### Performance Diagnosis Steps
1. **Monitor resources**: `docker stats`
2. **Check service UIs**: Look for bottlenecks
3. **Analyze query plans**: Use `.explain()`
4. **Profile applications**: Use Spark UI
5. **Validate configuration**: Review tuning parameters

Remember: **Performance tuning is iterative**. Start with the biggest bottlenecks and measure improvements after each change.