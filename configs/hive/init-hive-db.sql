-- Initialize Hive database schema
CREATE DATABASE IF NOT EXISTS metastore;
GRANT ALL PRIVILEGES ON DATABASE metastore TO hive;