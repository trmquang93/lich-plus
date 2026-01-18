import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { validateNonce } from "./nonce.ts"

const OPENROUTER_API_URL = "https://openrouter.ai/api/v1/chat/completions"

// Rate limiting (in-memory, resets on cold start)
const rateLimitMap = new Map<string, { count: number; resetTime: number }>()
const RATE_LIMIT_MAX = 20      // requests per minute
const RATE_LIMIT_WINDOW = 60000 // 1 minute

interface GreetingRequest {
  recipientType: string
  tone: string
  occasion: string
  recipientName?: string
  additionalInfo?: string
  year: number
  language?: string
  nonce: string
}

interface GreetingResponse {
  greeting: string
}

interface ErrorResponse {
  error: string
  code?: string
  details?: string
}

// Authentication and rate limiting functions
interface AuthResult {
  userId?: string
  error?: string
}

async function verifyAuth(req: Request): Promise<AuthResult> {
  const authHeader = req.headers.get("Authorization")

  if (!authHeader?.startsWith("Bearer ")) {
    return { error: "Missing or invalid Authorization header" }
  }

  // Create Supabase client with the user's auth context
  // This is the recommended pattern for Edge Functions
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    {
      global: {
        headers: { Authorization: authHeader }
      }
    }
  )

  // getUser() will use the Authorization header we passed
  const { data: { user }, error } = await supabase.auth.getUser()

  if (error) {
    return { error: `Supabase auth error: ${error.message}` }
  }

  if (!user) {
    return { error: "No user found in session" }
  }

  return { userId: user.id }
}

function checkRateLimit(userId: string): { allowed: boolean; remaining: number } {
  const now = Date.now()
  const entry = rateLimitMap.get(userId)

  if (!entry || now > entry.resetTime) {
    rateLimitMap.set(userId, { count: 1, resetTime: now + RATE_LIMIT_WINDOW })
    return { allowed: true, remaining: RATE_LIMIT_MAX - 1 }
  }

  if (entry.count >= RATE_LIMIT_MAX) {
    return { allowed: false, remaining: 0 }
  }

  entry.count++
  return { allowed: true, remaining: RATE_LIMIT_MAX - entry.count }
}

// Vietnamese zodiac arrays (Can and Chi)
// Reference: Year 4 AD was "Giáp Tý" - the canonical starting point
const CAN = ["Giap", "At", "Binh", "Dinh", "Mau", "Ky", "Canh", "Tan", "Nham", "Quy"]
const CHI = ["Ty", "Suu", "Dan", "Mao", "Thin", "Ti", "Ngo", "Mui", "Than", "Dau", "Tuat", "Hoi"]
const CHI_ANIMALS = ["Rat", "Ox", "Tiger", "Rabbit", "Dragon", "Snake", "Horse", "Goat", "Monkey", "Rooster", "Dog", "Pig"]

function calculateCanChi(year: number): { can: string; chi: string; animal: string } {
  // Use canonical formula: year 4 AD was "Giáp Tý"
  const canIndex = (year - 4 + 10) % 10
  const chiIndex = (year - 4 + 12) % 12

  return {
    can: CAN[canIndex],
    chi: CHI[chiIndex],
    animal: CHI_ANIMALS[chiIndex]
  }
}

function buildSystemPrompt(language: string): string {
  if (language === "en") {
    return `You are a helpful assistant that generates warm, culturally appropriate Vietnamese Tet (Lunar New Year) greetings in English.

Guidelines:
- Create heartfelt, sincere greetings appropriate for the specified recipient and tone
- For formal greetings to elders (parents, grandparents), use respectful language
- For informal greetings to peers or younger people, use warm, friendly language
- Include wishes for health, prosperity, happiness, and success
- Reference the zodiac year when appropriate
- Keep greetings concise but meaningful (2-4 sentences)
- Write in English but maintain Vietnamese cultural values of respect and family

Respond with ONLY the greeting text, no additional explanation or formatting.`
  }

  return `Bạn là trợ lý tạo lời chúc Tết Việt Nam ấm áp và phù hợp văn hóa.

Hướng dẫn:
- Tạo lời chúc chân thành, phù hợp với người nhận và giọng điệu được chỉ định
- Với lời chúc trang trọng dành cho người lớn tuổi (bố mẹ, ông bà), sử dụng ngôn ngữ kính trọng
- Với lời chúc thân mật dành cho bạn bè hoặc người trẻ tuổi, sử dụng ngôn ngữ ấm áp, gần gũi
- Bao gồm lời chúc sức khỏe, thịnh vượng, hạnh phúc và thành công
- Nhắc đến năm con giáp khi phù hợp
- Giữ lời chúc ngắn gọn nhưng ý nghĩa (2-4 câu)
- Sử dụng tiếng Việt có dấu chuẩn

Chỉ trả lời lời chúc, không giải thích hay định dạng thêm.`
}

function buildUserMessage(request: GreetingRequest, canChi: { can: string; chi: string; animal: string }): string {
  const { recipientType, tone, occasion, recipientName, additionalInfo, year, language } = request
  const yearName = `${canChi.can} ${canChi.chi}`

  if (language === "en") {
    let message = `Generate a ${tone} Tet greeting for ${recipientType}.`
    message += `\nYear: ${year} (${yearName} - Year of the ${canChi.animal})`
    message += `\nOccasion: ${occasion}`

    if (recipientName) {
      message += `\nRecipient name: ${recipientName}`
    }

    if (additionalInfo) {
      message += `\n\nAdditional context/requests from the sender:\n${additionalInfo}`
    }

    // Add recipient-specific guidance
    if (recipientType === "parents" || recipientType === "grandparents") {
      message += "\n\nUse respectful language showing gratitude and filial piety."
    } else if (recipientType === "friends" || recipientType === "colleagues") {
      message += "\n\nUse warm, friendly language wishing mutual success."
    } else if (recipientType === "children") {
      message += "\n\nUse encouraging, loving language wishing growth and learning."
    }

    return message
  }

  let message = `Tạo lời chúc Tết ${tone === "formal" ? "trang trọng" : "thân mật"} cho ${recipientType}.`
  message += `\nNăm: ${year} (${yearName})`
  message += `\nDịp: ${occasion}`

  if (recipientName) {
    message += `\nTên người nhận: ${recipientName}`
  }

  if (additionalInfo) {
    message += `\n\nThông tin thêm từ người gửi:\n${additionalInfo}`
  }

  // Add recipient-specific guidance in Vietnamese
  if (recipientType === "parents" || recipientType === "grandparents") {
    message += "\n\nSử dụng ngôn ngữ kính trọng, thể hiện lòng biết ơn và đạo hiếu."
  } else if (recipientType === "friends" || recipientType === "colleagues") {
    message += "\n\nSử dụng ngôn ngữ ấm áp, thân thiện, chúc nhau cùng thành công."
  } else if (recipientType === "children") {
    message += "\n\nSử dụng ngôn ngữ khích lệ, yêu thương, chúc con trưởng thành và học hành tốt."
  }

  return message
}

async function generateGreeting(request: GreetingRequest): Promise<string> {
  const apiKey = Deno.env.get("OPENROUTER_API_KEY")
  const model = Deno.env.get("OPENROUTER_MODEL") || "anthropic/claude-3.5-haiku"

  if (!apiKey) {
    throw new Error("OPENROUTER_API_KEY not configured")
  }

  const canChi = calculateCanChi(request.year)
  const language = request.language || "vi"
  const systemPrompt = buildSystemPrompt(language)
  const userMessage = buildUserMessage(request, canChi)

  const response = await fetch(OPENROUTER_API_URL, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
      "HTTP-Referer": "https://lichplus.app",
      "X-Title": "Lich Plus Greeting Generator"
    },
    body: JSON.stringify({
      model,
      max_tokens: 512,
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: userMessage }
      ]
    })
  })

  if (!response.ok) {
    const errorText = await response.text()
    throw new Error(`OpenRouter API error (${response.status}): ${errorText}`)
  }

  const data = await response.json()
  const greeting = data.choices?.[0]?.message?.content?.trim()

  if (!greeting) {
    throw new Error("No greeting generated by API")
  }

  return greeting
}

function validateRequest(body: any): { valid: boolean; error?: string } {
  if (!body.recipientType || typeof body.recipientType !== "string") {
    return { valid: false, error: "recipientType is required and must be a string" }
  }

  if (!body.tone || typeof body.tone !== "string") {
    return { valid: false, error: "tone is required and must be a string" }
  }

  if (!body.occasion || typeof body.occasion !== "string") {
    return { valid: false, error: "occasion is required and must be a string" }
  }

  if (!body.year || typeof body.year !== "number") {
    return { valid: false, error: "year is required and must be a number" }
  }

  if (body.year < 1900 || body.year > 2100) {
    return { valid: false, error: "year must be between 1900 and 2100" }
  }

  if (body.language && !["vi", "en"].includes(body.language)) {
    return { valid: false, error: "language must be 'vi' or 'en'" }
  }

  if (!body.nonce || typeof body.nonce !== "string") {
    return { valid: false, error: "nonce is required and must be a string" }
  }

  return { valid: true }
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    })
  }

  // Only allow POST
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed" } as ErrorResponse),
      {
        status: 405,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    )
  }

  try {
    // 1. Verify authentication
    const auth = await verifyAuth(req)
    if (!auth.userId) {
      return new Response(
        JSON.stringify({
          error: "Unauthorized",
          code: "AUTH_ERROR",
          details: auth.error || "Unknown auth error"
        }),
        {
          status: 401,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
        }
      )
    }

    // 2. Check rate limit
    const rateLimit = checkRateLimit(auth.userId)
    if (!rateLimit.allowed) {
      return new Response(
        JSON.stringify({ error: "Rate limit exceeded", code: "RATE_LIMIT_ERROR" } as ErrorResponse),
        {
          status: 429,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
        }
      )
    }

    // 3. Parse request body
    const body = await req.json()

    // 4. Validate request
    const validation = validateRequest(body)
    if (!validation.valid) {
      return new Response(
        JSON.stringify({
          error: validation.error,
          code: "VALIDATION_ERROR"
        } as ErrorResponse),
        {
          status: 400,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
        }
      )
    }

    // 5. Validate nonce (prevent replay attacks)
    const nonceValidation = await validateNonce(body.nonce, auth.userId)
    if (!nonceValidation.valid) {
      return new Response(
        JSON.stringify({
          error: nonceValidation.error,
          code: nonceValidation.code
        } as ErrorResponse),
        {
          status: nonceValidation.code === "REPLAY_DETECTED" ? 409 : 400,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
        }
      )
    }

    // 6. Generate greeting
    const greeting = await generateGreeting(body as GreetingRequest)

    // Return success response
    return new Response(
      JSON.stringify({ greeting } as GreetingResponse),
      {
        status: 200,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    )

  } catch (error) {
    console.error("Error generating greeting:", error)

    const errorMessage = error instanceof Error ? error.message : "Unknown error"
    const isConfigError = errorMessage.includes("not configured")
    const isApiError = errorMessage.includes("API error")

    return new Response(
      JSON.stringify({
        error: errorMessage,
        code: isConfigError ? "CONFIG_ERROR" : isApiError ? "API_ERROR" : "GENERATION_ERROR"
      } as ErrorResponse),
      {
        status: isConfigError ? 500 : isApiError ? 502 : 500,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    )
  }
})
