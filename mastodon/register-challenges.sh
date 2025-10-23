#!/bin/bash
# Mastodon Challenge Registration Script
# Registers challenges with CTFd based on configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/challenges.yml"
GENERATED_FLAGS_FILE="$SCRIPT_DIR/.generated-flags.txt"

# Load shared scripts
source "$SCRIPT_DIR/../scripts/ctfd-client.sh"

echo ""
log_info "════════════════════════════════════════"
log_info "  Mastodon Challenge Registration"
log_info "════════════════════════════════════════"
echo ""

# Check prerequisites
if ! check_prerequisites; then
    log_error "Prerequisites check failed"
    exit 1
fi

# Test connection
if ! test_connection; then
    log_error "Cannot connect to CTFd"
    exit 1
fi

# Check if flags were generated
if [ ! -f "$GENERATED_FLAGS_FILE" ]; then
    log_error "Flags file not found: $GENERATED_FLAGS_FILE"
    log_error "Run plant-flags-web.sh or test-local.sh first to generate flags"
    exit 1
fi

log_info "Configuration: $CONFIG_FILE"
log_info "CTFd URL: $CTFD_URL"
echo ""

# Load generated flags into associative array
declare -A FLAGS
while IFS='=' read -r key value; do
    FLAGS["$key"]="$value"
done < "$GENERATED_FLAGS_FILE"

log_info "Loaded ${#FLAGS[@]} generated flags"
echo ""

# ============================================
# Helper Function
# ============================================

register_single_challenge() {
    local challenge_id="$1"
    local name="$2"
    local category="$3"
    local description="$4"
    local points="$5"
    shift 5
    # Remaining arguments are hints in format "text|cost"
    local hints=("$@")

    log_info "Registering challenge: $name"

    # Get flag for this challenge
    local flag="${FLAGS[$challenge_id]}"
    if [ -z "$flag" ]; then
        log_error "No flag found for challenge: $challenge_id"
        return 1
    fi

    # Create challenge JSON payload
    local payload=$(jq -n \
        --arg name "$name" \
        --arg category "$category" \
        --arg description "$description" \
        --arg points "$points" \
        '{
            name: $name,
            category: $category,
            description: $description,
            value: ($points | tonumber),
            type: "standard",
            state: "visible"
        }')

    # Create challenge
    local ctfd_challenge_id=$(create_challenge "$payload")

    if [ -z "$ctfd_challenge_id" ] || [ "$ctfd_challenge_id" = "null" ]; then
        log_error "Failed to create challenge: $name"
        return 1
    fi

    # Add flag
    if ! add_flag "$ctfd_challenge_id" "$flag"; then
        log_error "Failed to add flag to challenge: $name"
        return 1
    fi

    # Add hints
    for hint_data in "${hints[@]}"; do
        if [ -n "$hint_data" ]; then
            local hint_text=$(echo "$hint_data" | cut -d'|' -f1)
            local hint_cost=$(echo "$hint_data" | cut -d'|' -f2)
            add_hint "$ctfd_challenge_id" "$hint_text" "$hint_cost"
        fi
    done

    log_info "✓ Challenge registered (CTFd ID: $ctfd_challenge_id)"
    echo ""
    return 0
}

# ============================================
# Register Challenges
# ============================================

log_info "Registering Mastodon challenges with CTFd..."
echo ""

# Challenge 1: The Hidden Toot
register_single_challenge \
    "mastodon_hidden_toot" \
    "The Hidden Toot" \
    "Mastodon - Chapter 1" \
    "Welcome to CyberLab's Mastodon instance! A mysterious user has joined our social network.

There are rumors that user **@ctf_user_2024** has posted something... interesting.
Can you find their secret message?

**Target:** https://mastodon.cyberlab.local
**Username to investigate:** @ctf_user_2024

**Hint:** Sometimes secrets are hidden in plain sight. Developers often leave comments...

Flag format: CYBERLABFLAG{...}" \
    100 \
    "Try viewing the page source of the user's profile or posts|0" \
    "Look for HTML comments in the page source - developers sometimes forget to remove them|25"

# Challenge 2: Profile Picture Secrets
register_single_challenge \
    "mastodon_profile_secrets" \
    "Profile Picture Secrets" \
    "Mastodon - Chapter 1" \
    "User **@ctf_user_2024** has an interesting profile picture...

Rumor has it they're not very good at hiding secrets in images.
Digital images can contain more information than meets the eye!

**Target:** https://mastodon.cyberlab.local/@ctf_user_2024

**Your mission:**
1. Download the user's profile picture
2. Analyze the image file for hidden data
3. Extract the flag

**Tools you might need:** exiftool, strings, steghide, or any metadata viewer

Flag format: CYBERLABFLAG{...}" \
    200 \
    "Images can contain metadata - information about when, where, and how they were created|0" \
    "Try using 'exiftool' command: exiftool image.jpg|50" \
    "Look for the 'Comment' field in the EXIF metadata|75"

# ============================================
# Summary
# ============================================

log_info "════════════════════════════════════════"
log_info "✓ Challenge registration complete!"
log_info "════════════════════════════════════════"
echo ""
echo "Summary:"
echo "  • Challenges registered: 2"
echo "  • Total points: 300"
echo "  • Chapter: 1 - Mastodon Social Network"
echo ""
echo "View challenges at: $CTFD_URL/challenges"
echo ""
echo "Next steps:"
echo "  1. Log in to CTFd and verify challenges appear"
echo "  2. Create a test user account"
echo "  3. Try to solve each challenge manually"
echo "  4. Verify flags work when submitted"
echo ""
