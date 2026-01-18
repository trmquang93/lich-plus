# Greetings Feature Documentation

## Overview

The Greetings feature is an AI-powered Vietnamese Tet greeting generator that creates personalized, culturally appropriate greetings for various recipients and occasions. The feature combines traditional Vietnamese cultural elements (zodiac years, Can-Chi calendar) with modern AI technology to generate authentic, heartfelt messages.

**Key Capabilities:**
- AI-generated greetings using Claude 3.5 Haiku via OpenRouter API
- Support for 8 recipient types (grandparents, parents, boss, colleagues, teachers, friends, partner, children)
- 4 different tones (formal, casual, funny, romantic)
- Personalization with recipient names
- Additional context for custom greetings
- Offline fallback with pre-written sample greetings
- Vietnamese zodiac year integration (Can-Chi system)
- Copy to clipboard and share functionality

---

## Architecture

### File Structure

```
Features/Greetings/
├── README.md                           # This documentation
├── Models/
│   └── GreetingModels.swift           # Data models and enums
├── Components/
│   └── GreetingGeneratorView.swift    # Main UI view
└── Services/
    └── GreetingService.swift          # Backend service integration
```

### Backend Structure

```
supabase/functions/generate-greeting/
└── index.ts                           # Deno Edge Function for AI generation
```

---

## Data Models

### RecipientType

Defines the type of person receiving the greeting.

```swift
enum RecipientType: String, CaseIterable, Identifiable {
    case grandparents = "grandparents"
    case parents = "parents"
    case boss = "boss"
    case colleagues = "colleagues"
    case teachers = "teachers"
    case friends = "friends"
    case partner = "partner"
    case children = "children"
}
```

**Properties:**
- `displayName`: Vietnamese name (e.g., "Ông bà", "Bố mẹ")
- `icon`: SF Symbol icon name for UI

### GreetingTone

Defines the style/formality of the greeting.

```swift
enum GreetingTone: String, CaseIterable, Identifiable {
    case formal = "formal"
    case casual = "casual"
    case funny = "funny"
    case romantic = "romantic"
}
```

**Properties:**
- `displayName`: Vietnamese name (e.g., "Trang trọng", "Thân mật")
- `icon`: SF Symbol icon name for UI

**Availability by Recipient:**
- Partner: All tones (formal, casual, funny, romantic)
- Friends: formal, casual, funny
- Others: formal, casual only

### GreetingOccasion

Defines special occasions (currently focused on Tết).

```swift
enum GreetingOccasion: String, CaseIterable, Identifiable {
    case tet = "tet"
    case birthday = "birthday"
    case wedding = "wedding"
    case newYear = "new_year"
    case womensDay = "womens_day"
    case teachersDay = "teachers_day"
}
```

**Properties:**
- `displayName`: Vietnamese name
- `icon`: Emoji representation
- `tetZodiacAnimal`: Returns zodiac animal for Tết year
- Static methods: `zodiacAnimal(for:)`, `canChi(for:)` for year calculations

### GreetingRequest

Main request model for generating greetings.

```swift
struct GreetingRequest {
    let recipientType: RecipientType
    let tone: GreetingTone
    let occasion: GreetingOccasion
    let recipientName: String?
    let additionalInfo: String?
    let year: Int
}
```

**Usage:**
```swift
let request = GreetingRequest(
    recipientType: .parents,
    tone: .formal,
    occasion: .tet,
    recipientName: "Bố Mẹ",
    additionalInfo: "Con vừa được tăng lương",
    year: 2026
)
```

### GeneratedGreeting

Model representing a generated greeting with metadata.

```swift
struct GeneratedGreeting: Identifiable, Equatable {
    let id: UUID
    let text: String
    let request: GreetingRequest
    let createdAt: Date
}
```

---

## User Interface

### GreetingGeneratorView

Main SwiftUI view providing the greeting generation interface.

**State Variables:**
```swift
@State private var selectedRecipient: RecipientType = .parents
@State private var selectedTone: GreetingTone = .formal
@State private var recipientName: String = ""
@State private var additionalInfo: String = ""
@State private var generatedGreeting: GeneratedGreeting?
@State private var isGenerating: Bool = false
@State private var errorMessage: String?
@State private var showCopiedToast: Bool = false
```

**UI Sections:**

1. **Header Section**
   - Displays current year in Can-Chi format
   - Shows zodiac animal for the year
   - Red envelope emoji (🧧)

2. **Recipient Selection**
   - 4-column grid of recipient type buttons
   - Icons + labels for each type
   - Selected state with primary color background

3. **Tone Selection**
   - Horizontal row of tone buttons
   - Dynamically filtered based on recipient type
   - Selected state with primary color background

4. **Name Input Section** (Optional)
   - Single-line text field
   - Placeholder: "Ví dụ: Ông Nội, Mẹ, Anh Minh..."
   - Allows personalization with specific names

5. **Additional Info Section** (Optional) ⭐ NEW
   - Multi-line text field (3-6 lines)
   - Placeholder: "Ví dụ: Con vừa được tăng lương, Chúc mừng nhà mới..."
   - Provides custom context for AI generation

6. **Generate Button**
   - Primary action button
   - Shows loading spinner when generating
   - Disabled during generation

7. **Generated Greeting Card** (Conditional)
   - Displays generated greeting text
   - Recipient type badge
   - Copy to clipboard button
   - Share button (iOS ShareLink)
   - Regenerate button

8. **Error View** (Conditional)
   - Shows error messages
   - Indicates offline mode usage

**Design System Integration:**
- Uses `AppColors` for consistent theming
- Uses `AppTheme` for spacing and typography
- Follows project design patterns

---

## Backend Service

### GreetingService

Swift service class for API communication.

**Configuration:**
```swift
struct GreetingServiceConfig {
    static var backendURL: URL?        // Set via environment or hardcoded
    static let requestTimeout: TimeInterval = 30
    static let useOfflineFallback: Bool = true
}
```

**Environment Variables:**
```bash
GREETING_API_URL=https://your-project.supabase.co/functions/v1/generate-greeting
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Authentication Flow

Supabase Edge Functions require authentication for all requests. The iOS app must include a Supabase anon (publishable) key in the `Authorization` header.

**Why Authentication is Required:**
- Supabase Edge Functions are protected by default
- The anon key verifies requests are coming from your project
- The Edge Function itself doesn't check auth, but Supabase's infrastructure does
- Without the anon key, requests return `401 Unauthorized`

**Configuration:**
```swift
struct GreetingServiceConfig {
    static var backendURL: URL? { ... }

    /// Supabase anon key for authentication
    /// This is safe to include in the app - it's designed to be public
    static var supabaseAnonKey: String? {
        // Try to get from environment or use default
        if let key = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] {
            return key
        }

        // Production Supabase anon key
        return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
}
```

**Request Headers:**
```swift
private func callBackendFunction(url: URL, request: GreetingRequest) async throws -> String {
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "POST"
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // Add Supabase anon key for authentication
    if let anonKey = GreetingServiceConfig.supabaseAnonKey {
        urlRequest.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
    }

    urlRequest.timeoutInterval = GreetingServiceConfig.requestTimeout
    // ...
}
```

**Getting Your Anon Key:**

1. Open Supabase Dashboard: `https://supabase.com/dashboard/project/[your-project-id]`
2. Navigate to: **Settings** → **API**
3. Copy the **anon public** key (starts with `eyJ...`)
4. Add to `GreetingServiceConfig.supabaseAnonKey` or set as environment variable

**Security Note:**
- The anon key is **safe to include** in your iOS app
- It's designed to be public and only allows authorized operations
- Access is controlled by Row Level Security (RLS) policies, not the key itself
- Never use the `service_role` key in client apps (admin access)

**Environment Variable Setup (Optional):**

If you prefer not to hardcode the anon key:

1. In Xcode: **Product** → **Scheme** → **Edit Scheme**
2. Go to **Run** → **Arguments** → **Environment Variables**
3. Add: `SUPABASE_ANON_KEY` = `<your-anon-key>`
4. The code checks for the environment variable first, then falls back to hardcoded value

**Methods:**

1. `generateGreeting(for request: GreetingRequest) async throws -> String`
   - Main method for greeting generation
   - Falls back to offline samples if backend unavailable
   - Throws `GreetingServiceError` on failure

2. `generateOfflineGreeting(for request: GreetingRequest) -> String`
   - Returns random sample greeting
   - Used as fallback when backend unavailable
   - Never throws errors

**Error Handling:**
```swift
enum GreetingServiceError: LocalizedError {
    case networkError(Error)
    case invalidResponse
    case rateLimited
    case serverError(String)
    case unauthorized
}
```

### API Request/Response

**Request Payload:**
```swift
struct GreetingAPIRequest: Codable {
    let recipientType: String
    let tone: String
    let occasion: String
    let recipientName: String?
    let additionalInfo: String?
    let year: Int
}
```

**Response Payload:**
```swift
struct GreetingAPIResponse: Codable {
    let greeting: String?
    let error: String?
}
```

---

## Supabase Edge Function

### Overview

Deno-based serverless function that interfaces with OpenRouter API to generate greetings using Claude AI.

**File:** `supabase/functions/generate-greeting/index.ts`

**Environment Variables:**
```bash
OPENROUTER_API_KEY=sk-or-v1-...
OPENROUTER_MODEL=anthropic/claude-3.5-haiku  # Default model
```

### Can-Chi Calculation

Vietnamese zodiac system calculation for any year.

```typescript
function calculateCanChi(year: number): { can: string; chi: string; animal: string }
```

**Arrays:**
- **CAN** (10 Heavenly Stems): Canh, Tan, Nham, Quy, Giap, At, Binh, Dinh, Mau, Ky
- **CHI** (12 Earthly Branches): Than, Dau, Tuat, Hoi, Ty, Suu, Dan, Mao, Thin, Ty, Ngo, Mui
- **Animals**: Monkey, Rooster, Dog, Pig, Rat, Ox, Tiger, Rabbit, Dragon, Snake, Horse, Goat

**Formula:**
- Reference year: 1900 (Canh Ty)
- CAN index: `(year - 1900) % 10`
- CHI index: `(year - 1900) % 12`

### AI Prompt Construction

**System Prompt:**
- English: Creates greetings in English with Vietnamese cultural values
- Vietnamese: Creates greetings in Vietnamese with proper diacritics

**User Message Structure:**
```
Generate a [tone] Tet greeting for [recipientType].
Year: [year] ([Can-Chi] - Year of the [Animal])
Occasion: [occasion]
[Optional] Recipient name: [name]
[Optional] Additional context/requests from the sender:
[additionalInfo]

[Recipient-specific guidance based on relationship]
```

**Example User Message:**
```
Tạo lời chúc Tết trang trọng cho parents.
Năm: 2026 (Binh Ngo)
Dịp: tet
Tên người nhận: Bố Mẹ

Thông tin thêm từ người gửi:
Con vừa được tăng lương, muốn thông báo tin vui này

Sử dụng ngôn ngữ kính trọng, thể hiện lòng biết ơn và đạo hiếu.
```

### OpenRouter API Integration

**Request Format:**
```typescript
{
  model: "anthropic/claude-3.5-haiku",
  max_tokens: 512,
  messages: [
    { role: "system", content: systemPrompt },
    { role: "user", content: userMessage }
  ]
}
```

**Headers:**
```typescript
{
  "Authorization": "Bearer ${apiKey}",
  "Content-Type": "application/json",
  "HTTP-Referer": "https://lichplus.app",
  "X-Title": "Lich Plus Greeting Generator"
}
```

### Error Handling

**Validation:**
- Required fields: recipientType, tone, occasion, year
- Year range: 1900-2100
- Language: 'vi' or 'en' only

**Error Codes:**
- `VALIDATION_ERROR` (400): Invalid request parameters
- `CONFIG_ERROR` (500): Missing API key
- `API_ERROR` (502): OpenRouter API error
- `GENERATION_ERROR` (500): Unknown generation error

**CORS:**
- Supports OPTIONS preflight
- `Access-Control-Allow-Origin: *`
- Methods: POST, OPTIONS

---

## Sample Greetings (Offline Fallback)

### SampleGreetings Struct

Provides pre-written greeting templates when backend is unavailable.

**Method:**
```swift
static func randomGreeting(for request: GreetingRequest) -> String
```

**Template Coverage:**
- All 8 recipient types
- Formal and casual tones
- Special tones (funny for friends, romantic for partner)
- Uses year's Can-Chi and zodiac animal

**Personalization:**
- Replaces generic terms with recipient name if provided
- Examples: "Ông Bà" → "Ông Nội", "Bố Mẹ" → "Mẹ"

**Sample Template (Parents, Formal):**
```
"Con kính chúc Bố Mẹ năm [Can-Chi] sức khỏe dồi dào, vạn sự như ý.
Cảm ơn Bố Mẹ đã luôn yêu thương và chở che cho con!"
```

---

## Usage Examples

### Basic Usage

```swift
// In a SwiftUI view
import SwiftUI

struct MyView: View {
    var body: some View {
        GreetingGeneratorView()
    }
}
```

### Programmatic Generation

```swift
let service = GreetingService()

let request = GreetingRequest(
    recipientType: .grandparents,
    tone: .formal,
    occasion: .tet,
    recipientName: "Ông Bà",
    additionalInfo: nil,
    year: 2026
)

Task {
    do {
        let greeting = try await service.generateGreeting(for: request)
        print(greeting)
    } catch {
        print("Error: \(error)")
        // Fallback to offline greeting
        let offlineGreeting = service.generateOfflineGreeting(for: request)
        print(offlineGreeting)
    }
}
```

### Custom Context Examples

```swift
// Example 1: Professional achievement
let request1 = GreetingRequest(
    recipientType: .parents,
    tone: .formal,
    recipientName: "Bố Mẹ",
    additionalInfo: "Con vừa được tăng lương và thăng chức",
    year: 2026
)

// Example 2: Family news
let request2 = GreetingRequest(
    recipientType: .grandparents,
    tone: .casual,
    recipientName: "Ông Nội Bà Nội",
    additionalInfo: "Nhà con vừa chuyển sang khu mới, gần nhà Ông Bà hơn",
    year: 2026
)

// Example 3: Personal wish
let request3 = GreetingRequest(
    recipientType: .boss,
    tone: .formal,
    additionalInfo: "Chúc công ty năm mới phát triển, dự án ABC thành công",
    year: 2026
)
```

---

## Development Guide

### Adding New Recipient Types

1. Add case to `RecipientType` enum in `GreetingModels.swift`:
   ```swift
   case newRecipient = "new_recipient"
   ```

2. Add display name and icon:
   ```swift
   var displayName: String {
       case .newRecipient: return "Vietnamese Name"
   }

   var icon: String {
       case .newRecipient: return "sf.symbol.name"
   }
   ```

3. Add sample greetings in `SampleGreetings.swift`:
   ```swift
   case (.newRecipient, .formal):
       return ["Template 1", "Template 2", "Template 3"]
   ```

4. Update backend guidance in `index.ts` if needed

### Adding New Tones

1. Add case to `GreetingTone` enum
2. Update `availableTones` logic in `GreetingGeneratorView`
3. Add sample templates for new tone
4. Update AI prompt guidance if needed

### Adding New Occasions

1. Add case to `GreetingOccasion` enum
2. Add display name and icon
3. Update UI to allow occasion selection (currently hardcoded to `.tet`)
4. Add occasion-specific sample greetings
5. Update backend system prompt for new occasion

### Modifying AI Behavior

**System Prompt** (`buildSystemPrompt` function):
- Adjust tone guidelines
- Change length requirements (currently 2-4 sentences)
- Add cultural context

**User Message** (`buildUserMessage` function):
- Add more context fields
- Modify recipient-specific guidance
- Change format/structure

**Model Selection:**
- Default: `anthropic/claude-3.5-haiku` (fast, cost-effective)
- Alternatives: `anthropic/claude-3.5-sonnet`, `anthropic/claude-opus-4-5`
- Set via `OPENROUTER_MODEL` environment variable

---

## Testing

### Manual Testing Checklist

**UI Testing:**
- [ ] All recipient types display correctly
- [ ] Tone filtering works (partner shows all, friends shows 3, others show 2)
- [ ] Name input accepts Vietnamese characters
- [ ] Additional info field expands to 6 lines
- [ ] Generate button shows loading state
- [ ] Generated greeting displays correctly
- [ ] Copy to clipboard works
- [ ] Share button opens iOS share sheet
- [ ] Regenerate button creates new greeting
- [ ] Toast notification appears on copy

**Backend Testing:**
- [ ] Valid request generates greeting
- [ ] Invalid request returns error
- [ ] Missing API key returns CONFIG_ERROR
- [ ] Offline mode falls back to samples
- [ ] Name personalization works
- [ ] Additional info appears in generated greeting
- [ ] Can-Chi calculation is accurate
- [ ] Vietnamese diacritics render correctly

### Local Backend Testing

```bash
# Start Supabase local development
cd supabase
supabase functions serve generate-greeting --env-file .env.local

# Test with curl (local - no auth required)
curl -X POST http://localhost:54321/functions/v1/generate-greeting \
  -H "Content-Type: application/json" \
  -d '{
    "recipientType": "parents",
    "tone": "formal",
    "occasion": "tet",
    "recipientName": "Bố Mẹ",
    "additionalInfo": "Con vừa được tăng lương",
    "year": 2026
  }'
```

### Production Backend Testing

```bash
# Test production endpoint (requires anon key)
curl -X POST https://jlqycjwtiabjsfldhzwt.supabase.co/functions/v1/generate-greeting \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -d '{
    "recipientType": "parents",
    "tone": "formal",
    "occasion": "tet",
    "recipientName": "Bố Mẹ",
    "year": 2026
  }'

# Without Authorization header, you'll get 401 Unauthorized
# Replace the Bearer token with your actual Supabase anon key
```

### Unit Test Examples

```swift
// Test Can-Chi calculation
func testCanChiCalculation() {
    let year2026 = GreetingOccasion.canChi(for: 2026)
    XCTAssertEqual(year2026, "Bính Ngọ")
}

// Test zodiac animal
func testZodiacAnimal() {
    let animal2026 = GreetingOccasion.zodiacAnimal(for: 2026)
    XCTAssertEqual(animal2026, "🐴 Ngọ")
}

// Test offline greeting generation
func testOfflineGreeting() {
    let request = GreetingRequest(
        recipientType: .parents,
        tone: .formal,
        year: 2026
    )
    let greeting = SampleGreetings.randomGreeting(for: request)
    XCTAssertFalse(greeting.isEmpty)
    XCTAssertTrue(greeting.contains("Bố Mẹ") || greeting.contains("năm"))
}
```

---

## Deployment

### iOS App Deployment

1. Ensure `GreetingServiceConfig.backendURL` points to production:
   ```swift
   static var backendURL: URL? {
       return URL(string: "https://your-project.supabase.co/functions/v1/generate-greeting")
   }
   ```

2. Configure Supabase anon key for authentication:
   ```swift
   static var supabaseAnonKey: String? {
       // Option 1: Hardcode (safe for anon key)
       return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

       // Option 2: Use environment variable
       // Set SUPABASE_ANON_KEY in Xcode scheme
   }
   ```

3. Build and test app:
   ```bash
   cd lich-plus
   ./build-app.sh
   ./run-tests.sh
   ```

3. Standard iOS deployment via Xcode or CI/CD

### Backend Deployment

```bash
cd supabase

# Deploy function to Supabase
supabase functions deploy generate-greeting

# Set environment variables in Supabase dashboard
# OPENROUTER_API_KEY=sk-or-v1-...
# OPENROUTER_MODEL=anthropic/claude-3.5-haiku

# Verify deployment
supabase functions list
```

**Environment Variables in Supabase:**
1. Go to Supabase Dashboard → Edge Functions
2. Select `generate-greeting` function
3. Add environment variables:
   - `OPENROUTER_API_KEY`: Your OpenRouter API key
   - `OPENROUTER_MODEL`: (Optional) Model to use

---

## Troubleshooting

### Common Issues

**1. "401 Unauthorized" or "403 Forbidden" error**
- **Cause:** Missing or invalid Supabase anon key in Authorization header
- **Solution:**
  - Get anon key from Supabase Dashboard → Settings → API
  - Add to `GreetingServiceConfig.supabaseAnonKey`
  - Or set environment variable `SUPABASE_ANON_KEY`
  - Verify the key starts with `eyJ` (JWT token format)
  - Ensure you're using the **anon public** key, not the service_role key

**2. "Backend not configured" error**
- **Cause:** `GreetingServiceConfig.backendURL` is nil
- **Solution:** Set environment variable `GREETING_API_URL` or hardcode URL

**3. Greetings always use offline samples**
- **Cause:** Backend URL incorrect, function not deployed, or authentication failing
- **Solution:**
  - Verify URL is correct
  - Check Supabase function logs for errors
  - Verify anon key is configured
  - Test backend directly with curl (see Testing section)

**4. OpenRouter API error**
- **Cause:** Invalid API key or rate limit exceeded
- **Solution:** Check API key in Supabase secrets, verify OpenRouter account status

**5. Vietnamese characters display incorrectly**
- **Cause:** Encoding issues
- **Solution:** Ensure API returns UTF-8, check JSON encoding in Swift

**6. Additional info not appearing in greetings**
- **Cause:** Backend not updated or field empty
- **Solution:** Verify backend deployment, ensure field contains text

### Debug Logging

**iOS App:**
```swift
// Add logging in GreetingService.swift
print("Request payload: \(try! JSONEncoder().encode(payload))")
print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
```

**Backend:**
```typescript
// Edge function automatically logs to Supabase
console.log("Request:", request)
console.log("AI Response:", greeting)
```

**View Logs:**
```bash
# Local development
supabase functions logs generate-greeting --tail

# Production
# View in Supabase Dashboard → Edge Functions → Logs
```

---

## Performance Considerations

### API Response Times

- **Average:** 2-4 seconds with Claude 3.5 Haiku
- **Max tokens:** 512 (limits cost and response time)
- **Timeout:** 30 seconds (configurable)

### Optimization Tips

1. **Use Haiku model** for production (faster, cheaper)
2. **Cache common greetings** (future enhancement)
3. **Implement retry logic** for transient failures
4. **Monitor API costs** via OpenRouter dashboard

### Cost Estimation

**Claude 3.5 Haiku pricing (approximate):**
- Input: $0.25 per 1M tokens
- Output: $1.25 per 1M tokens
- Average greeting: ~150 input tokens, ~100 output tokens
- **Cost per greeting:** ~$0.0001 (negligible)

---

## Security

### API Key Protection

✅ **Correct Implementation:**
- API keys stored in Supabase Edge Function environment
- Never exposed to iOS app
- iOS app calls Edge Function, which calls OpenRouter

❌ **Never Do This:**
- Store API keys in iOS app code
- Expose keys in client-side requests
- Commit keys to version control

### Input Validation

**Backend validation:**
- Recipient type, tone, occasion: Must be valid enum values
- Year: 1900-2100 range
- Name/Additional info: No size limits (reasonable use expected)

**Future Enhancements:**
- Rate limiting per user
- Input sanitization
- Content moderation

---

## Future Enhancements

### Planned Features

1. **Greeting History**
   - Save generated greetings to SwiftData
   - View past greetings
   - Favorite greetings

2. **Multiple Occasions**
   - UI selector for occasion type
   - Birthday greetings with age calculation
   - Wedding greetings with couple names

3. **Template Customization**
   - User-editable templates
   - Style preferences
   - Length preferences (short/medium/long)

4. **Social Features**
   - Share greetings as images
   - Custom greeting cards with designs
   - Send via Messages/WhatsApp

5. **Analytics**
   - Track most popular recipient types
   - Popular tones
   - Generation success rate

6. **Advanced Personalization**
   - Import contacts
   - Remember preferences per contact
   - Suggested greetings based on history

### Technical Improvements

1. **Caching Layer**
   - Cache common greeting combinations
   - Reduce API costs
   - Faster response times

2. **Error Recovery**
   - Automatic retry with exponential backoff
   - Better error messages
   - Offline queue for failed requests

3. **Internationalization**
   - English greetings (already supported by backend)
   - UI language selection
   - Mixed language greetings

4. **Testing**
   - Comprehensive unit tests
   - UI automation tests
   - Backend integration tests

---

## References

### Vietnamese Calendar & Culture

- **Can-Chi System:** Vietnamese sexagenary cycle for year naming
- **Zodiac Animals:** 12-year cycle based on lunar calendar
- **Cultural Values:** Respect for elders, family bonds, prosperity wishes

### External Dependencies

- **OpenRouter API:** https://openrouter.ai/docs
- **Claude AI Models:** https://docs.anthropic.com/
- **Supabase Edge Functions:** https://supabase.com/docs/guides/functions

### Related Documentation

- `../../CLAUDE.md` - Project-wide development guidelines
- `../../../SWIFTUI_BEST_PRACTICES.md` - SwiftUI patterns
- `supabase/README.md` - Backend setup and deployment

---

## Changelog

### v1.1.1 (2026-01-18)
- 🔐 Added Supabase authentication flow with anon key
- 🔧 Fixed 401 Unauthorized errors when calling Edge Function
- 📝 Added Authorization header with Bearer token to all API requests
- 🔑 Implemented environment variable support for `SUPABASE_ANON_KEY`
- 📚 Comprehensive documentation on authentication setup and troubleshooting

### v1.1.0 (2026-01-18)
- ✨ Added `additionalInfo` field for custom context
- 📱 New multi-line text input in UI
- 🔧 Backend updated to incorporate additional context in AI prompts
- 📦 Moved supabase folder into lich-plus repo

### v1.0.0 (2026-01-17)
- 🎉 Initial release
- ✨ AI-powered greeting generation
- 📱 SwiftUI interface with 8 recipient types
- 🎨 4 tone options
- 💾 Offline fallback with sample greetings
- 🔄 Share and copy functionality
- 🌏 Vietnamese zodiac integration

---

## Support & Contributing

### Getting Help

- Check troubleshooting section above
- Review Supabase function logs
- Verify OpenRouter API status

### Development Workflow

1. Make changes to models/views/services
2. Test locally with `./build-app.sh`
3. Test backend with `supabase functions serve`
4. Run tests with `./run-tests.sh`
5. Deploy backend with `supabase functions deploy`
6. Build and deploy iOS app

### Code Style

- Follow SwiftUI best practices (see `SWIFTUI_BEST_PRACTICES.md`)
- Use `AppColors` and `AppTheme` for styling
- Keep functions focused and single-purpose
- Add comments for complex logic
- Update this documentation for significant changes

---

**Last Updated:** January 18, 2026
**Maintainer:** Development Team
**Version:** 1.1.1
