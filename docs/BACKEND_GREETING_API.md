# Backend API Requirements: Greeting Generator

## Overview

This document describes the backend API requirements for the Lich+ greeting generator feature. The backend function acts as a secure proxy to the Claude API, keeping the API key server-side.

## Architecture

```
┌──────────────┐     ┌─────────────────────┐     ┌─────────────────┐
│   iOS App    │────▶│  Backend Function   │────▶│   Claude API    │
│  (Lich+)     │◀────│ (Firebase/Supabase) │◀────│   (Anthropic)   │
└──────────────┘     └─────────────────────┘     └─────────────────┘
                              │
                              ▼
                     ┌─────────────────┐
                     │  CLAUDE_API_KEY │
                     │  (Secret/Env)   │
                     └─────────────────┘
```

## API Endpoint

### URL Options

**Firebase Cloud Functions:**
```
POST https://<region>-<project-id>.cloudfunctions.net/generateGreeting
```

**Supabase Edge Functions:**
```
POST https://<project-ref>.supabase.co/functions/v1/generate-greeting
```

### HTTP Method
`POST`

### Headers
| Header | Value |
|--------|-------|
| `Content-Type` | `application/json` |

### Request Body

```json
{
  "recipientType": "parents",
  "tone": "formal",
  "occasion": "tet",
  "recipientName": "Bố Mẹ",
  "year": 2026
}
```

#### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `recipientType` | string | Yes | Type of recipient |
| `tone` | string | Yes | Greeting tone/style |
| `occasion` | string | Yes | Occasion type |
| `recipientName` | string | No | Optional name for personalization |
| `year` | integer | Yes | Year for zodiac calculation |

#### Enum Values

**recipientType:**
| Value | Vietnamese | Description |
|-------|------------|-------------|
| `grandparents` | Ông bà | Grandparents |
| `parents` | Bố mẹ | Parents |
| `boss` | Sếp | Boss/Manager |
| `colleagues` | Đồng nghiệp | Colleagues |
| `teachers` | Thầy cô | Teachers |
| `friends` | Bạn bè | Friends |
| `partner` | Người yêu | Partner/Spouse |
| `children` | Con cháu | Children |

**tone:**
| Value | Vietnamese | Description |
|-------|------------|-------------|
| `formal` | Trang trọng | Formal/Respectful |
| `casual` | Thân mật | Casual/Friendly |
| `funny` | Vui vẻ | Humorous |
| `romantic` | Lãng mạn | Romantic |

**occasion:**
| Value | Vietnamese | Description |
|-------|------------|-------------|
| `tet` | Tết Nguyên Đán | Lunar New Year |
| `birthday` | Sinh nhật | Birthday (future) |
| `wedding` | Đám cưới | Wedding (future) |
| `new_year` | Năm mới dương lịch | Solar New Year (future) |
| `womens_day` | Ngày 8/3 | Women's Day (future) |
| `teachers_day` | Ngày Nhà giáo | Teachers' Day (future) |

### Response Body

#### Success (200 OK)
```json
{
  "greeting": "Con kính chúc Bố Mẹ năm Bính Ngọ sức khỏe dồi dào, vạn sự như ý. Cảm ơn Bố Mẹ đã luôn yêu thương và chở che cho con!"
}
```

#### Error (4xx/5xx)
```json
{
  "error": "Error message describing what went wrong"
}
```

### HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 400 | Bad Request (invalid parameters) |
| 401 | Unauthorized |
| 429 | Rate Limited |
| 500 | Internal Server Error |

---

## Implementation Guide

### 1. Environment Variables

Store the Claude API key securely:

**Firebase:**
```bash
firebase functions:secrets:set CLAUDE_API_KEY
```

**Supabase:**
```bash
supabase secrets set CLAUDE_API_KEY=sk-ant-xxxxx
```

### 2. Claude API Integration

#### Model
Use `claude-3-5-haiku-20241022` for fast, cost-effective responses.

#### System Prompt Template

```
Bạn là chuyên gia viết lời chúc Tết Việt Nam. Hãy tạo lời chúc Tết năm {CAN_CHI} ({ZODIAC}) theo yêu cầu.

Quy tắc:
1. Viết bằng tiếng Việt, tự nhiên và chân thành
2. Độ dài: 2-4 câu (khoảng 50-100 từ)
3. Có thể dùng emoji phù hợp nếu phong cách thân mật/vui vẻ
4. Nhắc đến năm {CAN_CHI} hoặc con giáp {ZODIAC} nếu phù hợp
5. Phù hợp với mối quan hệ và phong cách được yêu cầu
6. KHÔNG bao gồm tiêu đề hay định dạng markdown
7. Chỉ trả về nội dung lời chúc, không giải thích gì thêm

Các cụm từ Tết thường dùng:
- An khang thịnh vượng
- Vạn sự như ý
- Phúc lộc đầy nhà
- Mã đáo thành công (năm Ngọ)
- Sức khỏe dồi dào
- Gia đình hạnh phúc
```

#### User Message Template

```
Viết lời chúc Tết cho {RECIPIENT_DISPLAY_NAME} (tên: {RECIPIENT_NAME}) với phong cách {TONE}.
{ADDITIONAL_GUIDANCE}
```

**Additional Guidance by Recipient Type:**
| Type | Guidance |
|------|----------|
| grandparents | Nhấn mạnh sức khỏe, trường thọ. |
| parents | Thể hiện lòng biết ơn và tình yêu thương. |
| boss | Chuyên nghiệp, chúc thành công trong công việc. |
| colleagues | Thân thiện, chúc công việc thuận lợi. |
| teachers | Kính trọng, cảm ơn sự dìu dắt. |
| friends | Thoải mái, có thể hài hước nếu phong cách cho phép. |
| partner | Ngọt ngào, thể hiện tình cảm. |
| children | Yêu thương, động viên học tập và trưởng thành. |

### 3. Vietnamese Zodiac Calculation

Use these formulas to calculate Can-Chi and zodiac animal:

```javascript
// Thiên Can (Heavenly Stems)
const CAN = ["Giáp", "Ất", "Bính", "Đinh", "Mậu", "Kỷ", "Canh", "Tân", "Nhâm", "Quý"];

// Địa Chi (Earthly Branches)
const CHI = ["Tý", "Sửu", "Dần", "Mão", "Thìn", "Tỵ", "Ngọ", "Mùi", "Thân", "Dậu", "Tuất", "Hợi"];

// Zodiac Animals with Emoji
const ANIMALS = ["🐀 Tý", "🐂 Sửu", "🐅 Dần", "🐇 Mão", "🐉 Thìn", "🐍 Tỵ",
                 "🐴 Ngọ", "🐐 Mùi", "🐒 Thân", "🐓 Dậu", "🐕 Tuất", "🐖 Hợi"];

function getCanChi(year) {
  const canIndex = (year - 4) % 10;
  const chiIndex = (year - 4) % 12;
  return `${CAN[canIndex]} ${CHI[chiIndex]}`;
}

function getZodiacAnimal(year) {
  const index = (year - 4) % 12;
  return ANIMALS[index];
}

// Example: 2026
// getCanChi(2026) => "Bính Ngọ"
// getZodiacAnimal(2026) => "🐴 Ngọ"
```

### 4. Rate Limiting

Implement rate limiting to prevent abuse:

| Limit | Value |
|-------|-------|
| Per IP | 10 requests/minute |
| Per user (if auth) | 30 requests/minute |
| Global | 1000 requests/hour |

### 5. Caching (Optional)

Consider caching responses for identical requests to reduce API costs:

```
Cache Key: `greeting:${recipientType}:${tone}:${occasion}:${year}:${hash(recipientName)}`
TTL: 24 hours
```

---

## Example Implementations

### Firebase Cloud Functions (TypeScript)

```typescript
import * as functions from "firebase-functions";
import Anthropic from "@anthropic-ai/sdk";

const anthropic = new Anthropic({
  apiKey: process.env.CLAUDE_API_KEY,
});

export const generateGreeting = functions.https.onRequest(async (req, res) => {
  // CORS
  res.set("Access-Control-Allow-Origin", "*");

  if (req.method === "OPTIONS") {
    res.set("Access-Control-Allow-Methods", "POST");
    res.set("Access-Control-Allow-Headers", "Content-Type");
    res.status(204).send("");
    return;
  }

  if (req.method !== "POST") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  try {
    const { recipientType, tone, occasion, recipientName, year } = req.body;

    // Validate required fields
    if (!recipientType || !tone || !occasion || !year) {
      res.status(400).json({ error: "Missing required fields" });
      return;
    }

    const canChi = getCanChi(year);
    const zodiac = getZodiacAnimal(year);

    const systemPrompt = buildSystemPrompt(canChi, zodiac);
    const userMessage = buildUserMessage(recipientType, tone, recipientName);

    const message = await anthropic.messages.create({
      model: "claude-3-5-haiku-20241022",
      max_tokens: 512,
      system: systemPrompt,
      messages: [{ role: "user", content: userMessage }],
    });

    const greeting = message.content[0].type === "text"
      ? message.content[0].text
      : "";

    res.status(200).json({ greeting: greeting.trim() });
  } catch (error) {
    console.error("Error generating greeting:", error);
    res.status(500).json({ error: "Failed to generate greeting" });
  }
});
```

### Supabase Edge Functions (Deno/TypeScript)

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import Anthropic from "npm:@anthropic-ai/sdk";

const anthropic = new Anthropic({
  apiKey: Deno.env.get("CLAUDE_API_KEY"),
});

serve(async (req) => {
  // CORS
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers": "Content-Type",
      },
    });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  try {
    const { recipientType, tone, occasion, recipientName, year } = await req.json();

    // Validate
    if (!recipientType || !tone || !occasion || !year) {
      return new Response(JSON.stringify({ error: "Missing required fields" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const canChi = getCanChi(year);
    const zodiac = getZodiacAnimal(year);

    const message = await anthropic.messages.create({
      model: "claude-3-5-haiku-20241022",
      max_tokens: 512,
      system: buildSystemPrompt(canChi, zodiac),
      messages: [{ role: "user", content: buildUserMessage(recipientType, tone, recipientName) }],
    });

    const greeting = message.content[0].type === "text" ? message.content[0].text : "";

    return new Response(JSON.stringify({ greeting: greeting.trim() }), {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  } catch (error) {
    console.error("Error:", error);
    return new Response(JSON.stringify({ error: "Failed to generate greeting" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
```

---

## Testing

### cURL Example

```bash
curl -X POST https://your-function-url/generateGreeting \
  -H "Content-Type: application/json" \
  -d '{
    "recipientType": "parents",
    "tone": "formal",
    "occasion": "tet",
    "recipientName": "Bố Mẹ",
    "year": 2026
  }'
```

### Expected Response

```json
{
  "greeting": "Con kính chúc Bố Mẹ năm Bính Ngọ sức khỏe dồi dào, vạn sự như ý. Cảm ơn Bố Mẹ đã luôn yêu thương và chở che cho con! 🧧"
}
```

---

## Deployment Checklist

- [ ] Set `CLAUDE_API_KEY` as secret/environment variable
- [ ] Deploy function to Firebase/Supabase
- [ ] Test endpoint with cURL
- [ ] Configure CORS for iOS app domain
- [ ] Set up rate limiting
- [ ] Set up monitoring/logging
- [ ] Update iOS app with production URL in `GreetingServiceConfig.backendURL`

---

## iOS App Configuration

After deploying the backend, update the iOS app:

**Option 1: Environment Variable**
Set `GREETING_API_URL` in Xcode scheme environment variables.

**Option 2: Hardcode URL**
Edit `GreetingService.swift`:

```swift
struct GreetingServiceConfig {
    static var backendURL: URL? {
        return URL(string: "https://your-deployed-function-url")
    }
}
```

---

## Cost Estimation

Using Claude 3.5 Haiku:
- Input: ~500 tokens per request
- Output: ~150 tokens per request
- Cost: ~$0.0003 per greeting

| Usage | Monthly Cost |
|-------|--------------|
| 1,000 greetings | ~$0.30 |
| 10,000 greetings | ~$3.00 |
| 100,000 greetings | ~$30.00 |

---

## Questions?

Contact the iOS team for clarification on:
- Request/response format
- Error handling requirements
- Rate limiting thresholds
