# Jupyter Lab Configuration for Big Data Environment
# This configuration sets up Jupyter with PySpark integration

import os
import sys

# Jupyter Lab Configuration
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.open_browser = False
c.ServerApp.allow_root = True
c.ServerApp.token = 'bigdata123'
c.ServerApp.password = ''

# Allow connections from any origin (for Docker environment)
c.ServerApp.allow_origin = '*'
c.ServerApp.disable_check_xsrf = True

# Content management
c.FileContentsManager.delete_to_trash = False

# Kernel management
c.MultiKernelManager.default_kernel_name = 'python3'

# Session management
c.SessionManager.enable_async = True

# PySpark Integration Environment Variables
os.environ['SPARK_HOME'] = '/opt/spark'
os.environ['PYSPARK_PYTHON'] = '/opt/conda/bin/python'
os.environ['PYSPARK_DRIVER_PYTHON'] = '/opt/conda/bin/python'
os.environ['PYSPARK_DRIVER_PYTHON_OPTS'] = 'lab'

# Hadoop Configuration
os.environ['HADOOP_HOME'] = '/opt/hadoop'
os.environ['HADOOP_CONF_DIR'] = '/opt/hadoop/etc/hadoop'
os.environ['YARN_CONF_DIR'] = '/opt/hadoop/etc/hadoop'

# Hive Configuration  
os.environ['HIVE_HOME'] = '/opt/hive'
os.environ['HIVE_CONF_DIR'] = '/opt/hive/conf'

# Java Configuration
os.environ['JAVA_HOME'] = '/opt/java/openjdk'

# Add Spark to Python path
spark_python_path = '/opt/spark/python'
if spark_python_path not in sys.path:
    sys.path.insert(0, spark_python_path)

spark_py4j_path = '/opt/spark/python/lib/py4j-0.10.9.7-src.zip'
if os.path.exists(spark_py4j_path) and spark_py4j_path not in sys.path:
    sys.path.insert(0, spark_py4j_path)

# Logging configuration
import logging
logging.getLogger('py4j').setLevel(logging.ERROR)

# Custom startup message
print("=" * 60)
print("🚀 Big Data Environment - Jupyter Lab")
print("=" * 60)
print("📊 Spark Master: spark://spark-master:7077")
print("🗄️  HDFS: hdfs://namenode:9000")
print("🔍 Hive Metastore: thrift://hive-metastore:9083")
print("🌐 Access Token: bigdata123")
print("=" * 60)