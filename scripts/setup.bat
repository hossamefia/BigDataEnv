@echo off
echo ==========================================
echo   Big Data Environment - Setup Script
echo ==========================================
echo.

echo [INFO] Welcome to Big Data Environment Setup!
echo [INFO] This script will prepare your environment for first use.
echo.

echo [INFO] Checking Docker installation...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not installed or not running!
    echo [ERROR] Please install Docker Desktop and ensure it's running.
    pause
    exit /b 1
)

echo [INFO] Checking Docker Compose installation...
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker Compose is not installed!
    echo [ERROR] Please install Docker Compose.
    pause
    exit /b 1
)

echo [INFO] Docker and Docker Compose are available!
echo.

echo [INFO] Creating data directories if they don't exist...
if not exist "data\samples" mkdir data\samples
if not exist "notebooks" mkdir notebooks

echo [INFO] Pulling required Docker images...
echo [INFO] This may take several minutes on first run...
docker-compose pull

echo.
echo [INFO] Environment setup complete!
echo.
echo Next steps:
echo   1. Run 'start.bat' to start all services
echo   2. Run 'validate.bat' to check everything is working
echo   3. Open http://localhost:8888 for Jupyter (token: bigdata123)
echo.
pause