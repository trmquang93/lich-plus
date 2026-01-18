#!/bin/bash

# Deployment script for greeting generator backend
# This script deploys the Supabase Edge Function with proper configuration

set -e  # Exit on error

echo "===================================="
echo "Greeting Generator Backend Deployment"
echo "===================================="
echo ""

# Check if we're in the supabase directory
if [ ! -f "config.toml" ]; then
    echo "Error: Must run from supabase/ directory"
    exit 1
fi

# Step 1: Set Supabase access token
echo "Step 1: Configure Supabase access token"
echo "Please enter your Supabase access token (from https://supabase.com/dashboard/account/tokens):"
read -s SUPABASE_ACCESS_TOKEN
export SUPABASE_ACCESS_TOKEN
echo "✓ Token configured"
echo ""

# Step 2: Link to project
echo "Step 2: Linking to Supabase project..."
supabase link --project-ref jlqycjwtiabjsfldhzwt
echo "✓ Project linked"
echo ""

# Step 3: Set OpenRouter API key
echo "Step 3: Configure OpenRouter API key"
echo "Please enter your OpenRouter API key (from https://openrouter.ai/keys):"
read -s OPENROUTER_API_KEY
echo ""
echo "Setting OpenRouter API key as Supabase secret..."
supabase secrets set OPENROUTER_API_KEY="$OPENROUTER_API_KEY"
echo "✓ API key configured"
echo ""

# Step 4: Optionally set model
echo "Step 4: Configure AI model (optional)"
echo "Default model: anthropic/claude-3.5-haiku"
echo "Press Enter to use default, or enter a different model:"
read MODEL_CHOICE

if [ -n "$MODEL_CHOICE" ]; then
    echo "Setting model to: $MODEL_CHOICE"
    supabase secrets set OPENROUTER_MODEL="$MODEL_CHOICE"
    echo "✓ Model configured"
else
    echo "✓ Using default model"
fi
echo ""

# Step 5: Deploy function
echo "Step 5: Deploying function..."
supabase functions deploy generate-greeting --no-verify-jwt
echo "✓ Function deployed"
echo ""

# Step 6: Verify deployment
echo "Step 6: Verifying deployment..."
supabase functions list
echo ""

# Step 7: Test endpoint
echo "Step 7: Testing production endpoint..."
echo "Sending test request..."
curl -X POST https://jlqycjwtiabjsfldhzwt.supabase.co/functions/v1/generate-greeting \
  -H "Content-Type: application/json" \
  -d '{
    "recipientType": "parents",
    "tone": "formal",
    "occasion": "tet",
    "year": 2026
  }' | jq '.'

echo ""
echo "===================================="
echo "Deployment Complete!"
echo "===================================="
echo ""
echo "Function URL: https://jlqycjwtiabjsfldhzwt.supabase.co/functions/v1/generate-greeting"
echo ""
echo "Next steps:"
echo "1. The iOS app is already configured to use this endpoint"
echo "2. Build and run the app to test the greeting feature"
echo "3. Check function logs: supabase functions logs generate-greeting"
echo ""
