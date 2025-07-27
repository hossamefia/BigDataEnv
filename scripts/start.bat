@echo off
echo ==========================================
echo   Big Data Environment - Startup Script
echo ==========================================
echo.

echo [INFO] Starting Big Data Environment...
echo [INFO] This will start all services in the following order:
echo   1. PostgreSQL Database
echo   2. Hadoop Services (NameNode, DataNode, ResourceManager, NodeManager)
echo   3. Hive Services (Metastore, HiveServer2)
echo   4. Spark Services (Master, Worker)
echo   5. Jupyter Lab
echo.

echo [INFO] Pulling latest images (if needed)...
docker-compose pull

echo.
echo [INFO] Starting services with health checks...
docker-compose up -d

echo.
echo [INFO] Waiting for services to be ready...
timeout /t 10 /nobreak > nul

echo.
echo [INFO] Checking service status...
docker-compose ps

echo.
echo ==========================================
echo   Big Data Environment Status
echo ==========================================
echo.
echo Web Interfaces:
echo   - Hadoop NameNode UI:    http://localhost:9870
echo   - YARN ResourceManager:  http://localhost:8088
echo   - Spark Master UI:       http://localhost:8080
echo   - Jupyter Lab:           http://localhost:8888 (token: bigdata123)
echo   - HiveServer2 Web UI:    http://localhost:10002
echo.
echo Database Connections:
echo   - PostgreSQL:            localhost:5432 (user: hive, pass: hive123)
echo   - HiveServer2:           localhost:10000
echo.
echo [INFO] Environment startup complete!
echo [INFO] Run 'validate.bat' to check all services are working properly
echo [INFO] Run 'logs.bat' to view service logs
echo.
pause