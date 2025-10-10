#!/bin/bash

# ============================================================================
# Logger - Centralized logging system
# ============================================================================

# Initialize logger
init_logger() {
    # Create log directory if not exists (CRITICAL - BEFORE any logging)
    mkdir -p "$LOG_DIR"
    
    # Create log file if not exists
    touch "$LOG_FILE" 2>/dev/null || {
        echo "HATA: Log dosyası oluşturulamadı: $LOG_FILE"
        return 1
    }
    
    # Rotate log if too large
    if [[ "$LOG_ROTATION" == true ]]; then
        rotate_log_if_needed
    fi
    
    # Write header
    log_message "INFO" "═══════════════════════════════════════════════════════════"
    log_message "INFO" "System Theme Setup v$THEME_SETUP_VERSION started"
    log_message "INFO" "User: $(whoami) | Date: $(date)"
    log_message "INFO" "═══════════════════════════════════════════════════════════"
}

# Core logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Write to log file (only if log file exists)
    if [[ -f "$LOG_FILE" ]]; then
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE" 2>/dev/null
    fi
    
    # Also write to console based on level
    case "$level" in
        "DEBUG")
            [[ "$LOG_LEVEL" == "DEBUG" ]] && echo -e "${BLUE}[DEBUG]${NC} $message"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ${NC} $message"
            ;;
        "SUCCESS")
            echo -e "${GREEN}✓${NC} $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}✗${NC} $message" >&2
            ;;
    esac
}

# Convenience functions
log_debug() {
    log_message "DEBUG" "$1"
}

log_info() {
    log_message "INFO" "$1"
}

log_success() {
    log_message "SUCCESS" "$1"
}

log_warning() {
    log_message "WARNING" "$1"
}

log_error() {
    log_message "ERROR" "$1"
}

# Log rotation
rotate_log_if_needed() {
    if [[ -f "$LOG_FILE" ]]; then
        local log_size=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null)
        local max_size=$((10 * 1024 * 1024))  # 10MB
        
        if [[ $log_size -gt $max_size ]]; then
            local backup_log="$LOG_FILE.$(date +%Y%m%d_%H%M%S).old"
            mv "$LOG_FILE" "$backup_log"
            
            # Compress old log
            if [[ "$BACKUP_COMPRESSION" == true ]]; then
                gzip "$backup_log" 2>/dev/null
            fi
            
            # Keep only last 5 logs
            ls -t "$LOG_DIR"/*.old.gz 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null
        fi
    fi
}

# Progress indicator
show_progress() {
    local message="$1"
    local current="$2"
    local total="$3"
    
    local percent=$((current * 100 / total))
    local bars=$((percent / 2))
    local spaces=$((50 - bars))
    
    printf "\r${CYAN}%s${NC} [" "$message"
    printf "%${bars}s" | tr ' ' '='
    printf "%${spaces}s" | tr ' ' ' '
    printf "] %3d%%" "$percent"
    
    if [[ $current -eq $total ]]; then
        echo
    fi
}

# Step indicator
log_step() {
    local step="$1"
    local total="$2"
    local message="$3"
    
    echo
    echo -e "${BOLD}${CYAN}[Adım $step/$total]${NC} $message"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Box message
log_box() {
    local message="$1"
    local color="${2:-$CYAN}"
    
    local length=${#message}
    local border_length=$((length + 4))
    
    echo
    echo -e "${color}╔$(printf '═%.0s' $(seq 1 $border_length))╗${NC}"
    echo -e "${color}║  ${message}  ║${NC}"
    echo -e "${color}╚$(printf '═%.0s' $(seq 1 $border_length))╝${NC}"
    echo
}

# Spinner
spinner() {
    local pid=$1
    local message="$2"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        i=$(((i + 1) % 10))
        printf "\r${CYAN}${spin:$i:1}${NC} $message"
        sleep 0.1
    done
    
    printf "\r${GREEN}✓${NC} $message\n"
}
