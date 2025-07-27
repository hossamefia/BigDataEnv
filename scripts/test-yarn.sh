#!/bin/bash

echo "🚀 Testing YARN ResourceManager Configuration..."
echo "=============================================="

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose is not installed or not in PATH"
    exit 1
fi

# Check if configuration files exist
echo "📋 Checking configuration files..."

config_files=(
    "configs/hadoop/capacity-scheduler.xml"
    "configs/hadoop/yarn-site.xml"
    "configs/hadoop/core-site.xml"
    "configs/hadoop/hdfs-site.xml"
    "configs/hadoop/mapred-site.xml"
)

for file in "${config_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file is missing"
        exit 1
    fi
done

echo ""
echo "🐳 Starting services..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to start..."
sleep 30

echo ""
echo "🔍 Checking service status..."
docker-compose ps

echo ""
echo "📊 Checking ResourceManager logs for queue configuration..."
docker-compose logs resourcemanager | grep -E "(queue|Queue|capacity|Capacity|scheduler|Scheduler)" | tail -10

echo ""
echo "🌐 ResourceManager Web UI should be available at: http://localhost:8088"
echo "📝 Check the logs above for any queue configuration errors"

# Test if ResourceManager web UI is responding
echo ""
echo "🧪 Testing ResourceManager web UI..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8088 | grep -q "200"; then
    echo "✅ ResourceManager web UI is responding"
else
    echo "⚠️  ResourceManager web UI is not responding yet (may need more time to start)"
fi