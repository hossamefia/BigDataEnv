@echo off
REM ========================================================================
REM Big Data Environment - Cleanup Script
REM ========================================================================
REM This script completely resets the Big Data environment
REM WARNING: This will delete all data and reset everything!
REM ========================================================================

title Big Data Environment - Cleanup
color 0C

echo.
echo ========================================================================
echo 🧹 Big Data Environment - Complete Cleanup
echo ========================================================================
echo.
echo ⚠️  WARNING: This will completely reset your Big Data environment!
echo ⚠️  All data, databases, and configurations will be lost!
echo.

set /p confirm="Are you sure you want to continue? (yes/no): "
if /i not "%confirm%"=="yes" (
    echo Operation cancelled.
    pause
    exit /b 0
)

echo.
echo 🔄 Starting cleanup process...
echo.

REM Stop all services
echo 📊 Stopping all services...
docker compose down

REM Remove all containers
echo 🗑️  Removing containers...
docker compose down --rmi all --volumes --remove-orphans

REM Remove all volumes (this deletes all data!)
echo 💾 Removing all data volumes...
docker volume rm bigdataenv_postgres_data 2>nul
docker volume rm bigdataenv_namenode_data 2>nul
docker volume rm bigdataenv_datanode_data 2>nul
docker volume rm bigdataenv_spark_logs 2>nul
docker volume rm bigdataenv_jupyter_home 2>nul

REM Remove any dangling volumes
echo 🧹 Cleaning up dangling volumes...
for /f "tokens=*" %%i in ('docker volume ls -qf dangling=true') do docker volume rm %%i 2>nul

REM Remove temporary directories
echo 📁 Cleaning up temporary files...
if exist "logs" rmdir /s /q logs
if exist "notebooks\.ipynb_checkpoints" rmdir /s /q "notebooks\.ipynb_checkpoints"

REM Prune Docker system (optional)
echo 🗑️  Pruning Docker system...
docker system prune -f --volumes

echo.
echo ========================================================================
echo ✅ Cleanup Complete!
echo ========================================================================
echo.
echo 🔄 Your Big Data environment has been completely reset.
echo.
echo Next steps:
echo 1. Run 'setup.bat' to reinitialize the environment
echo 2. Run 'start.bat' to start fresh services
echo.

pause