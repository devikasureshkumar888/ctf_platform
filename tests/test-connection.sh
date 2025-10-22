#!/bin/bash
# Test CTFd API connection

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/ctfd-client.sh"

echo "═══════════════════════════════════════"
echo "  CTFd Connection Test"
echo "═══════════════════════════════════════"
echo ""

# Check prerequisites
if ! check_prerequisites; then
    echo ""
    echo "Fix the errors above and try again"
    exit 1
fi

echo ""

# Test connection
if ! test_connection; then
    echo ""
    echo "Fix the connection issues and try again"
    exit 1
fi

echo ""
log_info "Listing existing challenges:"
echo ""
list_challenges

echo ""
echo "═══════════════════════════════════════"
echo "  ✓ Connection test successful!"
echo "═══════════════════════════════════════"
