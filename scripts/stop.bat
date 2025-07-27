@echo off
echo ==========================================
echo   Big Data Environment - Shutdown Script
echo ==========================================
echo.

echo [INFO] Stopping Big Data Environment...
echo [INFO] This will gracefully shutdown all services
echo.

echo [INFO] Stopping all containers...
docker-compose down

echo.
echo [INFO] Checking if all containers are stopped...
docker-compose ps

echo.
echo [INFO] Environment shutdown complete!
echo [INFO] Data is preserved in Docker volumes
echo [INFO] Run 'start.bat' to restart the environment
echo.
pause