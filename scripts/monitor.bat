@echo off
REM ========================================================================
REM Big Data Environment - Monitor Script
REM ========================================================================
REM This script helps monitor service logs and status
REM ========================================================================

title Big Data Environment - Monitor
color 0F

:menu
cls
echo.
echo ========================================================================
echo 📊 Big Data Environment - Service Monitor
echo ========================================================================
echo.
echo Select an option:
echo.
echo 1. View all service status
echo 2. View logs for a specific service
echo 3. View live logs (tail -f style)
echo 4. View resource usage
echo 5. Test connectivity
echo 6. Exit
echo.

set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" goto status
if "%choice%"=="2" goto logs
if "%choice%"=="3" goto live_logs
if "%choice%"=="4" goto resources
if "%choice%"=="5" goto connectivity
if "%choice%"=="6" goto exit
goto menu

:status
cls
echo ========================================================================
echo 📊 Service Status Overview
echo ========================================================================
echo.
docker compose ps
echo.
echo Press any key to return to menu...
pause >nul
goto menu

:logs
cls
echo ========================================================================
echo 📋 Service Logs
echo ========================================================================
echo.
echo Available services:
echo 1. postgres
echo 2. namenode
echo 3. datanode
echo 4. resourcemanager
echo 5. nodemanager
echo 6. hive-metastore
echo 7. hiveserver2
echo 8. spark-master
echo 9. spark-worker
echo 10. jupyter
echo.

set /p service_choice="Enter service number (1-10): "

if "%service_choice%"=="1" set service_name=postgres
if "%service_choice%"=="2" set service_name=namenode
if "%service_choice%"=="3" set service_name=datanode
if "%service_choice%"=="4" set service_name=resourcemanager
if "%service_choice%"=="5" set service_name=nodemanager
if "%service_choice%"=="6" set service_name=hive-metastore
if "%service_choice%"=="7" set service_name=hiveserver2
if "%service_choice%"=="8" set service_name=spark-master
if "%service_choice%"=="9" set service_name=spark-worker
if "%service_choice%"=="10" set service_name=jupyter

echo.
echo Showing logs for %service_name%...
echo ========================================================================
docker compose logs %service_name%
echo.
echo Press any key to return to menu...
pause >nul
goto menu

:live_logs
cls
echo ========================================================================
echo 📊 Live Logs (Press Ctrl+C to stop)
echo ========================================================================
echo.
echo Available services:
echo 1. postgres
echo 2. namenode
echo 3. datanode
echo 4. resourcemanager
echo 5. nodemanager
echo 6. hive-metastore
echo 7. hiveserver2
echo 8. spark-master
echo 9. spark-worker
echo 10. jupyter
echo 11. All services
echo.

set /p service_choice="Enter service number (1-11): "

if "%service_choice%"=="1" set service_name=postgres
if "%service_choice%"=="2" set service_name=namenode
if "%service_choice%"=="3" set service_name=datanode
if "%service_choice%"=="4" set service_name=resourcemanager
if "%service_choice%"=="5" set service_name=nodemanager
if "%service_choice%"=="6" set service_name=hive-metastore
if "%service_choice%"=="7" set service_name=hiveserver2
if "%service_choice%"=="8" set service_name=spark-master
if "%service_choice%"=="9" set service_name=spark-worker
if "%service_choice%"=="10" set service_name=jupyter
if "%service_choice%"=="11" set service_name=

echo.
if "%service_name%"=="" (
    echo Following logs for all services...
    docker compose logs -f
) else (
    echo Following logs for %service_name%...
    docker compose logs -f %service_name%
)
goto menu

:resources
cls
echo ========================================================================
echo 💻 Resource Usage
echo ========================================================================
echo.
echo Container resource usage:
docker stats --no-stream
echo.
echo Disk usage by volumes:
docker system df
echo.
echo Press any key to return to menu...
pause >nul
goto menu

:connectivity
cls
echo ========================================================================
echo 🔗 Connectivity Test
echo ========================================================================
echo.

echo Testing service endpoints...
echo.

echo PostgreSQL (5432):
netstat -an | findstr :5432 >nul && echo ✅ Port 5432 is open || echo ❌ Port 5432 is not accessible

echo NameNode (9870):
netstat -an | findstr :9870 >nul && echo ✅ Port 9870 is open || echo ❌ Port 9870 is not accessible

echo ResourceManager (8088):
netstat -an | findstr :8088 >nul && echo ✅ Port 8088 is open || echo ❌ Port 8088 is not accessible

echo Spark Master (8080):
netstat -an | findstr :8080 >nul && echo ✅ Port 8080 is open || echo ❌ Port 8080 is not accessible

echo HiveServer2 (10000):
netstat -an | findstr :10000 >nul && echo ✅ Port 10000 is open || echo ❌ Port 10000 is not accessible

echo Jupyter Lab (8888):
netstat -an | findstr :8888 >nul && echo ✅ Port 8888 is open || echo ❌ Port 8888 is not accessible

echo.
echo Network connectivity test:
ping -n 1 127.0.0.1 >nul && echo ✅ Localhost connectivity OK || echo ❌ Localhost connectivity failed

echo.
echo Press any key to return to menu...
pause >nul
goto menu

:exit
echo.
echo Goodbye!
exit /b 0