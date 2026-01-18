# Supabase Backend - Greeting Generator

This directory contains the Supabase Edge Function that powers the AI-generated Vietnamese Tet greetings feature in the Lịch Việt iOS app.

## Overview

The greeting generator is a serverless Edge Function that:
- Accepts greeting parameters from the iOS app
- Calculates Vietnamese zodiac (Can-Chi) for the specified year
- Calls OpenRouter API to generate culturally appropriate greetings
- Returns personalized greetings in Vietnamese or English

## Architecture

```
iOS App (Swift)
    ↓
    ↓ HTTPS POST /functions/v1/generate-greeting
    ↓
Supabase Edge Function (Deno/TypeScript)
    ↓
    ↓ OpenRouter API (chat/completions)
    ↓
AI Model (Claude 3.5 Haiku / GPT-4o-mini / etc.)
    ↓
    ↓ Generated greeting
    ↓
iOS App displays greeting
```

## Project Structure

```
supabase/
├── config.toml                          # Supabase project configuration
├── .env.local                           # Local environment variables (gitignored)
├── .gitignore                           # Ignore sensitive files
├── README.md                            # This file
├── DEPLOYMENT.md                        # Deployment guide
└── functions/
    └── generate-greeting/
        └── index.ts                     # Edge Function implementation
```

## Key Features

### 1. Vietnamese Zodiac Calculation
Matches the iOS app's `CanChiCalculator.swift` implementation:
- Reference year: 1900 (Canh Ty)
- Calculates Can (Heavenly Stem) and Chi (Earthly Branch)
- Returns zodiac animal in English

### 2. AI Model Integration via OpenRouter
- Uses OpenRouter API for flexibility
- Supports multiple models: Claude, GPT-4, etc.
- Configurable via environment variable
- Default: `anthropic/claude-3.5-haiku`

### 3. Bilingual Support
- Vietnamese greetings (default)
- English greetings
- Culturally appropriate for each language

### 4. Recipient-Specific Greetings
- Parents/Grandparents: Formal, respectful
- Friends/Colleagues: Warm, friendly
- Children: Encouraging, loving

### 5. Error Handling
- Request validation
- API error handling
- Configuration error detection
- Meaningful error codes

### 6. CORS Support
- Allows iOS app to call the function
- Supports preflight OPTIONS requests

## API Specification

### Endpoint
```
POST https://jlqycjwtiabjsfldhzwt.supabase.co/functions/v1/generate-greeting
```

### Request Body
```json
{
  "recipientType": "parents",
  "tone": "formal",
  "occasion": "tet",
  "recipientName": "Bố Mẹ",
  "year": 2026,
  "language": "vi"
}
```

**Parameters:**
- `recipientType` (required): string - "parents", "friends", "children", etc.
- `tone` (required): string - "formal" or "informal"
- `occasion` (required): string - "tet" or other occasions
- `year` (required): number - Year for zodiac calculation (1900-2100)
- `recipientName` (optional): string - Name of the recipient
- `language` (optional): string - "vi" (default) or "en"

### Response (Success)
```json
{
  "greeting": "Con kính chúc Bố Mẹ năm Bính Ngọ dồi dào sức khỏe, hạnh phúc tràn đầy..."
}
```

### Response (Error)
```json
{
  "error": "year is required and must be a number",
  "code": "VALIDATION_ERROR"
}
```

**Error Codes:**
- `VALIDATION_ERROR` - Invalid request parameters
- `CONFIG_ERROR` - Missing API key configuration
- `API_ERROR` - OpenRouter API error
- `GENERATION_ERROR` - Failed to generate greeting

## Environment Variables

### Required
- `OPENROUTER_API_KEY` - Your OpenRouter API key

### Optional
- `OPENROUTER_MODEL` - Model to use (default: `anthropic/claude-3.5-haiku`)

## Getting Started

See [DEPLOYMENT.md](./DEPLOYMENT.md) for complete setup instructions.

Quick start:
```bash
# 1. Configure environment
cd supabase
echo "OPENROUTER_API_KEY=your-key-here" > .env.local

# 2. Test locally
supabase functions serve generate-greeting --env-file .env.local

# 3. Deploy to production
supabase link --project-ref jlqycjwtiabjsfldhzwt
supabase secrets set OPENROUTER_API_KEY=your-key-here
supabase functions deploy generate-greeting
```

## Testing

### Local Testing
```bash
curl -X POST http://localhost:54321/functions/v1/generate-greeting \
  -H "Content-Type: application/json" \
  -d '{
    "recipientType": "parents",
    "tone": "formal",
    "occasion": "tet",
    "year": 2026
  }'
```

### Production Testing
```bash
curl -X POST https://jlqycjwtiabjsfldhzwt.supabase.co/functions/v1/generate-greeting \
  -H "Content-Type: application/json" \
  -d '{
    "recipientType": "friends",
    "tone": "informal",
    "occasion": "tet",
    "year": 2026,
    "language": "en"
  }'
```

## Cost Estimates

Using Claude 3.5 Haiku (default):
- ~$0.001 per greeting
- 10,000 greetings/month = ~$10/month

Using GPT-4o-mini:
- ~$0.0003 per greeting
- 10,000 greetings/month = ~$3/month

## Supported Models

Via OpenRouter API:
- `anthropic/claude-3.5-haiku` (default) - Fast, cost-effective
- `anthropic/claude-3.5-sonnet` - Higher quality
- `openai/gpt-4o-mini` - More affordable
- `openai/gpt-4o` - Highest quality
- See https://openrouter.ai/models for full list

Change model:
```bash
supabase secrets set OPENROUTER_MODEL=openai/gpt-4o-mini
```

## Monitoring

View function logs:
```bash
supabase functions logs generate-greeting
```

Tail logs in real-time:
```bash
supabase functions logs generate-greeting --tail
```

## Security

- API key stored as Supabase secret (never in code)
- CORS enabled for iOS app
- No authentication required (consider adding for production)
- No rate limiting (consider adding for production)

## Future Enhancements

1. **Rate Limiting** - Prevent abuse
2. **Caching** - Cache common greetings to reduce API costs
3. **Analytics** - Track usage and popular greeting types
4. **Templates** - Allow custom greeting templates
5. **CORS Restriction** - Limit to specific origins in production
6. **Authentication** - Add API key or JWT authentication
7. **Batch Generation** - Generate multiple greetings in one request

## Related Files

**iOS App:**
- `lich-plus/lich-plus/Services/GreetingService.swift` - iOS service that calls this endpoint
- `lich-plus/lich-plus/Utilities/CanChiCalculator.swift` - iOS zodiac calculator (logic matches this function)
- `lich-plus/lich-plus/Views/GreetingGeneratorView.swift` - UI for greeting generation

## Support

For issues or questions:
1. Check [DEPLOYMENT.md](./DEPLOYMENT.md) for troubleshooting
2. Review function logs: `supabase functions logs generate-greeting`
3. Test with curl to isolate issues
4. Verify API key and model configuration

## License

Part of the Lịch Việt project.
