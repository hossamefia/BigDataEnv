-- Initialize Hive Metastore Database
-- This script is executed automatically when PostgreSQL container starts

\echo 'Creating Hive metastore database and user...'

-- Create database if it doesn't exist
CREATE DATABASE metastore;

-- Grant all privileges to hive user
GRANT ALL PRIVILEGES ON DATABASE metastore TO hive;

\echo 'Hive metastore database initialized successfully!'