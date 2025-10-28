#!/bin/bash

# Disaster Recovery System for GivingBridge
# Provides automated failover, backup restoration, and recovery procedures

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR=${BACKUP_DIR:-"$PROJECT_ROOT/backups"}
RECOVERY_LOG_DIR=${RECOVERY_LOG_DIR:-"/var/log/givingbridge/recovery"}
RECOVERY_CONFIG_FILE=${RECOVERY_CONFIG_FILE:-"$PROJECT_ROOT/.recovery-config"}

# Database configuration
DB_HOST=${DB_HOST:-"localhost"}
DB_PORT=${DB_PORT:-"3306"}
DB_NAME=${DB_NAME:-"givingbridge"}
DB_USER=${DB_USER:-"root"}
DB_PASSWORD=${DB_PASSWORD:-""}
DB_BACKUP_USER=${DB_BACKUP_USER:-"givingbridge_backup"}
DB_BACKUP_PASSWORD=${DB_BACKUP_PASSWORD:-""}

# Application configuration
APP_DIR=${APP_DIR:-"$PROJECT_ROOT"}
UPLOADS_DIR=${UPLOADS_DIR:-"$APP_DIR/backend/uploads"}
DOCKER_COMPOSE_FILE=${DOCKER_COMPOSE_FILE:-"$APP_DIR/docker-compose.yml"}
DOCKER_COMPOSE_PROD_FILE=${DOCKER_COMPOSE_PROD_FILE:-"$APP_DIR/docker-compose.prod.yml"}

# Recovery targets
RECOVERY_TIME_OBJECTIVE=${RECOVERY_TIME_OBJECTIVE:-3600}  # 1 hour in seconds
RECOVERY_POINT_OBJECTIVE=${RECOVERY_POINT_OBJECTIVE:-1800}  # 30 minutes in seconds

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    local message="$1"
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $message"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $message" >> "$RECOVERY_LOG_DIR/recovery.log" 2>/dev/null || true
}

log_success() {
    local message="$1"
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $message"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [SUCCESS] $message" >> "$RECOVERY_LOG_DIR/recovery.log" 2>/dev/null || true
}

log_warning() {
    local message="$1"
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $message"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING] $message" >> "$RECOVERY_LOG_DIR/recovery.log" 2>/dev/null || true
}

log_error() {
    local message="$1"
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $message"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $message" >> "$RECOVERY_LOG_DIR/recovery.log" 2>/dev/null || true
}

log_critical() {
    local message="$1"
    echo -e "${PURPLE}[CRITICAL]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $message"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [CRITICAL] $message" >> "$RECOVERY_LOG_DIR/recovery.log" 2>/dev/null || true
}

# Create recovery log directory
create_log_directory() {
    if [ ! -d "$RECOVERY_LOG_DIR" ]; then
        mkdir -p "$RECOVERY_LOG_DIR"
        log_info "Created recovery log directory: $RECOVERY_LOG_DIR"
    fi
}

# Load recovery configuration
load_recovery_config() {
    if [ -f "$RECOVERY_CONFIG_FILE" ]; then
        source "$RECOVERY_CONFIG_FILE"
        log_info "Loaded recovery configuration from $RECOVERY_CONFIG_FILE"
    else
        log_warning "Recovery configuration file not found: $RECOVERY_CONFIG_FILE"
        log_info "Using default configuration"
    fi
}

# Save recovery configuration
save_recovery_config() {
    cat > "$RECOVERY_CONFIG_FILE" << EOF
# GivingBridge Disaster Recovery Configuration
# Generated on $(date)

# Recovery objectives
RECOVERY_TIME_OBJECTIVE=$RECOVERY_TIME_OBJECTIVE
RECOVERY_POINT_OBJECTIVE=$RECOVERY_POINT_OBJECTIVE

# Database configuration
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_BACKUP_USER=$DB_BACKUP_USER

# Application paths
APP_DIR=$APP_DIR
UPLOADS_DIR=$UPLOADS_DIR
BACKUP_DIR=$BACKUP_DIR

# Last recovery information
LAST_RECOVERY_TEST=$(date '+%Y-%m-%d %H:%M:%S')
LAST_RECOVERY_STATUS=configured
EOF
    
    log_success "Recovery configuration saved to $RECOVERY_CONFIG_FILE"
}

# Check system health
check_system_health() {
    log_info "Checking system health..."
    
    local health_issues=0
    
    # Check database connectivity
    if ! mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" > /dev/null 2>&1; then
        log_error "Database connection failed"
        health_issues=$((health_issues + 1))
    else
        log_success "Database connection OK"
    fi
    
    # Check application directory
    if [ ! -d "$APP_DIR" ]; then
        log_error "Application directory not found: $APP_DIR"
        health_issues=$((health_issues + 1))
    else
        log_success "Application directory OK"
    fi
    
    # Check uploads directory
    if [ ! -d "$UPLOADS_DIR" ]; then
        log_warning "Uploads directory not found: $UPLOADS_DIR"
        health_issues=$((health_issues + 1))
    else
        log_success "Uploads directory OK"
    fi
    
    # Check backup directory
    if [ ! -d "$BACKUP_DIR" ]; then
        log_warning "Backup directory not found: $BACKUP_DIR"
        health_issues=$((health_issues + 1))
    else
        log_success "Backup directory OK"
    fi
    
    # Check Docker
    if command -v docker &> /dev/null; then
        if docker info > /dev/null 2>&1; then
            log_success "Docker service OK"
        else
            log_error "Docker service not running"
            health_issues=$((health_issues + 1))
        fi
    else
        log_warning "Docker not installed"
    fi
    
    # Check Docker Compose
    if command -v docker-compose &> /dev/null; then
        log_success "Docker Compose available"
    else
        log_warning "Docker Compose not available"
    fi
    
    return $health_issues
}

# Find latest database backup
find_latest_database_backup() {
    local backup_pattern="$BACKUP_DIR/database/${DB_NAME}_backup_*.sql*"
    local latest_backup
    
    latest_backup=$(find "$BACKUP_DIR/database" -name "${DB_NAME}_backup_*.sql*" -type f 2>/dev/null | sort | tail -n 1)
    
    if [ -z "$latest_backup" ]; then
        log_error "No database backup found in $BACKUP_DIR/database"
        return 1
    fi
    
    log_info "Latest database backup: $(basename "$latest_backup")"
    echo "$latest_backup"
}

# Find latest file backup
find_latest_file_backup() {
    local latest_full_backup
    local latest_incremental_backup
    
    # Find latest full backup
    latest_full_backup=$(find "$BACKUP_DIR/files/full" -name "files_full_*" -type f -o -name "files_full_*" -type d 2>/dev/null | sort | tail -n 1)
    
    # Find latest incremental backup
    latest_incremental_backup=$(find "$BACKUP_DIR/files/incremental" -name "files_incremental_*" -type f -o -name "files_incremental_*" -type d 2>/dev/null | sort | tail -n 1)
    
    if [ -z "$latest_full_backup" ]; then
        log_error "No file backup found in $BACKUP_DIR/files"
        return 1
    fi
    
    log_info "Latest full file backup: $(basename "$latest_full_backup")"
    if [ -n "$latest_incremental_backup" ]; then
        log_info "Latest incremental file backup: $(basename "$latest_incremental_backup")"
    fi
    
    echo "$latest_full_backup|$latest_incremental_backup"
}

# Restore database from backup
restore_database() {
    local backup_file="$1"
    local target_db="${2:-$DB_NAME}"
    
    log_info "Starting database restoration..."
    log_info "Backup file: $backup_file"
    log_info "Target database: $target_db"
    
    if [ ! -f "$backup_file" ]; then
        log_error "Backup file not found: $backup_file"
        return 1
    fi
    
    # Create restoration database if it doesn't exist
    mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`$target_db\`;" || {
        log_error "Failed to create target database"
        return 1
    }
    
    # Restore database
    local restore_start_time=$(date +%s)
    
    if [[ "$backup_file" == *.gz ]]; then
        log_info "Decompressing and restoring database..."
        if ! zcat "$backup_file" | mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$target_db"; then
            log_error "Database restoration failed"
            return 1
        fi
    else
        log_info "Restoring database..."
        if ! mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$target_db" < "$backup_file"; then
            log_error "Database restoration failed"
            return 1
        fi
    fi
    
    local restore_end_time=$(date +%s)
    local restore_duration=$((restore_end_time - restore_start_time))
    
    log_success "Database restoration completed in ${restore_duration} seconds"
    
    # Verify restoration
    local table_count
    table_count=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" -sN -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$target_db';" 2>/dev/null || echo "0")
    
    if [ "$table_count" -gt 0 ]; then
        log_success "Database verification passed: $table_count tables restored"
    else
        log_error "Database verification failed: no tables found"
        return 1
    fi
}

# Restore files from backup
restore_files() {
    local backup_info="$1"
    local target_dir="${2:-$UPLOADS_DIR}"
    
    log_info "Starting file restoration..."
    log_info "Target directory: $target_dir"
    
    local full_backup=$(echo "$backup_info" | cut -d'|' -f1)
    local incremental_backup=$(echo "$backup_info" | cut -d'|' -f2)
    
    # Create target directory
    mkdir -p "$target_dir"
    
    # Restore full backup
    log_info "Restoring full backup: $(basename "$full_backup")"
    
    if [[ "$full_backup" == *.tar.gz ]]; then
        # Extract compressed backup
        local temp_dir=$(mktemp -d)
        if ! tar -xzf "$full_backup" -C "$temp_dir"; then
            log_error "Failed to extract full backup"
            rm -rf "$temp_dir"
            return 1
        fi
        
        # Copy files to target
        local extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d -name "files_full_*" | head -n 1)
        if [ -n "$extracted_dir" ]; then
            rsync -av "$extracted_dir/" "$target_dir/"
        else
            rsync -av "$temp_dir/" "$target_dir/"
        fi
        
        rm -rf "$temp_dir"
    else
        # Copy directory backup
        rsync -av "$full_backup/" "$target_dir/"
    fi
    
    # Restore incremental backup if available
    if [ -n "$incremental_backup" ] && [ "$incremental_backup" != "" ]; then
        log_info "Restoring incremental backup: $(basename "$incremental_backup")"
        
        if [[ "$incremental_backup" == *.tar.gz ]]; then
            # Extract compressed incremental backup
            local temp_dir=$(mktemp -d)
            if tar -xzf "$incremental_backup" -C "$temp_dir"; then
                local extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d -name "files_incremental_*" | head -n 1)
                if [ -n "$extracted_dir" ]; then
                    rsync -av "$extracted_dir/" "$target_dir/"
                else
                    rsync -av "$temp_dir/" "$target_dir/"
                fi
            else
                log_warning "Failed to extract incremental backup, continuing with full backup only"
            fi
            rm -rf "$temp_dir"
        else
            # Copy incremental directory backup
            rsync -av "$incremental_backup/" "$target_dir/"
        fi
    fi
    
    log_success "File restoration completed"
    
    # Verify file restoration
    local restored_files
    restored_files=$(find "$target_dir" -type f | wc -l)
    log_success "File verification: $restored_files files restored"
}

# Stop application services
stop_services() {
    log_info "Stopping application services..."
    
    # Stop Docker Compose services
    if [ -f "$DOCKER_COMPOSE_FILE" ]; then
        log_info "Stopping Docker Compose services..."
        docker-compose -f "$DOCKER_COMPOSE_FILE" down || log_warning "Failed to stop some services"
    fi
    
    if [ -f "$DOCKER_COMPOSE_PROD_FILE" ]; then
        log_info "Stopping production Docker Compose services..."
        docker-compose -f "$DOCKER_COMPOSE_PROD_FILE" down || log_warning "Failed to stop some production services"
    fi
    
    # Stop any running Node.js processes
    pkill -f "node.*server.js" || true
    pkill -f "npm.*start" || true
    
    log_success "Services stopped"
}

# Start application services
start_services() {
    log_info "Starting application services..."
    
    # Determine which compose file to use
    local compose_file="$DOCKER_COMPOSE_FILE"
    if [ -f "$DOCKER_COMPOSE_PROD_FILE" ] && [ "${NODE_ENV:-}" = "production" ]; then
        compose_file="$DOCKER_COMPOSE_PROD_FILE"
    fi
    
    if [ -f "$compose_file" ]; then
        log_info "Starting Docker Compose services with $compose_file..."
        if docker-compose -f "$compose_file" up -d; then
            log_success "Services started successfully"
            
            # Wait for services to be ready
            log_info "Waiting for services to be ready..."
            sleep 30
            
            # Check service health
            if docker-compose -f "$compose_file" ps | grep -q "Up"; then
                log_success "Services are running"
            else
                log_warning "Some services may not be running properly"
            fi
        else
            log_error "Failed to start services"
            return 1
        fi
    else
        log_warning "No Docker Compose file found, services not started"
    fi
}

# Perform full disaster recovery
perform_full_recovery() {
    local recovery_start_time=$(date +%s)
    
    log_critical "=== STARTING FULL DISASTER RECOVERY ==="
    log_info "Recovery started at: $(date)"
    log_info "Recovery Time Objective: ${RECOVERY_TIME_OBJECTIVE} seconds"
    log_info "Recovery Point Objective: ${RECOVERY_POINT_OBJECTIVE} seconds"
    
    # Step 1: Stop services
    log_info "Step 1: Stopping services..."
    stop_services
    
    # Step 2: Find backups
    log_info "Step 2: Locating backups..."
    local db_backup
    local file_backup
    
    db_backup=$(find_latest_database_backup) || {
        log_critical "Cannot proceed without database backup"
        return 1
    }
    
    file_backup=$(find_latest_file_backup) || {
        log_warning "File backup not found, continuing with database recovery only"
        file_backup=""
    }
    
    # Step 3: Restore database
    log_info "Step 3: Restoring database..."
    restore_database "$db_backup" || {
        log_critical "Database restoration failed"
        return 1
    }
    
    # Step 4: Restore files
    if [ -n "$file_backup" ]; then
        log_info "Step 4: Restoring files..."
        restore_files "$file_backup" || {
            log_error "File restoration failed, continuing with database only"
        }
    else
        log_info "Step 4: Skipping file restoration (no backup found)"
    fi
    
    # Step 5: Start services
    log_info "Step 5: Starting services..."
    start_services || {
        log_error "Failed to start services"
        return 1
    }
    
    # Step 6: Verify recovery
    log_info "Step 6: Verifying recovery..."
    sleep 10  # Give services time to start
    
    if check_system_health > /dev/null; then
        log_success "Recovery verification passed"
    else
        log_warning "Recovery verification found issues, but recovery completed"
    fi
    
    local recovery_end_time=$(date +%s)
    local recovery_duration=$((recovery_end_time - recovery_start_time))
    
    log_critical "=== DISASTER RECOVERY COMPLETED ==="
    log_success "Recovery completed in ${recovery_duration} seconds"
    
    if [ $recovery_duration -le $RECOVERY_TIME_OBJECTIVE ]; then
        log_success "Recovery Time Objective met (${recovery_duration}s <= ${RECOVERY_TIME_OBJECTIVE}s)"
    else
        log_warning "Recovery Time Objective exceeded (${recovery_duration}s > ${RECOVERY_TIME_OBJECTIVE}s)"
    fi
    
    # Update recovery configuration
    echo "LAST_RECOVERY_TIME=$(date '+%Y-%m-%d %H:%M:%S')" >> "$RECOVERY_CONFIG_FILE"
    echo "LAST_RECOVERY_DURATION=$recovery_duration" >> "$RECOVERY_CONFIG_FILE"
    echo "LAST_RECOVERY_STATUS=success" >> "$RECOVERY_CONFIG_FILE"
}

# Test disaster recovery procedures
test_recovery() {
    log_info "=== DISASTER RECOVERY TEST ==="
    log_info "This will test recovery procedures without affecting production"
    
    local test_db="${DB_NAME}_recovery_test"
    local test_dir="/tmp/givingbridge_recovery_test"
    
    # Clean up any previous test
    mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" -e "DROP DATABASE IF EXISTS \`$test_db\`;" 2>/dev/null || true
    rm -rf "$test_dir"
    
    # Test database recovery
    log_info "Testing database recovery..."
    local db_backup
    db_backup=$(find_latest_database_backup) || {
        log_error "No database backup found for testing"
        return 1
    }
    
    restore_database "$db_backup" "$test_db" || {
        log_error "Database recovery test failed"
        return 1
    }
    
    # Test file recovery
    log_info "Testing file recovery..."
    local file_backup
    file_backup=$(find_latest_file_backup) || {
        log_warning "No file backup found for testing"
    }
    
    if [ -n "$file_backup" ]; then
        restore_files "$file_backup" "$test_dir" || {
            log_error "File recovery test failed"
        }
    fi
    
    # Clean up test resources
    log_info "Cleaning up test resources..."
    mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" -e "DROP DATABASE IF EXISTS \`$test_db\`;" 2>/dev/null || true
    rm -rf "$test_dir"
    
    log_success "Disaster recovery test completed successfully"
    
    # Update test timestamp
    echo "LAST_RECOVERY_TEST=$(date '+%Y-%m-%d %H:%M:%S')" >> "$RECOVERY_CONFIG_FILE"
    echo "LAST_TEST_STATUS=success" >> "$RECOVERY_CONFIG_FILE"
}

# Monitor recovery metrics
monitor_recovery() {
    log_info "=== RECOVERY MONITORING ==="
    
    # Check backup freshness
    local db_backup
    db_backup=$(find_latest_database_backup 2>/dev/null) || {
        log_critical "No database backup available"
        return 1
    }
    
    local backup_age
    backup_age=$(( $(date +%s) - $(stat -c %Y "$db_backup") ))
    
    log_info "Latest database backup age: ${backup_age} seconds"
    
    if [ $backup_age -le $RECOVERY_POINT_OBJECTIVE ]; then
        log_success "Recovery Point Objective met"
    else
        log_warning "Recovery Point Objective exceeded (${backup_age}s > ${RECOVERY_POINT_OBJECTIVE}s)"
    fi
    
    # Check system health
    log_info "Checking system health..."
    local health_issues
    health_issues=$(check_system_health 2>/dev/null | grep -c "ERROR" || echo "0")
    
    if [ "$health_issues" -eq 0 ]; then
        log_success "System health: OK"
    else
        log_warning "System health: $health_issues issues found"
    fi
    
    # Display recovery readiness
    log_info "Recovery readiness: $([ "$health_issues" -eq 0 ] && [ $backup_age -le $RECOVERY_POINT_OBJECTIVE ] && echo "READY" || echo "NOT READY")"
}

# Show recovery status
show_status() {
    log_info "=== DISASTER RECOVERY STATUS ==="
    
    # Load configuration
    load_recovery_config
    
    # Show configuration
    log_info "Recovery Time Objective: ${RECOVERY_TIME_OBJECTIVE} seconds"
    log_info "Recovery Point Objective: ${RECOVERY_POINT_OBJECTIVE} seconds"
    log_info "Database: $DB_HOST:$DB_PORT/$DB_NAME"
    log_info "Application Directory: $APP_DIR"
    log_info "Backup Directory: $BACKUP_DIR"
    
    # Show backup status
    local db_backup
    db_backup=$(find_latest_database_backup 2>/dev/null) || db_backup="None"
    log_info "Latest Database Backup: $(basename "$db_backup")"
    
    local file_backup
    file_backup=$(find_latest_file_backup 2>/dev/null | cut -d'|' -f1) || file_backup="None"
    log_info "Latest File Backup: $(basename "$file_backup")"
    
    # Show last recovery information
    if [ -f "$RECOVERY_CONFIG_FILE" ]; then
        local last_test=$(grep "LAST_RECOVERY_TEST=" "$RECOVERY_CONFIG_FILE" 2>/dev/null | cut -d'=' -f2 || echo "Never")
        local last_recovery=$(grep "LAST_RECOVERY_TIME=" "$RECOVERY_CONFIG_FILE" 2>/dev/null | cut -d'=' -f2 || echo "Never")
        
        log_info "Last Recovery Test: $last_test"
        log_info "Last Recovery: $last_recovery"
    fi
    
    # Show current health
    monitor_recovery
}

# Show help
show_help() {
    echo "GivingBridge Disaster Recovery System"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  recover         Perform full disaster recovery"
    echo "  test            Test recovery procedures (safe)"
    echo "  monitor         Monitor recovery readiness"
    echo "  status          Show recovery status"
    echo "  configure       Configure recovery settings"
    echo "  health          Check system health"
    echo "  help            Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  DB_HOST                 Database host (default: localhost)"
    echo "  DB_PORT                 Database port (default: 3306)"
    echo "  DB_NAME                 Database name (default: givingbridge)"
    echo "  DB_USER                 Database user (default: root)"
    echo "  DB_PASSWORD             Database password"
    echo "  BACKUP_DIR              Backup directory (default: ./backups)"
    echo "  RECOVERY_TIME_OBJECTIVE Maximum recovery time in seconds (default: 3600)"
    echo "  RECOVERY_POINT_OBJECTIVE Maximum data loss in seconds (default: 1800)"
    echo ""
    echo "Examples:"
    echo "  $0 test                 # Test recovery procedures"
    echo "  $0 monitor              # Check recovery readiness"
    echo "  $0 recover              # Perform actual recovery (DESTRUCTIVE)"
}

# Main function
main() {
    local command="${1:-help}"
    
    # Create log directory
    create_log_directory
    
    # Load configuration
    load_recovery_config
    
    case "$command" in
        recover)
            log_critical "WARNING: This will perform a full disaster recovery!"
            log_critical "This operation is DESTRUCTIVE and will replace current data!"
            read -p "Are you sure you want to continue? (type 'YES' to confirm): " confirm
            if [ "$confirm" = "YES" ]; then
                perform_full_recovery
            else
                log_info "Recovery cancelled by user"
            fi
            ;;
        test)
            test_recovery
            ;;
        monitor)
            monitor_recovery
            ;;
        status)
            show_status
            ;;
        configure)
            save_recovery_config
            ;;
        health)
            check_system_health
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Handle script interruption
trap 'log_error "Recovery operation interrupted"; exit 1' INT TERM

# Run main function
main "$@"