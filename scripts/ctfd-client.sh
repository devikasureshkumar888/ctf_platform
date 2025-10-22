#!/bin/bash
# CTFd API Client
# Wrapper around CTFd REST API with error handling

set -e

# Configuration from environment
CTFD_URL="${CTFD_URL:-http://localhost:8000}"
CTFD_API="${CTFD_URL}/api/v1"
CTFD_TOKEN="${CTFD_TOKEN}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    local errors=0
    
    # Check jq
    if ! command -v jq &> /dev/null; then
        log_error "jq is not installed"
        echo "  Install with: sudo apt install jq"
        ((errors++))
    fi

    # Check curl
    if ! command -v curl &> /dev/null; then
        log_error "curl is not installed"
        echo "  Install with: sudo apt install curl"
        ((errors++))
    fi

    # Check token
    if [ -z "$CTFD_TOKEN" ]; then
        log_error "CTFD_TOKEN environment variable not set"
        echo "  Set it with: export CTFD_TOKEN='your-token'"
        ((errors++))
    fi
    
    # Check URL
    if [ -z "$CTFD_URL" ]; then
        log_error "CTFD_URL environment variable not set"
        echo "  Set it with: export CTFD_URL='http://your-ip:8000'"
        ((errors++))
    fi

    if [ $errors -gt 0 ]; then
        return 1
    fi
    
    log_info "Prerequisites check passed"
    return 0
}

# Test connection to CTFd
test_connection() {
    log_info "Testing connection to CTFd..."
    log_debug "URL: $CTFD_URL"
    
    response=$(curl -s -w "\n%{http_code}" \
        -H "Authorization: Token ${CTFD_TOKEN}" \
        -H "Content-Type: application/json" \
        "$CTFD_API/challenges" 2>/dev/null)
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "200" ]; then
        log_info "✓ Connection successful"
        return 0
    elif [ "$http_code" = "403" ]; then
        log_error "✗ Authentication failed (HTTP 403)"
        log_error "Check your API token"
        return 1
    elif [ "$http_code" = "000" ]; then
        log_error "✗ Cannot reach CTFd server"
        log_error "Check if CTFd is running and URL is correct"
        return 1
    else
        log_error "✗ Connection failed (HTTP $http_code)"
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
        return 1
    fi
}

# Create a challenge
# Usage: create_challenge <json_payload>
# Returns: challenge_id
create_challenge() {
    local payload="$1"
    
    log_info "Creating challenge..."
    
    response=$(curl -s -w "\n%{http_code}" \
        -X POST "$CTFD_API/challenges" \
        -H "Authorization: Token ${CTFD_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "$payload" 2>/dev/null)
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "200" ]; then
        challenge_id=$(echo "$body" | jq -r '.data.id')
        if [ "$challenge_id" != "null" ] && [ -n "$challenge_id" ]; then
            log_info "✓ Challenge created (ID: $challenge_id)"
            echo "$challenge_id"
            return 0
        fi
    fi
    
    log_error "✗ Failed to create challenge (HTTP $http_code)"
    echo "$body" | jq '.' 2>/dev/null || echo "$body"
    return 1
}

# Add flag to challenge
# Usage: add_flag <challenge_id> <flag_content> [type]
add_flag() {
    local challenge_id="$1"
    local flag_content="$2"
    local flag_type="${3:-static}"
    
    log_info "Adding flag to challenge $challenge_id..."
    
    payload=$(jq -n \
        --arg cid "$challenge_id" \
        --arg content "$flag_content" \
        --arg type "$flag_type" \
        '{
            challenge_id: ($cid | tonumber),
            content: $content,
            type: $type
        }')
    
    response=$(curl -s -w "\n%{http_code}" \
        -X POST "$CTFD_API/flags" \
        -H "Authorization: Token ${CTFD_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "$payload" 2>/dev/null)
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "200" ]; then
        flag_id=$(echo "$body" | jq -r '.data.id')
        log_info "✓ Flag added (ID: $flag_id)"
        echo "$flag_id"
        return 0
    else
        log_error "✗ Failed to add flag (HTTP $http_code)"
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
        return 1
    fi
}

# Add hint to challenge
# Usage: add_hint <challenge_id> <hint_text> [cost]
add_hint() {
    local challenge_id="$1"
    local hint_text="$2"
    local cost="${3:-0}"
    
    log_info "Adding hint to challenge $challenge_id (cost: $cost points)..."
    
    payload=$(jq -n \
        --arg cid "$challenge_id" \
        --arg content "$hint_text" \
        --arg cost "$cost" \
        '{
            challenge_id: ($cid | tonumber),
            content: $content,
            cost: ($cost | tonumber)
        }')
    
    response=$(curl -s -w "\n%{http_code}" \
        -X POST "$CTFD_API/hints" \
        -H "Authorization: Token ${CTFD_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "$payload" 2>/dev/null)
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "200" ]; then
        hint_id=$(echo "$body" | jq -r '.data.id')
        log_info "✓ Hint added (ID: $hint_id)"
        echo "$hint_id"
        return 0
    else
        log_error "✗ Failed to add hint (HTTP $http_code)"
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
        return 1
    fi
}

# List all challenges
list_challenges() {
    log_info "Fetching challenges from CTFd..."
    
    response=$(curl -s -w "\n%{http_code}" \
        -H "Authorization: Token ${CTFD_TOKEN}" \
        -H "Content-Type: application/json" \
        "$CTFD_API/challenges" 2>/dev/null)
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "200" ]; then
        count=$(echo "$body" | jq -r '.data | length')
        log_info "Found $count challenges"
        echo ""
        printf "%-5s %-40s %-30s %s\n" "ID" "NAME" "CATEGORY" "POINTS"
        printf "%-5s %-40s %-30s %s\n" "----" "----------------------------------------" "------------------------------" "------"
        echo "$body" | jq -r '.data[] | "\(.id)\t\(.name)\t\(.category)\t\(.value)"' | \
            while IFS=$'\t' read -r id name category value; do
                printf "%-5s %-40s %-30s %s\n" "$id" "$name" "$category" "$value"
            done
        return 0
    else
        log_error "✗ Failed to list challenges (HTTP $http_code)"
        return 1
    fi
}

# Delete challenge
# Usage: delete_challenge <challenge_id>
delete_challenge() {
    local challenge_id="$1"
    
    log_warn "Deleting challenge $challenge_id..."
    
    response=$(curl -s -w "\n%{http_code}" \
        -X DELETE "$CTFD_API/challenges/$challenge_id" \
        -H "Authorization: Token ${CTFD_TOKEN}" \
        -H "Content-Type: application/json" 2>/dev/null)
    
    http_code=$(echo "$response" | tail -n1)
    
    if [ "$http_code" = "200" ]; then
        log_info "✓ Challenge deleted"
        return 0
    else
        log_error "✗ Failed to delete challenge (HTTP $http_code)"
        return 1
    fi
}

# Get challenge details
get_challenge() {
    local challenge_id="$1"
    
    response=$(curl -s -w "\n%{http_code}" \
        -H "Authorization: Token ${CTFD_TOKEN}" \
        -H "Content-Type: application/json" \
        "$CTFD_API/challenges/$challenge_id" 2>/dev/null)
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "200" ]; then
        echo "$body" | jq '.data'
        return 0
    else
        log_error "✗ Failed to get challenge (HTTP $http_code)"
        return 1
    fi
}

# Export functions so they can be sourced
export -f check_prerequisites
export -f test_connection
export -f create_challenge
export -f add_flag
export -f add_hint
export -f list_challenges
export -f delete_challenge
export -f get_challenge
export -f log_info
export -f log_warn
export -f log_error
export -f log_debug
