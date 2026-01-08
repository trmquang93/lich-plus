#!/bin/bash

# Deploy Lich Viet Landing Page to Vercel
# Usage: ./deploy.sh [--preview]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "Deploying Lich Viet Landing Page..."
echo ""

if [ "$1" = "--preview" ]; then
    echo "Deploying to preview..."
    vercel --yes
else
    echo "Deploying to production..."
    vercel --prod --yes
fi

echo ""
echo "Deployment complete!"
