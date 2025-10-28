-- Database initialization script for GivingBridge
-- Creates database with proper character set and collation

-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS givingbridge
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- Use the database
USE givingbridge;

-- Create application user with limited privileges
CREATE USER IF NOT EXISTS 'givingbridge_app'@'%' IDENTIFIED BY 'secure_app_password_change_me';

-- Grant necessary privileges to application user
GRANT SELECT, INSERT, UPDATE, DELETE ON givingbridge.* TO 'givingbridge_app'@'%';
GRANT CREATE TEMPORARY TABLES ON givingbridge.* TO 'givingbridge_app'@'%';
GRANT LOCK TABLES ON givingbridge.* TO 'givingbridge_app'@'%';

-- Create read-only user for reporting/analytics
CREATE USER IF NOT EXISTS 'givingbridge_readonly'@'%' IDENTIFIED BY 'readonly_password_change_me';
GRANT SELECT ON givingbridge.* TO 'givingbridge_readonly'@'%';

-- Create backup user
CREATE USER IF NOT EXISTS 'givingbridge_backup'@'localhost' IDENTIFIED BY 'backup_password_change_me';
GRANT SELECT, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER ON givingbridge.* TO 'givingbridge_backup'@'localhost';
GRANT RELOAD, PROCESS ON *.* TO 'givingbridge_backup'@'localhost';

-- Flush privileges
FLUSH PRIVILEGES;

-- Set global variables for better performance
SET GLOBAL innodb_buffer_pool_size = 2147483648; -- 2GB
SET GLOBAL innodb_log_file_size = 536870912;     -- 512MB
SET GLOBAL max_connections = 200;
SET GLOBAL query_cache_size = 0;                 -- Disable query cache (MySQL 8.0+)
SET GLOBAL slow_query_log = 1;
SET GLOBAL long_query_time = 2;

-- Create performance monitoring views
CREATE OR REPLACE VIEW v_slow_queries AS
SELECT 
    query_time,
    lock_time,
    rows_sent,
    rows_examined,
    sql_text
FROM mysql.slow_log
WHERE start_time >= DATE_SUB(NOW(), INTERVAL 1 DAY)
ORDER BY query_time DESC
LIMIT 100;

-- Create connection monitoring view
CREATE OR REPLACE VIEW v_connection_stats AS
SELECT 
    PROCESSLIST_USER as user,
    PROCESSLIST_HOST as host,
    PROCESSLIST_DB as database_name,
    PROCESSLIST_COMMAND as command,
    PROCESSLIST_TIME as time_seconds,
    PROCESSLIST_STATE as state,
    PROCESSLIST_INFO as query_info
FROM performance_schema.processlist
WHERE PROCESSLIST_USER NOT IN ('root', 'mysql.sys', 'mysql.session')
ORDER BY PROCESSLIST_TIME DESC;

-- Create table size monitoring view
CREATE OR REPLACE VIEW v_table_sizes AS
SELECT 
    table_schema as database_name,
    table_name,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) as size_mb,
    table_rows,
    ROUND((data_length / 1024 / 1024), 2) as data_mb,
    ROUND((index_length / 1024 / 1024), 2) as index_mb
FROM information_schema.tables
WHERE table_schema = 'givingbridge'
ORDER BY (data_length + index_length) DESC;

-- Create index usage monitoring view
CREATE OR REPLACE VIEW v_index_usage AS
SELECT 
    object_schema as database_name,
    object_name as table_name,
    index_name,
    count_read,
    count_write,
    count_fetch,
    count_insert,
    count_update,
    count_delete
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE object_schema = 'givingbridge'
ORDER BY count_read DESC;

-- Log initialization completion
INSERT INTO mysql.general_log (event_time, user_host, thread_id, server_id, command_type, argument)
VALUES (NOW(), 'init_script', 0, 1, 'Query', 'GivingBridge database initialization completed');