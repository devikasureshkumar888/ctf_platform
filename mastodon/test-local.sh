#!/bin/bash
# Test script - Generates flags and shows what would be planted
# Does NOT modify any files or databases

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/flag-generator.sh"

echo "════════════════════════════════════════"
echo "  Mastodon Flag Generation Test"
echo "════════════════════════════════════════"
echo ""
echo "This script generates flags WITHOUT planting them."
echo "Use this to test before planting on actual Mastodon instance."
echo ""

# Generate flags for Mastodon challenges
echo "Generated flags (format: CYBERLABFLAG{...}):"
echo ""

FLAG_1=$(generate_challenge_flag "mastodon" "mastodon_hidden_toot")
echo "Challenge 1: mastodon_hidden_toot"
echo "  Flag: $FLAG_1"
echo "  Would plant in: User @ctf_user_2024's toot as HTML comment"
echo ""

FLAG_2=$(generate_challenge_flag "mastodon" "mastodon_profile_secrets")
echo "Challenge 2: mastodon_profile_secrets"
echo "  Flag: $FLAG_2"
echo "  Would plant in: Profile picture EXIF metadata"
echo ""

echo "════════════════════════════════════════"
echo "To actually plant flags, use:"
echo "  ./mastodon/plant-flags-web.sh"
echo "  OR follow manual instructions in:"
echo "  ./mastodon/flag-planting-manual.md"
echo "════════════════════════════════════════"
