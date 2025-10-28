#!/bin/bash

# Database Backup Script for GivingBridge
# Creates compressed backups with rotation and verification

set -e

# Configuration
DB_HOST=${DB_HOST:-"localhost"}
DB_PORT=${DB_PORT:-"3306"}
DB_NAME=${DB_NAME:-"givingbridge"}
DB_USER=${DB_BACKUP_USER:-"givingbridge_backup"}
DB_PASSWORD=${DB_BACKUP_PASSWORD:-"backup_password_change_me"}

BACKUP_DIR=${BACKUP_DIR:-"./backups/database"}
BACKUP_RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-30}
COMPRESS_BACKUPS=${COMPRESS_BACKUPS:-true}
VERIFY_BACKUPS=${VERIFY_BACKUPS:-true}

# S3 configuration (optional)
S3_BUCKET=${S3_BACKUP_BUCKET:-""}
S3_PREFIX=${S3_BACKUP_PREFIX:-"givingbridge/database"}
AWS_REGION=${AWS_REGION:-"us-east-1"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Create backup directory
create_backup_directory() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        log_info "Created backup directory: $BACKUP_DIR"
    fi
}

# Check database connectivity
check_database_connection() {
    log_info "Checking database connection..."
    
    if ! mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" > /dev/null 2>&1; then
        log_error "Cannot connect to database"
        log_error "Host: $DB_HOST:$DB_PORT"
        log_error "User: $DB_USER"
        log_error "Database: $DB_NAME"
        exit 1
    fi
    
    log_success "Database connection successful"
}

# Get database size
get_database_size() {
    local size_query="SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'DB Size in MB' 
                     FROM information_schema.tables 
                     WHERE table_schema='$DB_NAME';"
    
    local db_size=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" -sN -e "$size_query")
    echo "$db_size"
}

# Create database backup
create_backup() {
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_filename="${DB_NAME}_backup_${timestamp}.sql"
    local backup_path="$BACKUP_DIR/$backup_filename"
    
    log_info "Starting database backup..."
    log_info "Database: $DB_NAME"
    log_info "Size: $(get_database_size) MB"
    log_info "Backup file: $backup_filename"
    
    # Create backup with mysqldump
    local mysqldump_options=(
        --host="$DB_HOST"
        --port="$DB_PORT"
        --user="$DB_USER"
        --password="$DB_PASSWORD"
        --single-transaction
        --routines
        --triggers
        --events
        --hex-blob
        --opt
        --lock-tables=false
        --set-gtid-purged=OFF
        --default-character-set=utf8mb4
    )
    
    if ! mysqldump "${mysqldump_options[@]}" "$DB_NAME" > "$backup_path"; then
        log_error "Database backup failed"
        rm -f "$backup_path"
        exit 1
    fi
    
    log_success "Database backup created: $backup_path"
    
    # Compress backup if enabled
    if [ "$COMPRESS_BACKUPS" = true ]; then
        log_info "Compressing backup..."
        
        if gzip "$backup_path"; then
            backup_path="${backup_path}.gz"
            backup_filename="${backup_filename}.gz"
            log_success "Backup compressed: $backup_path"
        else
            log_warning "Backup compression failed, keeping uncompressed file"
        fi
    fi
    
    # Verify backup if enabled
    if [ "$VERIFY_BACKUPS" = true ]; then
        verify_backup "$backup_path"
    fi
    
    # Upload to S3 if configured
    if [ -n "$S3_BUCKET" ]; then
        upload_to_s3 "$backup_path" "$backup_filename"
    fi
    
    echo "$backup_path"
}

# Verify backup integrity
verify_backup() {
    local backup_path="$1"
    
    log_info "Verifying backup integrity..."
    
    # Check if file exists and is not empty
    if [ ! -f "$backup_path" ] || [ ! -s "$backup_path" ]; then
        log_error "Backup file is missing or empty"
        return 1
    fi
    
    # Check file format
    local file_type
    if [[ "$backup_path" == *.gz ]]; then
        # Check gzip integrity
        if ! gzip -t "$backup_path"; then
            log_error "Backup file is corrupted (gzip test failed)"
            return 1
        fi
        
        # Check SQL content
        file_type=$(zcat "$backup_path" | head -n 5 | grep -c "-- MySQL dump" || true)
    else
        # Check SQL content directly
        file_type=$(head -n 5 "$backup_path" | grep -c "-- MySQL dump" || true)
    fi
    
    if [ "$file_type" -eq 0 ]; then
        log_error "Backup file does not appear to be a valid MySQL dump"
        return 1
    fi
    
    # Get file size
    local file_size=$(du -h "$backup_path" | cut -f1)
    
    log_success "Backup verification passed"
    log_info "Backup size: $file_size"
}

# Upload backup to S3
upload_to_s3() {
    local backup_path="$1"
    local backup_filename="$2"
    
    log_info "Uploading backup to S3..."
    
    # Check if AWS CLI is available
    if ! command -v aws &> /dev/null; then
        log_warning "AWS CLI not found, skipping S3 upload"
        return 0
    fi
    
    local s3_key="$S3_PREFIX/$backup_filename"
    
    if aws s3 cp "$backup_path" "s3://$S3_BUCKET/$s3_key" --region "$AWS_REGION"; then
        log_success "Backup uploaded to S3: s3://$S3_BUCKET/$s3_key"
        
        # Set lifecycle policy for automatic deletion
        aws s3api put-object-tagging \
            --bucket "$S3_BUCKET" \
            --key "$s3_key" \
            --tagging "TagSet=[{Key=backup-type,Value=database},{Key=retention-days,Value=$BACKUP_RETENTION_DAYS}]" \
            --region "$AWS_REGION" || log_warning "Failed to set S3 object tags"
    else
        log_error "Failed to upload backup to S3"
    fi
}

# Clean up old backups
cleanup_old_backups() {
    log_info "Cleaning up backups older than $BACKUP_RETENTION_DAYS days..."
    
    local deleted_count=0
    
    # Find and delete old local backups
    while IFS= read -r -d '' file; do
        rm -f "$file"
        deleted_count=$((deleted_count + 1))
        log_info "Deleted old backup: $(basename "$file")"
    done < <(find "$BACKUP_DIR" -name "${DB_NAME}_backup_*.sql*" -type f -mtime +$BACKUP_RETENTION_DAYS -print0)
    
    if [ $deleted_count -eq 0 ]; then
        log_info "No old backups to clean up"
    else
        log_success "Cleaned up $deleted_count old backup(s)"
    fi
    
    # Clean up old S3 backups if configured
    if [ -n "$S3_BUCKET" ]; then
        cleanup_s3_backups
    fi
}

# Clean up old S3 backups
cleanup_s3_backups() {
    log_info "Cleaning up old S3 backups..."
    
    if ! command -v aws &> /dev/null; then
        log_warning "AWS CLI not found, skipping S3 cleanup"
        return 0
    fi
    
    local cutoff_date=$(date -d "$BACKUP_RETENTION_DAYS days ago" '+%Y-%m-%d')
    
    # List and delete old S3 objects
    aws s3api list-objects-v2 \
        --bucket "$S3_BUCKET" \
        --prefix "$S3_PREFIX/" \
        --query "Contents[?LastModified<='$cutoff_date'].Key" \
        --output text \
        --region "$AWS_REGION" | \
    while read -r key; do
        if [ -n "$key" ] && [ "$key" != "None" ]; then
            aws s3 rm "s3://$S3_BUCKET/$key" --region "$AWS_REGION"
            log_info "Deleted old S3 backup: $key"
        fi
    done
}

# Generate backup report
generate_backup_report() {
    local backup_path="$1"
    local backup_size=$(du -h "$backup_path" | cut -f1)
    local db_size=$(get_database_size)
    
    log_info "=== Backup Report ==="
    log_info "Database: $DB_NAME"
    log_info "Database Size: ${db_size} MB"
    log_info "Backup File: $(basename "$backup_path")"
    log_info "Backup Size: $backup_size"
    log_info "Compression: $([ "$COMPRESS_BACKUPS" = true ] && echo "Enabled" || echo "Disabled")"
    log_info "Verification: $([ "$VERIFY_BACKUPS" = true ] && echo "Passed" || echo "Skipped")"
    log_info "S3 Upload: $([ -n "$S3_BUCKET" ] && echo "Enabled" || echo "Disabled")"
    log_info "Retention: $BACKUP_RETENTION_DAYS days"
    log_info "===================="
}

# Main backup function
main() {
    log_info "Starting GivingBridge database backup..."
    
    # Validate environment
    if [ -z "$DB_PASSWORD" ] || [ "$DB_PASSWORD" = "backup_password_change_me" ]; then
        log_error "Database backup password not configured"
        log_error "Please set DB_BACKUP_PASSWORD environment variable"
        exit 1
    fi
    
    # Create backup directory
    create_backup_directory
    
    # Check database connection
    check_database_connection
    
    # Create backup
    local backup_path
    backup_path=$(create_backup)
    
    # Clean up old backups
    cleanup_old_backups
    
    # Generate report
    generate_backup_report "$backup_path"
    
    log_success "Database backup completed successfully!"
}

# Handle script interruption
trap 'log_error "Backup interrupted"; exit 1' INT TERM

# Run main function
main "$@"