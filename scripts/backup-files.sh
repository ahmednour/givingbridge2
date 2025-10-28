#!/bin/bash

# File Storage Backup Script for GivingBridge
# Creates incremental backups of uploaded files with cloud storage integration

set -e

# Configuration
UPLOADS_DIR=${UPLOADS_DIR:-"./backend/uploads"}
BACKUP_DIR=${BACKUP_DIR:-"./backups/files"}
BACKUP_RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-30}
INCREMENTAL_BACKUP=${INCREMENTAL_BACKUP:-true}
COMPRESS_BACKUPS=${COMPRESS_BACKUPS:-true}
VERIFY_BACKUPS=${VERIFY_BACKUPS:-true}

# Cloud storage configuration
S3_BUCKET=${S3_FILES_BUCKET:-""}
S3_PREFIX=${S3_FILES_PREFIX:-"givingbridge/files"}
AWS_REGION=${AWS_REGION:-"us-east-1"}

# Rsync configuration for cloud providers
RSYNC_REMOTE=${RSYNC_REMOTE:-""}
RSYNC_OPTIONS=${RSYNC_OPTIONS:-"-avz --delete --progress"}

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

# Create backup directory structure
create_backup_directory() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        log_info "Created backup directory: $BACKUP_DIR"
    fi
    
    # Create subdirectories for different backup types
    mkdir -p "$BACKUP_DIR/full"
    mkdir -p "$BACKUP_DIR/incremental"
    mkdir -p "$BACKUP_DIR/metadata"
}

# Check if uploads directory exists
check_uploads_directory() {
    if [ ! -d "$UPLOADS_DIR" ]; then
        log_error "Uploads directory not found: $UPLOADS_DIR"
        exit 1
    fi
    
    log_info "Uploads directory found: $UPLOADS_DIR"
}

# Get directory size and file count
get_directory_stats() {
    local dir="$1"
    
    if [ ! -d "$dir" ]; then
        echo "0 0 0"
        return
    fi
    
    local size=$(du -sb "$dir" 2>/dev/null | cut -f1 || echo "0")
    local file_count=$(find "$dir" -type f 2>/dev/null | wc -l || echo "0")
    local dir_count=$(find "$dir" -type d 2>/dev/null | wc -l || echo "0")
    
    echo "$size $file_count $dir_count"
}

# Create file manifest
create_file_manifest() {
    local source_dir="$1"
    local manifest_file="$2"
    
    log_info "Creating file manifest..."
    
    # Create detailed file listing with checksums
    find "$source_dir" -type f -exec stat -c "%n|%s|%Y|%A" {} \; | \
    while IFS='|' read -r filepath size mtime perms; do
        # Calculate MD5 checksum
        local checksum=$(md5sum "$filepath" 2>/dev/null | cut -d' ' -f1 || echo "ERROR")
        local relative_path=${filepath#$source_dir/}
        
        echo "$relative_path|$size|$mtime|$perms|$checksum"
    done > "$manifest_file"
    
    log_success "File manifest created: $manifest_file"
}

# Verify file integrity using manifest
verify_backup_integrity() {
    local backup_dir="$1"
    local manifest_file="$2"
    
    log_info "Verifying backup integrity..."
    
    local errors=0
    local checked=0
    
    while IFS='|' read -r filepath size mtime perms checksum; do
        local full_path="$backup_dir/$filepath"
        checked=$((checked + 1))
        
        # Check if file exists
        if [ ! -f "$full_path" ]; then
            log_error "Missing file in backup: $filepath"
            errors=$((errors + 1))
            continue
        fi
        
        # Check file size
        local actual_size=$(stat -c "%s" "$full_path" 2>/dev/null || echo "0")
        if [ "$actual_size" != "$size" ]; then
            log_error "Size mismatch for $filepath: expected $size, got $actual_size"
            errors=$((errors + 1))
            continue
        fi
        
        # Check checksum (skip if original was ERROR)
        if [ "$checksum" != "ERROR" ]; then
            local actual_checksum=$(md5sum "$full_path" 2>/dev/null | cut -d' ' -f1 || echo "ERROR")
            if [ "$actual_checksum" != "$checksum" ]; then
                log_error "Checksum mismatch for $filepath"
                errors=$((errors + 1))
                continue
            fi
        fi
        
        # Progress indicator
        if [ $((checked % 100)) -eq 0 ]; then
            log_info "Verified $checked files..."
        fi
    done < "$manifest_file"
    
    if [ $errors -eq 0 ]; then
        log_success "Backup integrity verification passed ($checked files checked)"
        return 0
    else
        log_error "Backup integrity verification failed ($errors errors out of $checked files)"
        return 1
    fi
}

# Create full backup
create_full_backup() {
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_name="files_full_${timestamp}"
    local backup_path="$BACKUP_DIR/full/$backup_name"
    
    log_info "Starting full file backup..."
    log_info "Source: $UPLOADS_DIR"
    log_info "Destination: $backup_path"
    
    # Get source directory stats
    local stats
    stats=$(get_directory_stats "$UPLOADS_DIR")
    local source_size=$(echo "$stats" | cut -d' ' -f1)
    local source_files=$(echo "$stats" | cut -d' ' -f2)
    
    log_info "Source statistics: $source_files files, $(numfmt --to=iec $source_size)"
    
    # Create backup directory
    mkdir -p "$backup_path"
    
    # Copy files with rsync for efficiency
    if ! rsync -av --progress "$UPLOADS_DIR/" "$backup_path/"; then
        log_error "File backup failed"
        rm -rf "$backup_path"
        exit 1
    fi
    
    # Create manifest
    local manifest_file="$BACKUP_DIR/metadata/${backup_name}_manifest.txt"
    create_file_manifest "$backup_path" "$manifest_file"
    
    # Verify backup if enabled
    if [ "$VERIFY_BACKUPS" = true ]; then
        if ! verify_backup_integrity "$backup_path" "$manifest_file"; then
            log_error "Backup verification failed"
            exit 1
        fi
    fi
    
    # Compress backup if enabled
    if [ "$COMPRESS_BACKUPS" = true ]; then
        log_info "Compressing backup..."
        
        local compressed_file="$BACKUP_DIR/full/${backup_name}.tar.gz"
        if tar -czf "$compressed_file" -C "$BACKUP_DIR/full" "$backup_name"; then
            rm -rf "$backup_path"
            backup_path="$compressed_file"
            log_success "Backup compressed: $compressed_file"
        else
            log_warning "Backup compression failed, keeping uncompressed backup"
        fi
    fi
    
    # Upload to cloud storage if configured
    if [ -n "$S3_BUCKET" ]; then
        upload_to_s3 "$backup_path" "$(basename "$backup_path")"
    fi
    
    if [ -n "$RSYNC_REMOTE" ]; then
        upload_via_rsync "$backup_path" "$(basename "$backup_path")"
    fi
    
    log_success "Full backup completed: $backup_path"
    echo "$backup_path"
}

# Create incremental backup
create_incremental_backup() {
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_name="files_incremental_${timestamp}"
    local backup_path="$BACKUP_DIR/incremental/$backup_name"
    
    log_info "Starting incremental file backup..."
    
    # Find the latest full backup
    local latest_full_backup
    latest_full_backup=$(find "$BACKUP_DIR/full" -name "files_full_*" -type f -o -name "files_full_*" -type d | sort | tail -n 1)
    
    if [ -z "$latest_full_backup" ]; then
        log_warning "No full backup found, creating full backup instead"
        create_full_backup
        return
    fi
    
    log_info "Base backup: $(basename "$latest_full_backup")"
    
    # Create incremental backup directory
    mkdir -p "$backup_path"
    
    # Find files newer than the last backup
    local reference_time
    if [[ "$latest_full_backup" == *.tar.gz ]]; then
        reference_time=$(stat -c "%Y" "$latest_full_backup")
    else
        reference_time=$(find "$latest_full_backup" -type f -exec stat -c "%Y" {} \; | sort -n | tail -n 1)
    fi
    
    # Copy only files modified since last backup
    local copied_files=0
    find "$UPLOADS_DIR" -type f -newer "$latest_full_backup" | while read -r file; do
        local relative_path=${file#$UPLOADS_DIR/}
        local dest_path="$backup_path/$relative_path"
        local dest_dir=$(dirname "$dest_path")
        
        mkdir -p "$dest_dir"
        cp "$file" "$dest_path"
        copied_files=$((copied_files + 1))
    done
    
    if [ $copied_files -eq 0 ]; then
        log_info "No new files to backup since last backup"
        rmdir "$backup_path" 2>/dev/null || true
        return
    fi
    
    log_info "Copied $copied_files new/modified files"
    
    # Create manifest for incremental backup
    local manifest_file="$BACKUP_DIR/metadata/${backup_name}_manifest.txt"
    create_file_manifest "$backup_path" "$manifest_file"
    
    # Compress if enabled
    if [ "$COMPRESS_BACKUPS" = true ]; then
        log_info "Compressing incremental backup..."
        
        local compressed_file="$BACKUP_DIR/incremental/${backup_name}.tar.gz"
        if tar -czf "$compressed_file" -C "$BACKUP_DIR/incremental" "$backup_name"; then
            rm -rf "$backup_path"
            backup_path="$compressed_file"
            log_success "Incremental backup compressed: $compressed_file"
        fi
    fi
    
    # Upload to cloud storage
    if [ -n "$S3_BUCKET" ]; then
        upload_to_s3 "$backup_path" "incremental/$(basename "$backup_path")"
    fi
    
    log_success "Incremental backup completed: $backup_path"
    echo "$backup_path"
}

# Upload backup to S3
upload_to_s3() {
    local backup_path="$1"
    local s3_key_suffix="$2"
    
    log_info "Uploading backup to S3..."
    
    if ! command -v aws &> /dev/null; then
        log_warning "AWS CLI not found, skipping S3 upload"
        return 0
    fi
    
    local s3_key="$S3_PREFIX/$s3_key_suffix"
    
    # Upload with progress and multipart for large files
    if aws s3 cp "$backup_path" "s3://$S3_BUCKET/$s3_key" \
        --region "$AWS_REGION" \
        --storage-class STANDARD_IA \
        --metadata "backup-type=files,retention-days=$BACKUP_RETENTION_DAYS"; then
        
        log_success "Backup uploaded to S3: s3://$S3_BUCKET/$s3_key"
        
        # Set lifecycle policy tags
        aws s3api put-object-tagging \
            --bucket "$S3_BUCKET" \
            --key "$s3_key" \
            --tagging "TagSet=[{Key=backup-type,Value=files},{Key=retention-days,Value=$BACKUP_RETENTION_DAYS}]" \
            --region "$AWS_REGION" || log_warning "Failed to set S3 object tags"
    else
        log_error "Failed to upload backup to S3"
    fi
}

# Upload via rsync (for other cloud providers)
upload_via_rsync() {
    local backup_path="$1"
    local remote_path="$2"
    
    log_info "Uploading backup via rsync..."
    
    if ! command -v rsync &> /dev/null; then
        log_warning "rsync not found, skipping remote upload"
        return 0
    fi
    
    local full_remote_path="$RSYNC_REMOTE/$remote_path"
    
    if rsync $RSYNC_OPTIONS "$backup_path" "$full_remote_path"; then
        log_success "Backup uploaded via rsync: $full_remote_path"
    else
        log_error "Failed to upload backup via rsync"
    fi
}

# Clean up old backups
cleanup_old_backups() {
    log_info "Cleaning up backups older than $BACKUP_RETENTION_DAYS days..."
    
    local deleted_count=0
    
    # Clean up local full backups
    find "$BACKUP_DIR/full" -name "files_full_*" -type f -o -name "files_full_*" -type d | \
    while read -r backup; do
        if [ -n "$backup" ] && find "$backup" -mtime +$BACKUP_RETENTION_DAYS -print -quit | grep -q .; then
            if [ -d "$backup" ]; then
                rm -rf "$backup"
            else
                rm -f "$backup"
            fi
            deleted_count=$((deleted_count + 1))
            log_info "Deleted old backup: $(basename "$backup")"
        fi
    done
    
    # Clean up local incremental backups
    find "$BACKUP_DIR/incremental" -name "files_incremental_*" -type f -o -name "files_incremental_*" -type d | \
    while read -r backup; do
        if [ -n "$backup" ] && find "$backup" -mtime +$BACKUP_RETENTION_DAYS -print -quit | grep -q .; then
            if [ -d "$backup" ]; then
                rm -rf "$backup"
            else
                rm -f "$backup"
            fi
            deleted_count=$((deleted_count + 1))
            log_info "Deleted old incremental backup: $(basename "$backup")"
        fi
    done
    
    # Clean up old manifests
    find "$BACKUP_DIR/metadata" -name "*_manifest.txt" -mtime +$BACKUP_RETENTION_DAYS -delete
    
    if [ $deleted_count -eq 0 ]; then
        log_info "No old backups to clean up"
    else
        log_success "Cleaned up $deleted_count old backup(s)"
    fi
    
    # Clean up S3 backups if configured
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
    local backup_type="$2"
    
    local backup_size
    if [ -f "$backup_path" ]; then
        backup_size=$(du -h "$backup_path" | cut -f1)
    elif [ -d "$backup_path" ]; then
        backup_size=$(du -sh "$backup_path" | cut -f1)
    else
        backup_size="Unknown"
    fi
    
    local source_stats
    source_stats=$(get_directory_stats "$UPLOADS_DIR")
    local source_size=$(echo "$source_stats" | cut -d' ' -f1)
    local source_files=$(echo "$source_stats" | cut -d' ' -f2)
    
    log_info "=== File Backup Report ==="
    log_info "Backup Type: $backup_type"
    log_info "Source Directory: $UPLOADS_DIR"
    log_info "Source Files: $source_files"
    log_info "Source Size: $(numfmt --to=iec $source_size)"
    log_info "Backup File: $(basename "$backup_path")"
    log_info "Backup Size: $backup_size"
    log_info "Compression: $([ "$COMPRESS_BACKUPS" = true ] && echo "Enabled" || echo "Disabled")"
    log_info "Verification: $([ "$VERIFY_BACKUPS" = true ] && echo "Passed" || echo "Skipped")"
    log_info "S3 Upload: $([ -n "$S3_BUCKET" ] && echo "Enabled" || echo "Disabled")"
    log_info "Retention: $BACKUP_RETENTION_DAYS days"
    log_info "======================="
}

# Main backup function
main() {
    local backup_type="${1:-auto}"
    
    log_info "Starting GivingBridge file backup..."
    log_info "Backup type: $backup_type"
    
    # Create backup directory structure
    create_backup_directory
    
    # Check uploads directory
    check_uploads_directory
    
    # Determine backup type
    local backup_path
    case "$backup_type" in
        full)
            backup_path=$(create_full_backup)
            ;;
        incremental)
            backup_path=$(create_incremental_backup)
            ;;
        auto)
            if [ "$INCREMENTAL_BACKUP" = true ]; then
                backup_path=$(create_incremental_backup)
            else
                backup_path=$(create_full_backup)
            fi
            ;;
        *)
            log_error "Unknown backup type: $backup_type"
            log_error "Valid types: full, incremental, auto"
            exit 1
            ;;
    esac
    
    # Clean up old backups
    cleanup_old_backups
    
    # Generate report
    if [ -n "$backup_path" ]; then
        generate_backup_report "$backup_path" "$backup_type"
        log_success "File backup completed successfully!"
    else
        log_info "No backup created (no new files to backup)"
    fi
}

# Show help
show_help() {
    echo "GivingBridge File Backup Script"
    echo ""
    echo "Usage: $0 [BACKUP_TYPE]"
    echo ""
    echo "Backup Types:"
    echo "  full         Create full backup of all files"
    echo "  incremental  Create incremental backup (only changed files)"
    echo "  auto         Automatic mode (incremental if enabled, otherwise full)"
    echo ""
    echo "Environment Variables:"
    echo "  UPLOADS_DIR              Source directory (default: ./backend/uploads)"
    echo "  BACKUP_DIR               Backup destination (default: ./backups/files)"
    echo "  BACKUP_RETENTION_DAYS    Retention period (default: 30)"
    echo "  INCREMENTAL_BACKUP       Enable incremental backups (default: true)"
    echo "  COMPRESS_BACKUPS         Enable compression (default: true)"
    echo "  VERIFY_BACKUPS           Enable verification (default: true)"
    echo "  S3_FILES_BUCKET          S3 bucket for cloud backup"
    echo "  RSYNC_REMOTE             Remote rsync destination"
}

# Handle script arguments
case "${1:-auto}" in
    help|--help|-h)
        show_help
        exit 0
        ;;
    *)
        # Handle script interruption
        trap 'log_error "Backup interrupted"; exit 1' INT TERM
        
        # Run main function
        main "$@"
        ;;
esac