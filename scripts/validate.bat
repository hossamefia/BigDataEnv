@echo off
REM ========================================================================
REM Big Data Environment - Validation Script
REM ========================================================================
REM This script performs comprehensive health checks on all services
REM ========================================================================

title Big Data Environment - Health Check
color 0E

echo.
echo ========================================================================
echo 🔍 Big Data Environment - Health Check
echo ========================================================================
echo.

REM Check if Docker is running
echo 📋 Checking Docker status...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not running
    pause
    exit /b 1
)

echo ✅ Docker is running
echo.

REM Function to check service health
echo 🏥 Checking service health...
echo.

REM Check PostgreSQL
echo 📊 PostgreSQL (Hive Metastore):
docker exec bigdata-postgres pg_isready -U hive -d metastore >nul 2>&1
if %errorlevel% eq 0 (
    echo    ✅ PostgreSQL is healthy
) else (
    echo    ❌ PostgreSQL is not responding
)

REM Check Hadoop NameNode
echo 📊 Hadoop NameNode:
curl -s -f http://localhost:9870/ >nul 2>&1
if %errorlevel% eq 0 (
    echo    ✅ NameNode Web UI is accessible
) else (
    echo    ❌ NameNode Web UI is not accessible
)

REM Check Hadoop DataNode  
echo 📊 Hadoop DataNode:
curl -s -f http://localhost:9864/ >nul 2>&1
if %errorlevel% eq 0 (
    echo    ✅ DataNode Web UI is accessible
) else (
    echo    ❌ DataNode Web UI is not accessible
)

REM Check YARN ResourceManager
echo 📊 YARN ResourceManager:
curl -s -f http://localhost:8088/ >nul 2>&1
if %errorlevel% eq 0 (
    echo    ✅ ResourceManager Web UI is accessible
) else (
    echo    ❌ ResourceManager Web UI is not accessible
)

REM Check YARN NodeManager
echo 📊 YARN NodeManager:
curl -s -f http://localhost:8042/ >nul 2>&1
if %errorlevel% eq 0 (
    echo    ✅ NodeManager Web UI is accessible
) else (
    echo    ❌ NodeManager Web UI is not accessible
)

REM Check Spark Master
echo 📊 Spark Master:
curl -s -f http://localhost:8080/ >nul 2>&1
if %errorlevel% eq 0 (
    echo    ✅ Spark Master Web UI is accessible
) else (
    echo    ❌ Spark Master Web UI is not accessible
)

REM Check Spark Worker
echo 📊 Spark Worker:
curl -s -f http://localhost:8081/ >nul 2>&1
if %errorlevel% eq 0 (
    echo    ✅ Spark Worker Web UI is accessible
) else (
    echo    ❌ Spark Worker Web UI is not accessible
)

REM Check HiveServer2
echo 📊 HiveServer2:
curl -s -f http://localhost:10002/ >nul 2>&1
if %errorlevel% eq 0 (
    echo    ✅ HiveServer2 Web UI is accessible
) else (
    echo    ❌ HiveServer2 Web UI is not accessible
)

REM Check Jupyter Lab
echo 📊 Jupyter Lab:
curl -s -f http://localhost:8888/ >nul 2>&1
if %errorlevel% eq 0 (
    echo    ✅ Jupyter Lab is accessible
) else (
    echo    ❌ Jupyter Lab is not accessible
)

echo.
echo 🔗 Testing service connectivity...
echo.

REM Test HDFS connectivity
echo 📁 Testing HDFS connectivity:
docker exec bigdata-namenode hdfs dfs -ls / >nul 2>&1
if %errorlevel% eq 0 (
    echo    ✅ HDFS is accessible
) else (
    echo    ❌ HDFS is not accessible
)

REM Test Hive Metastore connectivity
echo 🗄️  Testing Hive Metastore connectivity:
docker exec bigdata-hive-metastore /opt/hive/bin/hive --help >nul 2>&1
if %errorlevel% eq 0 (
    echo    ✅ Hive Metastore is accessible
) else (
    echo    ❌ Hive Metastore is not accessible
)

echo.
echo 📊 Container status:
docker compose ps

echo.
echo ========================================================================
echo 🏁 Health Check Complete
echo ========================================================================
echo.
echo 💡 If any services show as unhealthy:
echo    1. Check the logs with 'monitor.bat'
echo    2. Try restarting with 'stop.bat' then 'start.bat'
echo    3. Check the troubleshooting guide in docs/troubleshooting.md
echo.
echo 🌐 Service URLs:
echo    📊 Jupyter Lab:       http://localhost:8888
echo    🗄️  Hadoop NameNode:   http://localhost:9870
echo    📈 YARN ResourceMgr:   http://localhost:8088
echo    ⚡ Spark Master:      http://localhost:8080
echo    🔍 HiveServer2 UI:    http://localhost:10002
echo.

pause