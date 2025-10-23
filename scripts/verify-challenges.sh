#!/bin/bash
# Verify CTF Challenges
# Tests that all challenges are accessible and flags can be found

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load shared scripts
source "$SCRIPT_DIR/ctfd-client.sh"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  CyberLab CTF - Challenge Verification"
echo "═══════════════════════════════════════════════════════"
echo ""

log_info "This script verifies that challenges are accessible"
log_info "and flags can be found in the target systems."
echo ""

# Configuration
MASTODON_URL="${MASTODON_URL:-https://mastodon.cyberlab.local}"
HOSPITAL_URL="${HOSPITAL_URL:-https://hospital.cyberlab.local}"

# Track results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Helper function to run test
run_test() {
    local test_name="$1"
    local test_command="$2"

    ((TOTAL_TESTS++))
    echo ""
    log_info "Testing: $test_name"

    if eval "$test_command"; then
        log_info "  ✓ PASSED"
        ((PASSED_TESTS++))
        return 0
    else
        log_error "  ✗ FAILED"
        ((FAILED_TESTS++))
        return 1
    fi
}

# ═══════════════════════════════════════════════════════
# Test 1: CTFd Connectivity
# ═══════════════════════════════════════════════════════

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  CTFd Platform Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_test "CTFd API Connection" "test_connection"

run_test "CTFd Challenges Listed" "
    challenge_count=\$(curl -s -H 'Authorization: Token ${CTFD_TOKEN}' \
        '${CTFD_URL}/api/v1/challenges' | jq '.data | length')
    [ \"\$challenge_count\" -ge 1 ]
"

# ═══════════════════════════════════════════════════════
# Test 2: Mastodon Challenges
# ═══════════════════════════════════════════════════════

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Mastodon Chapter Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if Mastodon is accessible
run_test "Mastodon Instance Accessible" "
    response=\$(curl -s -o /dev/null -w '%{http_code}' '$MASTODON_URL' 2>/dev/null || echo '000')
    [ \"\$response\" = \"200\" ] || [ \"\$response\" = \"302\" ]
"

# Check if CTF user profile exists
run_test "Mastodon CTF User Profile Exists" "
    response=\$(curl -s -o /dev/null -w '%{http_code}' '$MASTODON_URL/@ctf_user_2024' 2>/dev/null || echo '000')
    [ \"\$response\" = \"200\" ]
"

# Check for flag in HTML source (Challenge 1)
if [ -f "$PROJECT_ROOT/mastodon/.generated-flags.txt" ]; then
    FLAG_1=$(grep "mastodon_hidden_toot" "$PROJECT_ROOT/mastodon/.generated-flags.txt" | cut -d'=' -f2)

    run_test "Mastodon Challenge 1 - Flag in Page Source" "
        page_source=\$(curl -s '$MASTODON_URL/@ctf_user_2024' 2>/dev/null)
        echo \"\$page_source\" | grep -q '$FLAG_1' || echo \"\$page_source\" | grep -q 'CTF Flag'
    "
else
    log_warn "Skipping Mastodon flag verification (flags not generated)"
fi

# Check if profile picture exists (Challenge 2)
run_test "Mastodon Challenge 2 - Profile Picture Exists" "
    response=\$(curl -s -o /dev/null -w '%{http_code}' '$MASTODON_URL/@ctf_user_2024/avatar.jpg' 2>/dev/null || echo '000')
    [ \"\$response\" = \"200\" ] || [ \"\$response\" = \"302\" ]
"

# ═══════════════════════════════════════════════════════
# Test 3: Hospital Challenges
# ═══════════════════════════════════════════════════════

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Hospital Chapter Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if Hospital is accessible
run_test "Hospital Instance Accessible" "
    response=\$(curl -s -o /dev/null -w '%{http_code}' '$HOSPITAL_URL' 2>/dev/null || echo '000')
    [ \"\$response\" = \"200\" ] || [ \"\$response\" = \"302\" ]
"

# Check for patient 999 endpoint (Challenge 1)
run_test "Hospital Challenge 1 - Patient 999 Endpoint Exists" "
    response=\$(curl -s -o /dev/null -w '%{http_code}' '$HOSPITAL_URL/patients/999' 2>/dev/null || echo '000')
    [ \"\$response\" = \"200\" ] || [ \"\$response\" = \"302\" ] || {
        # Try API endpoint
        response=\$(curl -s -o /dev/null -w '%{http_code}' '$HOSPITAL_URL/api/patients/999' 2>/dev/null || echo '000')
        [ \"\$response\" = \"200\" ]
    }
"

# Check if flag exists in patient 999 data
if [ -f "$PROJECT_ROOT/hospital/.generated-flags.txt" ]; then
    FLAG_H1=$(grep "hospital_patient_records" "$PROJECT_ROOT/hospital/.generated-flags.txt" | cut -d'=' -f2)

    run_test "Hospital Challenge 1 - Flag in Patient Data" "
        patient_data=\$(curl -s '$HOSPITAL_URL/patients/999' 2>/dev/null)
        echo \"\$patient_data\" | grep -q '$FLAG_H1' || {
            # Try API endpoint
            patient_data=\$(curl -s '$HOSPITAL_URL/api/patients/999' 2>/dev/null)
            echo \"\$patient_data\" | grep -q '$FLAG_H1'
        }
    "
else
    log_warn "Skipping Hospital flag verification (flags not generated)"
fi

# Check for admin panel endpoint (Challenge 2)
run_test "Hospital Challenge 2 - Admin Panel Endpoint Exists" "
    response=\$(curl -s -o /dev/null -w '%{http_code}' '$HOSPITAL_URL/ctf_admin_panel_secret_2024' 2>/dev/null || echo '000')
    [ \"\$response\" = \"200\" ]
"

# Check if flag exists in admin panel
if [ -f "$PROJECT_ROOT/hospital/.generated-flags.txt" ]; then
    FLAG_H2=$(grep "hospital_admin_dashboard" "$PROJECT_ROOT/hospital/.generated-flags.txt" | cut -d'=' -f2)

    run_test "Hospital Challenge 2 - Flag in Admin Panel" "
        admin_page=\$(curl -s '$HOSPITAL_URL/ctf_admin_panel_secret_2024' 2>/dev/null)
        echo \"\$admin_page\" | grep -q '$FLAG_H2'
    "
fi

# ═══════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════

echo ""
echo ""
echo "═══════════════════════════════════════════════════════"
echo "  VERIFICATION SUMMARY"
echo "═══════════════════════════════════════════════════════"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    log_info "✓ All tests passed! ($PASSED_TESTS/$TOTAL_TESTS)"
    echo ""
    echo "Your CTF challenges are ready to go! 🎉"
else
    log_warn "⚠ Some tests failed"
    echo ""
    echo "Results:"
    echo "  • Passed: $PASSED_TESTS"
    echo "  • Failed: $FAILED_TESTS"
    echo "  • Total:  $TOTAL_TESTS"
fi

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  NEXT STEPS"
echo "═══════════════════════════════════════════════════════"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo "Everything looks good! Now:"
    echo ""
    echo "1. Test manually with a browser"
    echo "   • Visit $MASTODON_URL/@ctf_user_2024"
    echo "   • Visit $HOSPITAL_URL"
    echo ""
    echo "2. Create a test user in CTFd"
    echo "   • Register at $CTFD_URL/register"
    echo "   • Try to solve each challenge"
    echo "   • Submit flags to verify they work"
    echo ""
    echo "3. Configure CTFd for production"
    echo "   • Set start/end times"
    echo "   • Configure registration settings"
    echo "   • Customize theme"
    echo ""
else
    echo "Some tests failed. Here's what to check:"
    echo ""

    if curl -s "$MASTODON_URL" >/dev/null 2>&1; then
        :
    else
        echo "❌ Mastodon not accessible:"
        echo "   • Check if Mastodon is running"
        echo "   • Verify URL: $MASTODON_URL"
        echo "   • Check network connectivity"
        echo ""
    fi

    if curl -s "$HOSPITAL_URL" >/dev/null 2>&1; then
        :
    else
        echo "❌ Hospital not accessible:"
        echo "   • Check if Hospital is running"
        echo "   • Verify URL: $HOSPITAL_URL"
        echo "   • Check network connectivity"
        echo ""
    fi

    if [ ! -f "$PROJECT_ROOT/mastodon/.generated-flags.txt" ]; then
        echo "❌ Mastodon flags not generated:"
        echo "   • Run: cd mastodon && ./plant-flags-web.sh"
        echo ""
    fi

    if [ ! -f "$PROJECT_ROOT/hospital/.generated-flags.txt" ]; then
        echo "❌ Hospital flags not generated:"
        echo "   • Run: cd hospital && sudo ./plant-flags.sh"
        echo "   • Or follow manual instructions in flag-planting-manual.md"
        echo ""
    fi

    echo "For detailed troubleshooting, see: docs/troubleshooting.md"
    echo ""
fi

echo "═══════════════════════════════════════════════════════"
echo ""

# Exit with error if any tests failed
if [ $FAILED_TESTS -gt 0 ]; then
    exit 1
fi

exit 0
