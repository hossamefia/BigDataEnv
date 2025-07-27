@echo off
echo ==========================================
echo   Big Data Environment - Cleanup Script
echo ==========================================
echo.

echo [WARNING] This will stop all services and remove all data!
echo [WARNING] This action cannot be undone!
echo.
set /p confirm="Are you sure you want to cleanup everything? (y/N): "

if /i not "%confirm%"=="y" (
    echo [INFO] Cleanup cancelled.
    pause
    exit /b
)

echo.
echo [INFO] Stopping all services...
docker-compose down

echo [INFO] Removing all volumes (this will delete all data)...
docker-compose down -v

echo [INFO] Removing all images used by this environment...
docker-compose down --rmi all

echo [INFO] Cleaning up Docker system...
docker system prune -f

echo.
echo [INFO] Environment cleanup complete!
echo [INFO] Run 'setup.bat' to reinitialize the environment
echo.
pause