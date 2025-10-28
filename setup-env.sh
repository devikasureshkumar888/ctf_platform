#!/bin/bash
# Helper script to easily load environment variables
# Usage: source setup-env.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/ctf_platform/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "ERROR: .env file not found at $ENV_FILE"
    echo "Please create it first: cp ctf_platform/.env.example ctf_platform/.env"
    return 1 2>/dev/null || exit 1
fi

# Export all variables from .env file (skip comments and empty lines)
set -a
source "$ENV_FILE"
set +a

echo "✓ Environment variables loaded from: $ENV_FILE"
echo ""
echo "Configuration:"
echo "  CTFD_URL: $CTFD_URL"
echo "  CTFD_TOKEN: ${CTFD_TOKEN:0:20}..."
echo "  MASTODON_URL: $MASTODON_URL"
echo "  HOSPITAL_URL: $HOSPITAL_URL"
echo "  FLAG_PREFIX: $FLAG_PREFIX"
echo "  CTF_YEAR: $CTF_YEAR"
echo ""
echo "You can now run scripts like:"
echo "  ./tests/test-connection.sh"
echo "  ./hospital/test-local.sh"
echo "  ./ctf_platform/mastodon/test-local.sh"
