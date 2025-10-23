#!/bin/bash
# Mastodon Flag Planting Script (Web-Based)
# Prepares flags and creates image files for manual upload

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load shared scripts
source "$SCRIPT_DIR/../scripts/ctfd-client.sh"
source "$SCRIPT_DIR/../scripts/flag-generator.sh"

echo ""
log_info "════════════════════════════════════════"
log_info "  Mastodon Flag Planting (Web-Based)"
log_info "════════════════════════════════════════"
echo ""

log_info "This script prepares flags for manual planting via Mastodon web interface"
log_info "System: Mastodon (mastodon.cyberlab.local)"
echo ""

# Store generated flags for later use
GENERATED_FLAGS_FILE="$SCRIPT_DIR/.generated-flags.txt"
> "$GENERATED_FLAGS_FILE"  # Clear file

# Create temp directory for images
TEMP_DIR="$SCRIPT_DIR/.ctf_temp"
mkdir -p "$TEMP_DIR"

# ============================================
# Generate Flags
# ============================================

log_info "Step 1: Generating flags..."
echo ""

# Challenge 1: Hidden Toot
FLAG_1=$(generate_challenge_flag "mastodon" "mastodon_hidden_toot")
echo "mastodon_hidden_toot=$FLAG_1" >> "$GENERATED_FLAGS_FILE"
show_flag "Challenge 1 (Hidden Toot)" "$FLAG_1"
echo ""

# Challenge 2: Profile Secrets
FLAG_2=$(generate_challenge_flag "mastodon" "mastodon_profile_secrets")
echo "mastodon_profile_secrets=$FLAG_2" >> "$GENERATED_FLAGS_FILE"
show_flag "Challenge 2 (Profile Secrets)" "$FLAG_2"
echo ""

# ============================================
# Create Profile Picture with Metadata
# ============================================

log_info "Step 2: Creating profile picture with embedded flag..."
echo ""

PROFILE_IMG="$TEMP_DIR/ctf_profile_picture.jpg"

# Check if ImageMagick is installed
if command -v convert &> /dev/null; then
    # Create a simple profile image
    convert -size 400x400 gradient:blue-purple \
            -gravity center \
            -pointsize 48 -fill white \
            -annotate +0+0 "CTF\nUser" \
            "$PROFILE_IMG"

    log_info "✓ Base image created"
else
    log_warn "ImageMagick not found. Downloading placeholder image..."
    if command -v wget &> /dev/null; then
        wget -q https://via.placeholder.com/400x400/6b5b95/ffffff?text=CTF+User -O "$PROFILE_IMG" 2>/dev/null || \
            log_warn "Could not download image. You'll need to provide your own."
    else
        log_warn "Please provide your own profile image as: $PROFILE_IMG"
    fi
fi

# Embed flag in EXIF metadata
if [ -f "$PROFILE_IMG" ]; then
    if command -v exiftool &> /dev/null; then
        exiftool -Comment="$FLAG_2" \
                 -Artist="CTF User 2024" \
                 -Copyright="CyberLab CTF 2025" \
                 -Description="Profile picture for Mastodon CTF challenge" \
                 -overwrite_original \
                 "$PROFILE_IMG" 2>/dev/null

        log_info "✓ Flag embedded in image metadata"
        echo ""
        log_info "Verifying metadata..."
        exiftool "$PROFILE_IMG" | grep -E "(Comment|Artist|Copyright)" || true
        echo ""
    else
        log_warn "exiftool not found. Install with: sudo apt install exiftool"
        log_warn "You'll need to manually embed metadata in the image"
    fi
fi

# ============================================
# Manual Instructions
# ============================================

echo ""
log_info "════════════════════════════════════════"
log_info "  MANUAL PLANTING INSTRUCTIONS"
log_info "════════════════════════════════════════"
echo ""

echo "FLAG SUMMARY:"
echo "─────────────────────────────────────────"
echo "Challenge 1: $FLAG_1"
echo "Challenge 2: $FLAG_2"
echo "─────────────────────────────────────────"
echo ""

echo "STEP-BY-STEP INSTRUCTIONS:"
echo ""

echo "📋 CHALLENGE 1: The Hidden Toot"
echo "─────────────────────────────────────────"
echo "1. Go to: https://mastodon.cyberlab.local"
echo "2. Register account with username: ctf_user_2024"
echo "3. Verify email if required"
echo "4. Go to Edit Profile"
echo "5. In Bio field, add:"
echo "   'Welcome to CyberLab Mastodon! 🚀'"
echo "6. If HTML allowed in metadata fields, add a custom field:"
echo "   Field name: Website"
echo "   Field value: https://cyberlab.local/ctf"
echo "7. Create a public post (toot):"
echo "   'Welcome to CyberLab Mastodon! 🚀 #CTF #CyberLab'"
echo "8. Pin the toot to your profile"
echo ""
echo "   If you have access to Mastodon's admin panel:"
echo "   - Edit the user's profile page template"
echo "   - Add HTML comment: <!-- CTF Flag: $FLAG_1 -->"
echo ""

echo "🖼️  CHALLENGE 2: Profile Picture Secrets"
echo "─────────────────────────────────────────"
echo "1. Profile picture created at:"
echo "   $PROFILE_IMG"
echo "2. Upload this image to @ctf_user_2024's profile:"
echo "   - Log in to Mastodon as ctf_user_2024"
echo "   - Go to Edit Profile"
echo "   - Upload $PROFILE_IMG as profile picture"
echo "   - Save changes"
echo "3. Verify metadata preserved:"
echo "   - Download the profile picture from Mastodon"
echo "   - Run: exiftool downloaded_image.jpg"
echo "   - Check if Comment field contains the flag"
echo ""
echo "   If metadata is stripped by Mastodon:"
echo "   - Use the steganography method (see manual guide)"
echo "   - Or add flag to image alt-text if supported"
echo ""

echo "═══════════════════════════════════════════"
echo "  VERIFICATION"
echo "═══════════════════════════════════════════"
echo ""
echo "After planting, verify flags are accessible:"
echo ""
echo "Challenge 1:"
echo "  curl https://mastodon.cyberlab.local/@ctf_user_2024 | grep 'CTF Flag'"
echo "  (Or view page source in browser)"
echo ""
echo "Challenge 2:"
echo "  wget https://mastodon.cyberlab.local/@ctf_user_2024/avatar.jpg"
echo "  exiftool avatar.jpg | grep Comment"
echo ""

echo "═══════════════════════════════════════════"
echo "  NEXT STEPS"
echo "═══════════════════════════════════════════"
echo ""
echo "1. Complete manual planting steps above"
echo "2. Verify both flags are accessible"
echo "3. Register challenges in CTFd:"
echo "   ./mastodon/register-challenges.sh"
echo "4. Test challenges manually"
echo ""

echo "FILES CREATED:"
echo "  • Flags: $GENERATED_FLAGS_FILE"
echo "  • Profile Picture: $PROFILE_IMG"
echo ""

echo "For detailed instructions, see:"
echo "  ./mastodon/flag-planting-manual.md"
echo ""

# ============================================
# Optional: Mastodon API Integration
# ============================================

if [ -n "$MASTODON_ACCESS_TOKEN" ]; then
    echo ""
    log_info "Mastodon API token detected. Attempting automated planting..."
    echo ""

    MASTODON_URL="${MASTODON_URL:-https://mastodon.cyberlab.local}"

    # Create account (if API supports it)
    log_warn "Note: Account creation via API requires admin token"
    log_warn "Proceeding with manual instructions instead"
else
    log_info "Tip: Set MASTODON_ACCESS_TOKEN for API-based automation (optional)"
fi

echo ""
log_info "✓ Flag preparation complete!"
echo ""
