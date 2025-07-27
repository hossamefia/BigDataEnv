@echo off
REM ========================================================================
REM Big Data Environment - Stop Script
REM ========================================================================
REM This script gracefully stops all Big Data services
REM ========================================================================

title Big Data Environment - Stopping Services
color 0C

echo.
echo ========================================================================
echo 🛑 Big Data Environment - Stopping Services
echo ========================================================================
echo.

REM Check if Docker is running
echo 📋 Checking Docker status...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not running
    echo Services may already be stopped
    pause
    exit /b 0
)

echo ✅ Docker is running

REM Stop services gracefully in reverse order
echo.
echo 🔄 Stopping Big Data services gracefully...
echo.

echo 📊 Stopping Jupyter Lab...
docker compose stop jupyter

echo 📊 Stopping Spark Worker...
docker compose stop spark-worker

echo 📊 Stopping Spark Master...
docker compose stop spark-master

echo 📊 Stopping HiveServer2...
docker compose stop hiveserver2

echo 📊 Stopping Hive Metastore...
docker compose stop hive-metastore

echo 📊 Stopping YARN NodeManager...
docker compose stop nodemanager

echo 📊 Stopping YARN ResourceManager...
docker compose stop resourcemanager

echo 📊 Stopping Hadoop DataNode...
docker compose stop datanode

echo 📊 Stopping Hadoop NameNode...
docker compose stop namenode

echo 📊 Stopping PostgreSQL...
docker compose stop postgres

echo.
echo 🧹 Removing stopped containers...
docker compose down

echo.
echo ========================================================================
echo ✅ Big Data Environment Stopped Successfully!
echo ========================================================================
echo.
echo 💡 Data is preserved in Docker volumes
echo 💡 Run 'start.bat' to restart the environment
echo 💡 Run 'cleanup.bat' if you want to reset everything
echo.

pause