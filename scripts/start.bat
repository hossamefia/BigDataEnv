@echo off
REM ========================================================================
REM Big Data Environment - Start Script
REM ========================================================================
REM This script starts all Big Data services in the correct order
REM ========================================================================

title Big Data Environment - Starting Services
color 0B

echo.
echo ========================================================================
echo 🚀 Big Data Environment - Starting Services
echo ========================================================================
echo.

REM Check if Docker is running
echo 📋 Checking Docker status...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not running
    echo Please start Docker Desktop and try again
    pause
    exit /b 1
)

echo ✅ Docker is running

REM Stop any existing containers
echo.
echo 🛑 Stopping any existing containers...
docker compose down >nul 2>&1

REM Start services in correct order with proper dependencies
echo.
echo 🔄 Starting Big Data services...
echo This may take 2-3 minutes for all services to be ready...
echo.

echo 📊 Starting PostgreSQL (Hive Metastore)...
docker compose up -d postgres
timeout /t 10 /nobreak >nul

echo 📊 Starting Hadoop NameNode...
docker compose up -d namenode
timeout /t 15 /nobreak >nul

echo 📊 Starting Hadoop DataNode...
docker compose up -d datanode
timeout /t 10 /nobreak >nul

echo 📊 Starting YARN ResourceManager...
docker compose up -d resourcemanager
timeout /t 10 /nobreak >nul

echo 📊 Starting YARN NodeManager...
docker compose up -d nodemanager
timeout /t 10 /nobreak >nul

echo 📊 Starting Hive Metastore...
docker compose up -d hive-metastore
timeout /t 15 /nobreak >nul

echo 📊 Starting HiveServer2...
docker compose up -d hiveserver2
timeout /t 10 /nobreak >nul

echo 📊 Starting Spark Master...
docker compose up -d spark-master
timeout /t 10 /nobreak >nul

echo 📊 Starting Spark Worker...
docker compose up -d spark-worker
timeout /t 10 /nobreak >nul

echo 📊 Starting Jupyter Lab...
docker compose up -d jupyter
timeout /t 15 /nobreak >nul

echo.
echo ⏳ Waiting for all services to be fully ready...
timeout /t 30 /nobreak >nul

REM Initialize HDFS directories if needed
echo.
echo 📁 Initializing HDFS directories...
docker exec bigdata-namenode hdfs dfs -mkdir -p /user/hive/warehouse >nul 2>&1
docker exec bigdata-namenode hdfs dfs -mkdir -p /spark-history >nul 2>&1
docker exec bigdata-namenode hdfs dfs -mkdir -p /app-logs >nul 2>&1
docker exec bigdata-namenode hdfs dfs -mkdir -p /tmp >nul 2>&1
docker exec bigdata-namenode hdfs dfs -chmod 777 /tmp >nul 2>&1

echo.
echo ========================================================================
echo ✅ Big Data Environment Started Successfully!
echo ========================================================================
echo.
echo 🌐 Access your services:
echo.
echo   📊 Jupyter Lab:       http://localhost:8888  (token: bigdata123)
echo   🗄️  Hadoop NameNode:   http://localhost:9870
echo   📈 YARN ResourceMgr:   http://localhost:8088
echo   ⚡ Spark Master:      http://localhost:8080
echo   🔍 HiveServer2 UI:    http://localhost:10002
echo.
echo 💡 Tips:
echo   - Run 'validate.bat' to check service health
echo   - Run 'monitor.bat' to see service logs
echo   - Run 'stop.bat' to gracefully stop all services
echo.
echo 📚 Sample notebooks are available in the 'notebooks' folder
echo 📁 Sample data is available in the 'data/samples' folder
echo.

pause