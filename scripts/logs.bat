@echo off
echo ==========================================
echo   Big Data Environment - Logs Viewer
echo ==========================================
echo.

if "%1"=="" (
    echo Usage: logs.bat [service_name]
    echo.
    echo Available services:
    echo   - postgres
    echo   - namenode
    echo   - datanode
    echo   - resourcemanager
    echo   - nodemanager
    echo   - hive-metastore
    echo   - hiveserver2
    echo   - spark-master
    echo   - spark-worker
    echo   - jupyter
    echo   - all ^(show all logs^)
    echo.
    echo Example: logs.bat namenode
    echo Example: logs.bat all
    echo.
    pause
    exit /b
)

if "%1"=="all" (
    echo [INFO] Showing logs for all services...
    docker-compose logs --tail=50 -f
) else (
    echo [INFO] Showing logs for service: %1
    docker-compose logs --tail=50 -f %1
)

pause