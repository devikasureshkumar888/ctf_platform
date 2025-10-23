#!/bin/bash
# Deploy All CTF Challenges
# Registers all challenges from all chapters in CTFd

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load shared scripts
source "$SCRIPT_DIR/ctfd-client.sh"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  CyberLab CTF - Deploy All Challenges"
echo "═══════════════════════════════════════════════════════"
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

echo ""
log_info "CTFd URL: $CTFD_URL"
log_info "Deploying all chapters..."
echo ""

# Track statistics
TOTAL_CHALLENGES=0
TOTAL_POINTS=0
FAILED_CHAPTERS=0

# ═══════════════════════════════════════════════════════
# Chapter 1: Mastodon
# ═══════════════════════════════════════════════════════

log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "  Chapter 1: Mastodon Social Network"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$PROJECT_ROOT/mastodon"

if [ ! -f ".generated-flags.txt" ]; then
    log_error "Mastodon flags not generated!"
    log_error "Run: cd mastodon && ./plant-flags-web.sh"
    ((FAILED_CHAPTERS++))
else
    if ./register-challenges.sh; then
        log_info "✓ Mastodon challenges deployed successfully"
        ((TOTAL_CHALLENGES += 2))
        ((TOTAL_POINTS += 300))
    else
        log_error "✗ Mastodon deployment failed"
        ((FAILED_CHAPTERS++))
    fi
fi

echo ""
echo ""

# ═══════════════════════════════════════════════════════
# Chapter 2: Hospital
# ═══════════════════════════════════════════════════════

log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "  Chapter 2: Hospital Management System"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$PROJECT_ROOT/hospital"

if [ ! -f ".generated-flags.txt" ]; then
    log_warn "Hospital flags not generated!"
    log_warn "Run: cd hospital && ./test-local.sh (to preview)"
    log_warn "Then: sudo ./plant-flags.sh (to actually plant)"
    log_warn "Skipping Hospital chapter..."
    ((FAILED_CHAPTERS++))
else
    if ./register-challenges.sh; then
        log_info "✓ Hospital challenges deployed successfully"
        ((TOTAL_CHALLENGES += 2))
        ((TOTAL_POINTS += 350))
    else
        log_error "✗ Hospital deployment failed"
        ((FAILED_CHAPTERS++))
    fi
fi

cd "$PROJECT_ROOT"

# ═══════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════

echo ""
echo ""
echo "═══════════════════════════════════════════════════════"
echo "  DEPLOYMENT SUMMARY"
echo "═══════════════════════════════════════════════════════"
echo ""

if [ $FAILED_CHAPTERS -eq 0 ]; then
    log_info "✓ All chapters deployed successfully!"
else
    log_warn "⚠ $FAILED_CHAPTERS chapter(s) failed to deploy"
fi

echo ""
echo "Statistics:"
echo "  • Total Challenges: $TOTAL_CHALLENGES"
echo "  • Total Points: $TOTAL_POINTS"
echo "  • Chapters Deployed: $((2 - FAILED_CHAPTERS))/2"
echo ""
echo "CTFd Dashboard: $CTFD_URL/admin"
echo "Challenges Page: $CTFD_URL/challenges"
echo ""

if [ $TOTAL_CHALLENGES -gt 0 ]; then
    echo "═══════════════════════════════════════════════════════"
    echo "  NEXT STEPS"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    echo "1. Verify challenges in CTFd:"
    echo "   • Log in to $CTFD_URL/admin"
    echo "   • Go to Challenges section"
    echo "   • Check all $TOTAL_CHALLENGES challenges are listed"
    echo ""
    echo "2. Test each challenge:"
    echo "   • Create a test user account"
    echo "   • Try to solve each challenge"
    echo "   • Verify flags work when submitted"
    echo ""
    echo "3. Run verification script:"
    echo "   ./scripts/verify-challenges.sh"
    echo ""
    echo "4. Configure CTFd settings:"
    echo "   • Set CTF start/end times"
    echo "   • Configure user registration"
    echo "   • Customize theme/branding"
    echo "   • Set up teams (if needed)"
    echo ""
fi

if [ $FAILED_CHAPTERS -gt 0 ]; then
    echo "═══════════════════════════════════════════════════════"
    echo "  TROUBLESHOOTING"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    echo "If deployment failed, check:"
    echo ""
    echo "1. Flags generated?"
    echo "   • Mastodon: ./mastodon/plant-flags-web.sh"
    echo "   • Hospital: sudo ./hospital/plant-flags.sh"
    echo ""
    echo "2. CTFd accessible?"
    echo "   • Test: curl $CTFD_URL"
    echo "   • Check API token: echo \$CTFD_TOKEN"
    echo ""
    echo "3. Review error messages above"
    echo ""
    echo "For more help, see: docs/troubleshooting.md"
    echo ""
fi

echo "═══════════════════════════════════════════════════════"
echo ""

# Exit with error if any chapters failed
if [ $FAILED_CHAPTERS -gt 0 ]; then
    exit 1
fi

exit 0
