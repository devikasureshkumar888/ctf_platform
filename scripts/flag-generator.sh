#!/bin/bash
FLAG_PREFIX="CYBERLABFLAG"

generate_random_flag() {
    local length="${1:-16}"
    local random_str=$(cat /dev/urandom | tr -dc 'a-z0-9_' | fold -w "$length" | head -n 1)
    echo "${FLAG_PREFIX}{${random_str}}"
}

generate_seeded_flag() {
    local seed="$1"
    local hash=$(echo -n "$seed" | sha256sum | cut -d' ' -f1 | cut -c1-16)
    echo "${FLAG_PREFIX}{${hash}}"
}

generate_challenge_flag() {
    local system="$1"
    local challenge_id="$2"
    local seed="${system}_${challenge_id}_ctf2025"
    generate_seeded_flag "$seed"
}
validate_flag() {
    local flag="$1"
    if [[ $flag =~ ^${FLAG_PREFIX}\{[a-z0-9_]+\}$ ]]; then
        return 0
    else
        return 1
    fi
}

show_flag() {
    local label="$1"
    local flag="$2"
    echo "  $label: $flag"
}

export -f generate_random_flag
export -f generate_seeded_flag
export -f generate_challenge_flag
export -f validate_flag
export -f show_flag
