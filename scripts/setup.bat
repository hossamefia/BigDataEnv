@echo off
REM ========================================================================
REM Big Data Environment - Initial Setup Script
REM ========================================================================
REM This script performs initial setup for the Big Data testing environment
REM ========================================================================

title Big Data Environment - Setup
color 0A

echo.
echo ========================================================================
echo 🚀 Big Data Environment - Initial Setup
echo ========================================================================
echo.

REM Check if Docker is installed and running
echo 📋 Checking Docker installation...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not installed or not in PATH
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

echo ✅ Docker is installed

REM Check if Docker is running
echo 📋 Checking if Docker is running...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not running
    echo Please start Docker Desktop and try again
    pause
    exit /b 1
)

echo ✅ Docker is running

REM Check if Docker Compose is available
echo 📋 Checking Docker Compose...
docker compose version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Compose is not available
    echo Please ensure Docker Compose is installed
    pause
    exit /b 1
)

echo ✅ Docker Compose is available

REM Create necessary directories
echo.
echo 📁 Creating project directories...
if not exist "data\samples" mkdir data\samples
if not exist "notebooks" mkdir notebooks
if not exist "logs" mkdir logs
echo ✅ Directories created

REM Pull required Docker images
echo.
echo 📥 Pulling Docker images (this may take several minutes)...
echo This is a one-time setup process...

docker pull postgres:13
docker pull apache/hadoop:3.3.4
docker pull apache/hive:3.1.3
docker pull apache/spark:3.4.1-scala2.12-java11-python3-ubuntu
docker pull jupyter/pyspark-notebook:spark-3.4.1

if %errorlevel% neq 0 (
    echo ❌ Failed to pull some Docker images
    echo Please check your internet connection and try again
    pause
    exit /b 1
)

echo ✅ All Docker images pulled successfully

REM Initialize HDFS directories (this will be done after first startup)
echo.
echo 📋 Setup completed successfully!
echo.
echo Next steps:
echo 1. Run 'start.bat' to start the Big Data environment
echo 2. Run 'validate.bat' to verify all services are running
echo 3. Access Jupyter Lab at http://localhost:8888 (token: bigdata123)
echo.
echo 🌐 Service URLs:
echo - Jupyter Lab:       http://localhost:8888
echo - Hadoop NameNode:   http://localhost:9870
echo - YARN ResourceMgr:  http://localhost:8088
echo - Spark Master:      http://localhost:8080
echo - HiveServer2 UI:    http://localhost:10002
echo.

pause