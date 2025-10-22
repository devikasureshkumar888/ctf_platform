#!/bin/bash
# End-to-end test: Create, verify, and delete a test challenge

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/ctfd-client.sh"

echo "═══════════════════════════════════════"
echo "  End-to-End Test"
echo "═══════════════════════════════════════"
echo ""

# Check prerequisites
if ! check_prerequisites; then
    exit 1
fi

if ! test_connection; then
    exit 1
fi

echo ""
log_info "Creating test challenge..."

# Create challenge
PAYLOAD=$(jq -n '{
    name: "TEST - Delete Me",
    category: "Test",
    description: "This is a test challenge. It can be deleted.",
    value: 100,
    type: "standard",
    state: "hidden"
}')

CHALLENGE_ID=$(create_challenge "$PAYLOAD")

if [ -z "$CHALLENGE_ID" ]; then
    log_error "Failed to create challenge"
    exit 1
fi

echo ""
log_info "Adding test flag..."
FLAG="RONIN{test_flag_$(date +%s)}"
add_flag "$CHALLENGE_ID" "$FLAG"

echo ""
log_info "Adding test hints..."
add_hint "$CHALLENGE_ID" "This is a free hint" 0
add_hint "$CHALLENGE_ID" "This hint costs 25 points" 25

echo ""
log_info "Verifying challenge..."
list_challenges | grep "TEST - Delete Me"

echo ""
log_info "Challenge created successfully!"
log_info "Challenge ID: $CHALLENGE_ID"
log_info "Flag: $FLAG"
echo ""

read -p "Delete test challenge? (yes/no): " confirm

if [ "$confirm" = "yes" ]; then
    delete_challenge "$CHALLENGE_ID"
    echo ""
    log_info "Verifying deletion..."
    list_challenges
fi

echo ""
echo "═══════════════════════════════════════"
echo "  ✓ End-to-end test complete!"
echo "═══════════════════════════════════════"
