#!/bin/bash
# Hospital Flag Planting Script
# Plants flags in the Hospital system based on configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config/hospital/challenges.yml"

# Load shared scripts
source "$SCRIPT_DIR/../scripts/ctfd-client.sh"
source "$SCRIPT_DIR/../scripts/flag-generator.sh"

echo ""
log_info "════════════════════════════════════════"
log_info "  Hospital Flag Planting Script"
log_info "════════════════════════════════════════"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    log_error "This script must run as root to modify system files"
    log_error "Run with: sudo $0"
    exit 1
fi

# Validate config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    log_error "Config file not found: $CONFIG_FILE"
    exit 1
fi

log_info "Configuration: $CONFIG_FILE"
log_info "System: Hospital (hospital.cyberlab.local)"
echo ""

# Store generated flags for later use
GENERATED_FLAGS_FILE="$SCRIPT_DIR/.generated-flags.txt"
> "$GENERATED_FLAGS_FILE"  # Clear file

# ============================================
# Helper Functions
# ============================================

plant_flag_in_database() {
    local challenge_id="$1"
    local flag="$2"
    local details="$3"
    
    log_info "Planting flag in database..."
    log_debug "Challenge: $challenge_id"
    log_debug "Details: $details"
    
    # Check if PostgreSQL is available
    if ! command -v psql &> /dev/null; then
        log_warn "PostgreSQL client not found, skipping database flag"
        return 1
    fi
    
    # Example: Insert into patients table
    # Modify this based on your actual database schema
    sudo -u postgres psql hospital_db <<EOF 2>/dev/null || true
-- Backup existing data
CREATE TABLE IF NOT EXISTS ctf_backup_patients AS 
SELECT * FROM patients WHERE id = 999 LIMIT 0;

INSERT INTO ctf_backup_patients 
SELECT * FROM patients WHERE id = 999;

-- Insert or update flag
INSERT INTO patients (id, name, age, diagnosis, notes, created_at) 
VALUES (999, 'CTF Test Patient', 45, 'Routine Checkup', 'CTF Flag: $flag', NOW())
ON CONFLICT (id) DO UPDATE 
SET notes = 'CTF Flag: $flag',
    updated_at = NOW();
EOF
    
    if [ $? -eq 0 ]; then
        log_info "✓ Flag planted in database"
        return 0
    else
        log_warn "Database insertion may have failed (check manually)"
        return 1
    fi
}

plant_flag_in_file() {
    local challenge_id="$1"
    local flag="$2"
    local file_path="$3"
    local method="${4:-html_comment}"
    
    log_info "Planting flag in file..."
    log_debug "Challenge: $challenge_id"
    log_debug "File: $file_path"
    log_debug "Method: $method"
    
    # Check if file exists
    if [ ! -f "$file_path" ]; then
        log_warn "File not found: $file_path"
        log_warn "Skipping this flag (you may need to create the file first)"
        return 1
    fi
    
    # Backup original file
    if [ ! -f "${file_path}.ctf-backup" ]; then
        cp "$file_path" "${file_path}.ctf-backup"
        log_debug "Created backup: ${file_path}.ctf-backup"
    fi
    
    # Plant flag based on method
    case "$method" in
        html_comment)
            # Add HTML comment with flag
            if grep -q "CTF Flag:" "$file_path" 2>/dev/null; then
                log_warn "Flag already exists in file, skipping"
            else
                # Try to add after <body> tag, or at the end if no <body>
                if grep -q "<body" "$file_path"; then
                    sed -i "/<body/a\\  <!-- CTF Flag: $flag -->" "$file_path"
                else
                    echo "<!-- CTF Flag: $flag -->" >> "$file_path"
                fi
                log_info "✓ Flag planted in file as HTML comment"
            fi
            ;;
            
        config_value)
            # Add as configuration value
            if grep -q "ctf_flag" "$file_path" 2>/dev/null; then
                log_warn "Flag already exists in config, skipping"
            else
                echo "# CTF Flag" >> "$file_path"
                echo "ctf_flag=$flag" >> "$file_path"
                log_info "✓ Flag planted in file as config value"
            fi
            ;;
            
        json_field)
            # Add as JSON field (requires jq)
            if command -v jq &> /dev/null; then
                jq ". + {ctf_flag: \"$flag\"}" "$file_path" > "${file_path}.tmp"
                mv "${file_path}.tmp" "$file_path"
                log_info "✓ Flag planted in file as JSON field"
            else
                log_warn "jq not found, cannot add JSON flag"
                return 1
            fi
            ;;
            
        *)
            log_warn "Unknown planting method: $method"
            return 1
            ;;
    esac
    
    return 0
}

# ============================================
# Main Flag Planting Logic
# ============================================

log_info "Generating and planting flags..."
echo ""

# Challenge 1: Patient Records (database flag)
log_info "[1/2] Processing: hospital_patient_records"
FLAG_1=$(generate_challenge_flag "hospital" "hospital_patient_records")
echo "hospital_patient_records=$FLAG_1" >> "$GENERATED_FLAGS_FILE"
show_flag "Generated flag" "$FLAG_1"

# Try to plant in database
plant_flag_in_database "hospital_patient_records" "$FLAG_1" "patients table, id=999, notes column"
echo ""

# Challenge 2: Admin Dashboard (file/route flag)
log_info "[2/2] Processing: hospital_admin_dashboard"
FLAG_2=$(generate_challenge_flag "hospital" "hospital_admin_dashboard")
echo "hospital_admin_dashboard=$FLAG_2" >> "$GENERATED_FLAGS_FILE"
show_flag "Generated flag" "$FLAG_2"

# Try to plant in file
# NOTE: This might need to be done via code change (PR) instead
# Trying common locations, but manual planting may be required
FILE_PATH="/var/www/hospital/public/index.html"
if [ -f "$FILE_PATH" ]; then
    plant_flag_in_file "hospital_admin_dashboard" "$FLAG_2" "$FILE_PATH" "html_comment"
else
    log_warn "File not found: $FILE_PATH"
    log_warn "This flag likely needs to be planted via code change"
    log_warn "See flag-planting-manual.md for instructions"
    log_warn "Flag to plant: $FLAG_2"
fi
echo ""

# ============================================
# Summary
# ============================================

log_info "════════════════════════════════════════"
log_info "✓ Flag planting complete!"
log_info "════════════════════════════════════════"
echo ""
echo "Summary:"
echo "  • Flags generated: 2"
echo "  • Flags file: $GENERATED_FLAGS_FILE"
echo ""
echo "Generated flags:"
cat "$GENERATED_FLAGS_FILE"
echo ""
echo "Next steps:"
echo "  1. Verify flags are accessible in Hospital system"
echo "  2. Run: ./hospital/register-challenges.sh"
echo "     (This will register challenges with CTFd)"
echo "  3. Test challenges manually"
echo ""
echo "Backup files created with .ctf-backup extension"
echo ""

# Restart services if needed
# Uncomment if you need to restart Hospital services
# log_info "Restarting Hospital services..."
# systemctl restart hospital-app
# systemctl restart postgresql
