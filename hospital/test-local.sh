#!/bin/bash
# Test script - Generates flags and shows what would be planted
# Does NOT modify any files or databases

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/flag-generator.sh"

echo "════════════════════════════════════════"
echo "  Hospital Flag Generation Test"
echo "════════════════════════════════════════"
echo ""
echo "This script generates flags WITHOUT planting them."
echo "Use this to test before running on actual Hospital system."
echo ""

# Generate flags for example challenges
echo "Generated flags (format: CYBERLABFLAG{...}):"
echo ""

FLAG_1=$(generate_challenge_flag "hospital" "hospital_example_1")
echo "Challenge 1: hospital_example_1"
echo "  Flag: $FLAG_1"
echo "  Would plant in: Database (patients table, id=999)"
echo ""

FLAG_2=$(generate_challenge_flag "hospital" "hospital_example_2")
echo "Challenge 2: hospital_example_2"
echo "  Flag: $FLAG_2"
echo "  Would plant in: /var/www/hospital/config.php"
echo ""

echo "════════════════════════════════════════"
echo "To actually plant flags, run:"
echo "  sudo ./hospital/plant-flags.sh"
echo "════════════════════════════════════════"
