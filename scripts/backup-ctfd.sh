#!/bin/bash
# CTFd Backup Script
# Backs up CTFd challenges, users, and submissions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load shared scripts
source "$SCRIPT_DIR/ctfd-client.sh"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  CTFd Backup Utility"
echo "═══════════════════════════════════════════════════════"
echo ""

# Check prerequisites
if ! check_prerequisites; then
    log_error "Prerequisites check failed"
    exit 1
fi

# Create backup directory
BACKUP_DIR="$PROJECT_ROOT/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/ctfd_backup_$TIMESTAMP"

mkdir -p "$BACKUP_PATH"

log_info "Backup location: $BACKUP_PATH"
echo ""

# ═══════════════════════════════════════════════════════
# Backup Challenges
# ═══════════════════════════════════════════════════════

log_info "Backing up challenges..."

curl -s -H "Authorization: Token ${CTFD_TOKEN}" \
    -H "Content-Type: application/json" \
    "$CTFD_API/challenges" > "$BACKUP_PATH/challenges.json"

challenge_count=$(cat "$BACKUP_PATH/challenges.json" | jq '.data | length')
log_info "✓ Backed up $challenge_count challenges"

# ═══════════════════════════════════════════════════════
# Backup Users
# ═══════════════════════════════════════════════════════

log_info "Backing up users..."

curl -s -H "Authorization: Token ${CTFD_TOKEN}" \
    -H "Content-Type: application/json" \
    "$CTFD_API/users" > "$BACKUP_PATH/users.json"

user_count=$(cat "$BACKUP_PATH/users.json" | jq '.data | length' 2>/dev/null || echo "0")
log_info "✓ Backed up $user_count users"

# ═══════════════════════════════════════════════════════
# Backup Teams (if applicable)
# ═══════════════════════════════════════════════════════

log_info "Backing up teams..."

curl -s -H "Authorization: Token ${CTFD_TOKEN}" \
    -H "Content-Type: application/json" \
    "$CTFD_API/teams" > "$BACKUP_PATH/teams.json" 2>/dev/null || echo '{"data":[]}' > "$BACKUP_PATH/teams.json"

team_count=$(cat "$BACKUP_PATH/teams.json" | jq '.data | length' 2>/dev/null || echo "0")
log_info "✓ Backed up $team_count teams"

# ═══════════════════════════════════════════════════════
# Backup Submissions
# ═══════════════════════════════════════════════════════

log_info "Backing up submissions..."

curl -s -H "Authorization: Token ${CTFD_TOKEN}" \
    -H "Content-Type: application/json" \
    "$CTFD_API/submissions" > "$BACKUP_PATH/submissions.json" 2>/dev/null || echo '{"data":[]}' > "$BACKUP_PATH/submissions.json"

submission_count=$(cat "$BACKUP_PATH/submissions.json" | jq '.data | length' 2>/dev/null || echo "0")
log_info "✓ Backed up $submission_count submissions"

# ═══════════════════════════════════════════════════════
# Backup Flags
# ═══════════════════════════════════════════════════════

log_info "Backing up flags..."

curl -s -H "Authorization: Token ${CTFD_TOKEN}" \
    -H "Content-Type: application/json" \
    "$CTFD_API/flags" > "$BACKUP_PATH/flags.json" 2>/dev/null || echo '{"data":[]}' > "$BACKUP_PATH/flags.json"

flag_count=$(cat "$BACKUP_PATH/flags.json" | jq '.data | length' 2>/dev/null || echo "0")
log_info "✓ Backed up $flag_count flags"

# ═══════════════════════════════════════════════════════
# Backup Hints
# ═══════════════════════════════════════════════════════

log_info "Backing up hints..."

curl -s -H "Authorization: Token ${CTFD_TOKEN}" \
    -H "Content-Type: application/json" \
    "$CTFD_API/hints" > "$BACKUP_PATH/hints.json" 2>/dev/null || echo '{"data":[]}' > "$BACKUP_PATH/hints.json"

hint_count=$(cat "$BACKUP_PATH/hints.json" | jq '.data | length' 2>/dev/null || echo "0")
log_info "✓ Backed up $hint_count hints"

# ═══════════════════════════════════════════════════════
# Backup Configuration Files
# ═══════════════════════════════════════════════════════

log_info "Backing up configuration files..."

# Copy challenge configurations
mkdir -p "$BACKUP_PATH/configs"

if [ -f "$PROJECT_ROOT/mastodon/challenges.yml" ]; then
    cp "$PROJECT_ROOT/mastodon/challenges.yml" "$BACKUP_PATH/configs/mastodon-challenges.yml"
fi

if [ -f "$PROJECT_ROOT/hospital/challenges.yml" ]; then
    cp "$PROJECT_ROOT/hospital/challenges.yml" "$BACKUP_PATH/configs/hospital-challenges.yml"
fi

# Copy generated flags (without exposing them in git)
if [ -f "$PROJECT_ROOT/mastodon/.generated-flags.txt" ]; then
    cp "$PROJECT_ROOT/mastodon/.generated-flags.txt" "$BACKUP_PATH/configs/mastodon-flags.txt"
fi

if [ -f "$PROJECT_ROOT/hospital/.generated-flags.txt" ]; then
    cp "$PROJECT_ROOT/hospital/.generated-flags.txt" "$BACKUP_PATH/configs/hospital-flags.txt"
fi

log_info "✓ Backed up configuration files"

# ═══════════════════════════════════════════════════════
# Create Backup Manifest
# ═══════════════════════════════════════════════════════

log_info "Creating backup manifest..."

cat > "$BACKUP_PATH/manifest.txt" <<EOF
CTFd Backup Manifest
====================

Backup Date: $(date)
CTFd URL: $CTFD_URL
Backup Path: $BACKUP_PATH

Contents:
---------
Challenges:  $challenge_count
Users:       $user_count
Teams:       $team_count
Submissions: $submission_count
Flags:       $flag_count
Hints:       $hint_count

Files:
------
- challenges.json
- users.json
- teams.json
- submissions.json
- flags.json
- hints.json
- configs/mastodon-challenges.yml
- configs/hospital-challenges.yml
- configs/mastodon-flags.txt (if generated)
- configs/hospital-flags.txt (if generated)

Restore Instructions:
---------------------
This is a JSON backup of CTFd data. To restore:

1. Use CTFd's import feature in admin panel
2. Or use the CTFd API to recreate challenges
3. Configuration files can be used to re-register challenges

Note: This backup contains sensitive data including flags.
Store securely and do not commit to git!
EOF

log_info "✓ Created manifest"

# ═══════════════════════════════════════════════════════
# Create Archive
# ═══════════════════════════════════════════════════════

log_info "Creating compressed archive..."

cd "$BACKUP_DIR"
tar -czf "ctfd_backup_$TIMESTAMP.tar.gz" "ctfd_backup_$TIMESTAMP"

ARCHIVE_SIZE=$(du -h "ctfd_backup_$TIMESTAMP.tar.gz" | cut -f1)
log_info "✓ Created archive: ctfd_backup_$TIMESTAMP.tar.gz ($ARCHIVE_SIZE)"

# ═══════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  BACKUP COMPLETE"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Backup Summary:"
echo "  • Challenges:  $challenge_count"
echo "  • Users:       $user_count"
echo "  • Teams:       $team_count"
echo "  • Submissions: $submission_count"
echo "  • Flags:       $flag_count"
echo "  • Hints:       $hint_count"
echo ""
echo "Backup Files:"
echo "  • Directory: $BACKUP_PATH"
echo "  • Archive:   $BACKUP_DIR/ctfd_backup_$TIMESTAMP.tar.gz"
echo "  • Size:      $ARCHIVE_SIZE"
echo ""
echo "⚠️  SECURITY WARNING:"
echo "  This backup contains sensitive data including flags and user information."
echo "  Store securely and do NOT commit to version control!"
echo ""
echo "To view manifest:"
echo "  cat $BACKUP_PATH/manifest.txt"
echo ""
echo "To extract archive:"
echo "  tar -xzf $BACKUP_DIR/ctfd_backup_$TIMESTAMP.tar.gz -C $BACKUP_DIR"
echo ""
echo "═══════════════════════════════════════════════════════"
echo ""

# Optional: Clean up old backups (keep last 5)
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/ctfd_backup_*.tar.gz 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 5 ]; then
    log_warn "You have $BACKUP_COUNT backups. Consider cleaning up old ones."
    echo "  To remove old backups:"
    echo "  ls -t $BACKUP_DIR/ctfd_backup_*.tar.gz | tail -n +6 | xargs rm"
    echo ""
fi

exit 0
