# Supabase Greeting Generator - Deployment Guide

This guide covers local testing, deployment, and iOS integration for the greeting generator Edge Function.

## Prerequisites

1. **Supabase CLI** - Already installed
2. **OpenRouter API Key** - Get one from https://openrouter.ai/keys
3. **Supabase Project**:
   - Project ID: `jlqycjwtiabjsfldhzwt`
   - Function URL: `https://jlqycjwtiabjsfldhzwt.supabase.co/functions/v1/generate-greeting`

## Step 1: Configure Local Environment

1. Navigate to the supabase directory:
```bash
cd /Volumes/T7/Projects/new-ios/lich-plus/supabase
```

2. Edit `.env.local` and add your OpenRouter API key:
```bash
OPENROUTER_API_KEY=sk-or-v1-YOUR-ACTUAL-KEY-HERE
OPENROUTER_MODEL=anthropic/claude-3.5-haiku
```

## Step 2: Local Testing

1. Start the local Supabase function server:
```bash
supabase functions serve generate-greeting --env-file .env.local
```

2. In a new terminal, test with curl:

**Test Vietnamese greeting:**
```bash
curl -X POST http://localhost:54321/functions/v1/generate-greeting \
  -H "Content-Type: application/json" \
  -d '{
    "recipientType": "parents",
    "tone": "formal",
    "occasion": "tet",
    "year": 2026,
    "language": "vi"
  }'
```

**Test English greeting:**
```bash
curl -X POST http://localhost:54321/functions/v1/generate-greeting \
  -H "Content-Type: application/json" \
  -d '{
    "recipientType": "friends",
    "tone": "informal",
    "occasion": "tet",
    "year": 2026,
    "language": "en",
    "recipientName": "John"
  }'
```

**Expected response:**
```json
{
  "greeting": "Con kính chúc Bố Mẹ năm Bính Ngọ..."
}
```

**Test validation error:**
```bash
curl -X POST http://localhost:54321/functions/v1/generate-greeting \
  -H "Content-Type: application/json" \
  -d '{
    "recipientType": "parents"
  }'
```

## Step 3: Deploy to Supabase

1. Link to your Supabase project (first time only):
```bash
supabase link --project-ref jlqycjwtiabjsfldhzwt
```

You may need to enter your Supabase access token. Get it from:
https://supabase.com/dashboard/account/tokens

2. Set the OpenRouter API key as a secret:
```bash
supabase secrets set OPENROUTER_API_KEY=sk-or-v1-YOUR-ACTUAL-KEY-HERE
```

3. (Optional) Set a specific model:
```bash
supabase secrets set OPENROUTER_MODEL=anthropic/claude-3.5-haiku
```

4. Deploy the function:
```bash
supabase functions deploy generate-greeting
```

5. Verify deployment:
```bash
supabase functions list
```

You should see `generate-greeting` in the list.

## Step 4: Test Production Endpoint

Test the deployed function:

```bash
curl -X POST https://jlqycjwtiabjsfldhzwt.supabase.co/functions/v1/generate-greeting \
  -H "Content-Type: application/json" \
  -d '{
    "recipientType": "parents",
    "tone": "formal",
    "occasion": "tet",
    "year": 2026
  }'
```

## Step 5: Update iOS App

The iOS app is already configured to use a backend URL. You just need to set it.

**Option A: Environment Variable (Recommended)**

1. In Xcode, edit the scheme (Product > Scheme > Edit Scheme)
2. Go to Run > Arguments > Environment Variables
3. Add:
   - Name: `GREETING_API_URL`
   - Value: `https://jlqycjwtiabjsfldhzwt.supabase.co/functions/v1/generate-greeting`

**Option B: Hardcode in Code**

Edit `lich-plus/lich-plus/Services/GreetingService.swift` and update the `backendURL`:

```swift
static var backendURL: URL? {
    if let urlString = ProcessInfo.processInfo.environment["GREETING_API_URL"],
       let url = URL(string: urlString) {
        return url
    }
    // Fallback to production URL
    return URL(string: "https://jlqycjwtiabjsfldhzwt.supabase.co/functions/v1/generate-greeting")
}
```

## Step 6: Test in iOS App

1. Build and run the iOS app
2. Navigate to the greeting generator feature
3. Select recipient type, tone, and year
4. Tap "Generate" and verify the greeting is generated

## Troubleshooting

### Local testing fails

**Error: "OPENROUTER_API_KEY not configured"**
- Check that `.env.local` exists and has the correct API key
- Verify you're using `--env-file .env.local` flag

**Error: "OpenRouter API error (401)"**
- Your API key is invalid or expired
- Get a new key from https://openrouter.ai/keys

**Error: "Connection refused"**
- Make sure `supabase functions serve` is running
- Check the port is 54321

### Deployment fails

**Error: "Project not linked"**
- Run `supabase link --project-ref jlqycjwtiabjsfldhzwt`
- Enter your Supabase access token when prompted

**Error: "Unauthorized"**
- Get a new access token from https://supabase.com/dashboard/account/tokens
- Run `supabase link` again

### Production endpoint fails

**Error: "CONFIG_ERROR"**
- The secret `OPENROUTER_API_KEY` is not set
- Run `supabase secrets set OPENROUTER_API_KEY=...`

**Error: "API_ERROR"**
- OpenRouter API is down or your key is invalid
- Check https://openrouter.ai/status

### iOS app doesn't generate greetings

**Check the URL is set:**
```swift
print("Greeting API URL:", GreetingServiceConfig.backendURL ?? "not set")
```

**Check network errors in Xcode console:**
- Look for URLSession errors
- Verify the iOS app can reach the Supabase endpoint

## Changing Models

To switch to a different model after deployment:

```bash
# Use GPT-4o-mini instead
supabase secrets set OPENROUTER_MODEL=openai/gpt-4o-mini

# Use Claude 3.5 Sonnet for higher quality
supabase secrets set OPENROUTER_MODEL=anthropic/claude-3.5-sonnet
```

See available models at: https://openrouter.ai/models

## Monitoring and Logs

View function logs:
```bash
supabase functions logs generate-greeting
```

View recent invocations:
```bash
supabase functions logs generate-greeting --tail
```

## Cost Optimization

**Current model (claude-3.5-haiku):**
- ~$0.001 per greeting
- 10,000 greetings = ~$10/month

**To reduce costs further:**
```bash
supabase secrets set OPENROUTER_MODEL=openai/gpt-4o-mini
```
- ~$0.0003 per greeting
- 10,000 greetings = ~$3/month

## Security Notes

- API key is stored as a Supabase secret (never in code)
- CORS is currently set to `*` (all origins)
- For production, consider restricting CORS to your app's domain
- No rate limiting is implemented yet (can add if needed)

## Next Steps

1. Add rate limiting to prevent abuse
2. Add request logging for analytics
3. Implement caching for common greetings
4. Add support for custom greeting templates
5. Restrict CORS to specific origins
