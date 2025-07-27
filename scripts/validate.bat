@echo off
echo ==========================================
echo   Big Data Environment - Health Validation
echo ==========================================
echo.

echo [INFO] Checking service health and connectivity...
echo.

echo [INFO] Container Status:
docker-compose ps
echo.

echo [INFO] Testing web interfaces...
echo.

echo [1/6] Testing Hadoop NameNode (http://localhost:9870)...
curl -s -o nul -w "Status: %%{http_code}\n" http://localhost:9870/ || echo Failed to connect

echo [2/6] Testing YARN ResourceManager (http://localhost:8088)...
curl -s -o nul -w "Status: %%{http_code}\n" http://localhost:8088/ || echo Failed to connect

echo [3/6] Testing Spark Master (http://localhost:8080)...
curl -s -o nul -w "Status: %%{http_code}\n" http://localhost:8080/ || echo Failed to connect

echo [4/6] Testing Jupyter Lab (http://localhost:8888)...
curl -s -o nul -w "Status: %%{http_code}\n" http://localhost:8888/ || echo Failed to connect

echo [5/6] Testing HiveServer2 Web UI (http://localhost:10002)...
curl -s -o nul -w "Status: %%{http_code}\n" http://localhost:10002/ || echo Failed to connect

echo [6/6] Testing PostgreSQL connection...
docker-compose exec -T postgres psql -U hive -d metastore -c "\l" > nul 2>&1 && echo PostgreSQL: Connected || echo PostgreSQL: Failed

echo.
echo [INFO] HDFS Operations Test:
echo [INFO] Creating test directory in HDFS...
docker-compose exec -T namenode hdfs dfs -mkdir -p /test 2>nul && echo HDFS: Test directory created || echo HDFS: Failed to create directory

echo [INFO] Listing HDFS root directory:
docker-compose exec -T namenode hdfs dfs -ls / 2>nul || echo HDFS: Failed to list directory

echo.
echo ==========================================
echo   Validation Summary
echo ==========================================
echo.
echo If all tests show success/200 status, your environment is ready!
echo.
echo Next steps:
echo   1. Open Jupyter Lab: http://localhost:8888 (token: bigdata123)
echo   2. Try the sample notebooks in the 'work' directory
echo   3. Access Hadoop NameNode UI: http://localhost:9870
echo   4. Access Spark Master UI: http://localhost:8080
echo.
pause