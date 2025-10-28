#!/bin/bash

# Automated Backup Scheduler for GivingBridge
# Sets up cron jobs for automated daily backups with monitoring

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SCRIPT="$SCRIPT_DIR/backup-database.sh"
LOG_DIR="/var/log/givingbridge"
CRON_LOG="$LOG_DIR/backup-cron.log"
BACKUP_TIME=${BACKUP_TIME:-"02:00"}  # Default: 2 AM
BACKUP_USER=${BACKUP_USER:-"root"}

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

# Create log directory
create_log_directory() {
    if [ ! -d "$LOG_DIR" ]; then
        sudo mkdir -p "$LOG_DIR"
        sudo chown "$BACKUP_USER:$BACKUP_USER" "$LOG_DIR"
        log_info "Created log directory: $LOG_DIR"
    fi
}

# Check if backup script exists and is executable
check_backup_script() {
    if [ ! -f "$BACKUP_SCRIPT" ]; then
        log_error "Backup script not found: $BACKUP_SCRIPT"
        exit 1
    fi
    
    if [ ! -x "$BACKUP_SCRIPT" ]; then
        chmod +x "$BACKUP_SCRIPT"
        log_info "Made backup script executable"
    fi
    
    log_success "Backup script verified: $BACKUP_SCRIPT"
}

# Parse backup time
parse_backup_time() {
    if [[ ! "$BACKUP_TIME" =~ ^([0-1]?[0-9]|2[0-3]):([0-5]?[0-9])$ ]]; then
        log_error "Invalid backup time format: $BACKUP_TIME"
        log_error "Expected format: HH:MM (24-hour format)"
        exit 1
    fi
    
    local hour=$(echo "$BACKUP_TIME" | cut -d: -f1)
    local minute=$(echo "$BACKUP_TIME" | cut -d: -f2)
    
    # Remove leading zeros
    hour=$((10#$hour))
    minute=$((10#$minute))
    
    echo "$minute $hour"
}

# Create cron job entry
create_cron_entry() {
    local time_parts
    time_parts=$(parse_backup_time)
    
    local cron_entry="$time_parts * * * $BACKUP_SCRIPT >> $CRON_LOG 2>&1"
    
    log_info "Cron entry: $cron_entry"
    echo "$cron_entry"
}

# Install cron job
install_cron_job() {
    local cron_entry
    cron_entry=$(create_cron_entry)
    
    log_info "Installing cron job for automated backups..."
    
    # Get current crontab
    local current_crontab
    current_crontab=$(crontab -u "$BACKUP_USER" -l 2>/dev/null || true)
    
    # Check if backup job already exists
    if echo "$current_crontab" | grep -q "$BACKUP_SCRIPT"; then
        log_warning "Backup cron job already exists"
        
        # Remove existing backup jobs
        local new_crontab
        new_crontab=$(echo "$current_crontab" | grep -v "$BACKUP_SCRIPT" || true)
        
        # Add new job
        if [ -n "$new_crontab" ]; then
            echo -e "$new_crontab\n$cron_entry" | crontab -u "$BACKUP_USER" -
        else
            echo "$cron_entry" | crontab -u "$BACKUP_USER" -
        fi
        
        log_info "Updated existing backup cron job"
    else
        # Add new job to existing crontab
        if [ -n "$current_crontab" ]; then
            echo -e "$current_crontab\n$cron_entry" | crontab -u "$BACKUP_USER" -
        else
            echo "$cron_entry" | crontab -u "$BACKUP_USER" -
        fi
        
        log_success "Installed new backup cron job"
    fi
    
    # Verify installation
    log_info "Current crontab for user $BACKUP_USER:"
    crontab -u "$BACKUP_USER" -l | grep "$BACKUP_SCRIPT" || log_error "Failed to verify cron job installation"
}

# Remove cron job
remove_cron_job() {
    log_info "Removing backup cron job..."
    
    local current_crontab
    current_crontab=$(crontab -u "$BACKUP_USER" -l 2>/dev/null || true)
    
    if echo "$current_crontab" | grep -q "$BACKUP_SCRIPT"; then
        local new_crontab
        new_crontab=$(echo "$current_crontab" | grep -v "$BACKUP_SCRIPT" || true)
        
        if [ -n "$new_crontab" ]; then
            echo "$new_crontab" | crontab -u "$BACKUP_USER" -
        else
            crontab -u "$BACKUP_USER" -r
        fi
        
        log_success "Removed backup cron job"
    else
        log_warning "No backup cron job found to remove"
    fi
}

# Check cron service status
check_cron_service() {
    log_info "Checking cron service status..."
    
    if systemctl is-active --quiet cron || systemctl is-active --quiet crond; then
        log_success "Cron service is running"
    else
        log_error "Cron service is not running"
        log_info "Starting cron service..."
        
        if systemctl start cron 2>/dev/null || systemctl start crond 2>/dev/null; then
            log_success "Cron service started"
        else
            log_error "Failed to start cron service"
            exit 1
        fi
    fi
}

# Test backup execution
test_backup() {
    log_info "Testing backup execution..."
    
    if "$BACKUP_SCRIPT"; then
        log_success "Backup test completed successfully"
    else
        log_error "Backup test failed"
        exit 1
    fi
}

# Show backup status
show_status() {
    log_info "=== Backup Scheduler Status ==="
    
    # Check cron job
    local cron_status="Not installed"
    if crontab -u "$BACKUP_USER" -l 2>/dev/null | grep -q "$BACKUP_SCRIPT"; then
        cron_status="Installed"
        local cron_line
        cron_line=$(crontab -u "$BACKUP_USER" -l | grep "$BACKUP_SCRIPT")
        log_info "Cron job: $cron_status"
        log_info "Schedule: $cron_line"
    else
        log_info "Cron job: $cron_status"
    fi
    
    # Check cron service
    if systemctl is-active --quiet cron || systemctl is-active --quiet crond; then
        log_info "Cron service: Running"
    else
        log_info "Cron service: Not running"
    fi
    
    # Check backup script
    if [ -x "$BACKUP_SCRIPT" ]; then
        log_info "Backup script: Available and executable"
    else
        log_info "Backup script: Not found or not executable"
    fi
    
    # Check log file
    if [ -f "$CRON_LOG" ]; then
        local log_size
        log_size=$(du -h "$CRON_LOG" | cut -f1)
        local last_backup
        last_backup=$(tail -n 1 "$CRON_LOG" 2>/dev/null | grep -o '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}' || echo "Never")
        
        log_info "Log file: $CRON_LOG ($log_size)"
        log_info "Last backup: $last_backup"
    else
        log_info "Log file: Not found"
    fi
    
    log_info "=========================="
}

# Show help
show_help() {
    echo "GivingBridge Backup Scheduler"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  install     Install automated backup cron job"
    echo "  remove      Remove backup cron job"
    echo "  status      Show backup scheduler status"
    echo "  test        Test backup execution"
    echo "  help        Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  BACKUP_TIME     Time to run backup (HH:MM format, default: 02:00)"
    echo "  BACKUP_USER     User to run backup as (default: root)"
    echo "  LOG_DIR         Directory for log files (default: /var/log/givingbridge)"
    echo ""
    echo "Examples:"
    echo "  $0 install                    # Install with default settings"
    echo "  BACKUP_TIME=03:30 $0 install # Install with custom time"
    echo "  $0 status                     # Check current status"
    echo "  $0 test                       # Test backup execution"
}

# Main function
main() {
    local command="${1:-help}"
    
    case "$command" in
        install)
            log_info "Installing automated backup scheduler..."
            create_log_directory
            check_backup_script
            check_cron_service
            install_cron_job
            log_success "Backup scheduler installed successfully!"
            log_info "Backups will run daily at $BACKUP_TIME"
            log_info "Logs will be written to: $CRON_LOG"
            ;;
        remove)
            remove_cron_job
            ;;
        status)
            show_status
            ;;
        test)
            check_backup_script
            test_backup
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
trap 'log_error "Operation interrupted"; exit 1' INT TERM

# Run main function
main "$@"