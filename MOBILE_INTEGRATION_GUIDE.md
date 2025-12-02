# Puldon Mobile Integration Guide

## 🔗 Base Configuration

### API Base URL
```
Production: https://your-domain.com
Development: http://localhost:8000
```

### Required Headers
```
Content-Type: application/json
Authorization: Bearer <access_token>  # For authenticated endpoints
```

---

## 🔐 Authentication Flow

### 1. Sign Up New User

**Endpoint**: `POST /auth/signup`

**Request**:
```json
{
  "phone_number": "+1234567890",      // Required: E.164 format with country code
  "full_name": "John Doe",            // Required
  "gender": "male",                   // Optional: "male", "female", "other"
  "date_of_birth": "1990-01-15",      // Optional: YYYY-MM-DD format
  "email": "john@example.com",        // Optional
  "image_id": "avatar_1"              // Optional: Avatar identifier
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "User registered successfully. Please sign in to continue.",
  "user_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Error Response** (400 Bad Request):
```json
{
  "detail": "Phone number already registered"
}
```

---

### 2. Sign In - Step 1: Request OTP

**Endpoint**: `POST /auth/signin/request-otp`

**Request**:
```json
{
  "phone_number": "+1234567890"
}
```

**Response** (200 OK):
```json
{
  "message": "OTP sent to +1234567890",
  "otp_code": "123456"  // Only in development mode, omitted in production
}
```

**Important**: In production, the OTP will be sent via SMS to the user's phone. In development, the OTP is returned in the response for testing.

---

### 3. Sign In - Step 2: Verify OTP & Get Token

**Endpoint**: `POST /auth/signin/verify-otp`

**Request**:
```json
{
  "phone_number": "+1234567890",
  "otp": "123456"
}
```

**Response** (200 OK):
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1NTBlODQwMC1lMjliLTQxZDQtYTcxNi00NDY2NTU0NDAwMDAiLCJwaG9uZSI6IisxMjM0NTY3ODkwIiwiZXhwIjoxNzM3MDI0MDAwLCJpYXQiOjE3MzY0MTkyMDB9.abcd1234...",
  "token_type": "bearer"
}
```

**Error Response** (401 Unauthorized):
```json
{
  "detail": "Invalid or expired OTP code"
}
```

**Store this token securely** (Keychain on iOS, EncryptedSharedPreferences on Android)

**Token Expiration**: 7 days by default

---

## 📲 Profile Management

### Get User Profile

**Endpoint**: `GET /auth/profile`

**Headers**:
```
Authorization: Bearer <access_token>
```

**Response** (200 OK):
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "phone_number": "+1234567890",
  "full_name": "John Doe",
  "gender": "male",
  "date_of_birth": "1990-01-15",
  "email": "john@example.com",
  "image_id": "avatar_1",
  "created_at": "2025-01-15T10:30:00Z"
}
```

---

### Update Profile

**Endpoint**: `PATCH /auth/profile`

**Headers**:
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request** (all fields optional):
```json
{
  "full_name": "John Smith",
  "gender": "male",
  "date_of_birth": "1990-01-15",
  "email": "johnsmith@example.com",
  "image_id": "avatar_2"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "user": { /* updated user object */ }
}
```

---

### Update Phone Number

**Step 1 - Request OTP**: `POST /auth/profile/phone/request-otp`

**Headers**:
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request**:
```json
{
  "new_phone_number": "+1987654321"
}
```

**Response** (200 OK):
```json
{
  "message": "OTP sent to +1987654321",
  "otp_code": "654321"  // Only in dev mode
}
```

**Step 2 - Verify OTP**: `POST /auth/profile/phone/verify-otp`

**Request**:
```json
{
  "new_phone_number": "+1987654321",
  "otp": "654321"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Phone number updated successfully",
  "new_phone_number": "+1987654321"
}
```

---

## 📊 Dashboard

### Get Dashboard

**Endpoint**: `GET /dashboard`

**Headers**:
```
Authorization: Bearer <access_token>
```

**Response** (200 OK):
```json
{
  "net_worth": 5000.00,
  "not_invested_money": 5000.00,
  "insights": [
    "You're 40.0% towards your 2 active goal(s). Keep it up!",
    "Your net worth is positive at $5,000.00. Keep building your wealth!"
  ],
  "overview": [
    {
      "sector": "savings",
      "portion_percent": 70.50
    },
    {
      "sector": "debt",
      "portion_percent": 29.50
    }
  ]
}
```

---

## 🎯 Goals Management

### List All Goals

**Endpoint**: `GET /goals`

**Headers**:
```
Authorization: Bearer <access_token>
```

**Response** (200 OK):
```json
[
  {
    "id": "goal-uuid-1",
    "name": "Emergency Fund",
    "icon": "💰",
    "description": "Save for 6 months expenses",
    "progress": 20.0,
    "current_contribution": 2000.00,
    "total_contribution": 10000.00,
    "days_left": 180,
    "monthly_recurring_contribution": 500.00,
    "color": "#4CAF50"
  },
  {
    "id": "goal-uuid-2",
    "name": "Vacation Fund",
    "icon": "✈️",
    "description": "Trip to Europe",
    "progress": 50.0,
    "current_contribution": 2500.00,
    "total_contribution": 5000.00,
    "days_left": 90,
    "monthly_recurring_contribution": 300.00,
    "color": "#2196F3"
  }
]
```

---

### Get Goal Details

**Endpoint**: `GET /goals/{goal_id}`

**Headers**:
```
Authorization: Bearer <access_token>
```

**Response** (200 OK):
```json
{
  "id": "goal-uuid-1",
  "name": "Emergency Fund",
  "icon": "💰",
  "description": "Save for 6 months expenses",
  "current_contribution": 2000.00,
  "total_contribution": 10000.00,
  "days_left": 180,
  "monthly_recurring_contribution": 500.00,
  "color": "#4CAF50",
  "contribution_history": [
    {
      "amount": 500.00,
      "date": "2025-01-15",
      "currency_type": "USD"
    },
    {
      "amount": 1500.00,
      "date": "2025-01-01",
      "currency_type": "USD"
    }
  ]
}
```

---

### Create New Goal

**Endpoint**: `POST /goals`

**Headers**:
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request**:
```json
{
  "name": "New Car",                           // Required
  "icon": "🚗",                                // Optional, default: "🎯"
  "description": "Save for a Tesla Model 3",   // Optional
  "total_contribution": 50000.00,              // Required (can also use "target_amount")
  "current_contribution": 5000.00,             // Optional, default: 0
  "deadline": "2026-12-31T23:59:59Z",         // Optional (ISO 8601 format)
  "color": "#FF5722",                          // Optional, default: "#4CAF50"
  "monthly_recurring_contribution": 1000.00    // Optional, default: 0
}
```

**Response** (201 Created):
```json
{
  "success": true,
  "message": "Goal 'New Car' created successfully",
  "goal": { /* full goal object */ }
}
```

---

### Update Goal

**Endpoint**: `PUT /goals/{goal_id}`

**Headers**:
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request** (all fields optional):
```json
{
  "name": "Updated Goal Name",
  "icon": "🎯",
  "description": "Updated description",
  "total_contribution": 60000.00,
  "current_contribution": 10000.00,
  "deadline": "2027-01-01T00:00:00Z",
  "color": "#9C27B0"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Goal updated successfully",
  "goal": { /* updated goal object */ }
}
```

---

### Delete Goal

**Endpoint**: `DELETE /goals/{goal_id}`

**Headers**:
```
Authorization: Bearer <access_token>
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Goal 'Emergency Fund' deleted successfully"
}
```

---

### Update Goal Progress (Legacy)

**Endpoint**: `PATCH /goals/{goal_id}/progress?current_amount=3000`

**Headers**:
```
Authorization: Bearer <access_token>
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Goal progress updated to $3000.00",
  "goal": { /* updated goal object */ }
}
```

---

## 💬 Smart Chat with AI - Enhanced Financial Coach

### Overview

The chat endpoint features an **intelligent, proactive financial coach** with:
- 🧠 **Memory System** - Remembers user context and long-term facts
- ⚡ **Proactive Suggestions** - Understands implied actions
- 🎯 **Context-Aware** - Knows your full financial state
- ✨ **Clean Responses** - Short, actionable messages (no escaped characters)

### Send Message

**Endpoint**: `POST /chat`

**Headers**:
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request**:
```json
{
  "message": "I have a debt of $2000 I need to handle",
  "thread_id": "thread_abc123"  // Optional: omit to create new thread
}
```

**Response** (200 OK):
```json
{
  "reply": "Got it, $2,000 in debt.\n\nDo you want me to add this as a tracked debt? I'll need:\n- Creditor name\n- Monthly payment amount\n- Due date\n\nThis will help me give you better financial insights.",
  "thread_id": "thread_abc123",
  "tool_calls": null
}
```

### Proactive Behavior Examples

The AI **understands implied actions** without explicit commands:

#### Example 1: Debt Mention
**User**: "I have a credit card debt of $2000"
**AI**: Offers to add it to debt tracking with required details

#### Example 2: Purchase Intent
**User**: "I want to buy a laptop, it costs $1500"
**AI**: Suggests creating a savings goal with target amount

#### Example 3: Overspending
**User**: "I overspent on food delivery this week"
**AI**: Offers to track patterns and set budget alerts

#### Example 4: Income Received
**User**: "I just got paid $3000"
**AI**: Suggests allocating funds across goals and expenses

### Thread Context (IMPORTANT!)

**Always pass `thread_id` for continued conversations:**

```javascript
// First message - creates new thread
const response1 = await sendMessage("Hello, I'm a freelancer");
const threadId = response1.thread_id; // Save this!

// Subsequent messages - use same thread_id
const response2 = await sendMessage("I overspend on food", threadId);
const response3 = await sendMessage("What do you know about me?", threadId);
```

**Why thread_id matters:**
- Maintains conversation context
- Enables memory retrieval
- Allows AI to reference past discussions
- Provides personalized advice

### Memory System

#### Short-term (Active) Memory
- Recent messages in thread
- Thread summary
- Current financial snapshot

#### Long-term (Passive) Memory
- User profile facts (e.g., "freelancer with irregular income")
- Financial preferences
- Spending patterns
- Long-term goals

**Example of Memory in Action:**
```
Day 1:
User: "I'm a student with part-time income"
AI: Saves to memory

Day 7:
User: "What do you know about me?"
AI: "You're a student with part-time income. I can help you with flexible budgeting."
```

### AI Capabilities

**Automated Actions:**
- ✅ Add/view expenses
- ✅ Create/update financial goals
- ✅ Add/track debts
- ✅ Get spending summaries
- ✅ Calculate debt payoff plans
- ✅ Provide personalized insights

**Smart Features:**
- 🔍 Understands context from past conversations
- 💡 Suggests relevant actions proactively
- 📊 Provides financial insights based on your data
- 🎯 Remembers your preferences and patterns
- ✨ Gives concise, actionable responses (not verbose)

### Mobile Integration Best Practices

#### 1. Thread Management
```javascript
// Store thread_id in local state or AsyncStorage
const [currentThreadId, setCurrentThreadId] = useState(null);

async function sendChatMessage(message) {
  const response = await PuldonAPI.sendMessage(message, currentThreadId);

  // Save thread_id for future messages
  if (!currentThreadId) {
    setCurrentThreadId(response.thread_id);
    await AsyncStorage.setItem('chat_thread_id', response.thread_id);
  }

  return response;
}
```

#### 2. Display Clean Responses
```javascript
// The API returns clean text (no \n escapes)
function ChatBubble({ message }) {
  return (
    <View style={styles.bubble}>
      <Text>{message}</Text>  {/* Just display directly */}
    </View>
  );
}
```

#### 3. Handle Tool Calls
```javascript
// Show which actions the AI performed
function ChatMessage({ reply, toolCalls }) {
  return (
    <View>
      <Text>{reply}</Text>
      {toolCalls && (
        <Text style={styles.meta}>
          Actions: {toolCalls.join(', ')}
        </Text>
      )}
    </View>
  );
}
```

#### 4. Typing Indicators
```javascript
// Show typing while waiting for AI response
const [isTyping, setIsTyping] = useState(false);

async function sendMessage(text) {
  setIsTyping(true);
  try {
    const response = await PuldonAPI.sendMessage(text, threadId);
    addMessageToChat(response);
  } finally {
    setIsTyping(false);
  }
}
```

#### 5. New Conversation Flow
```javascript
// Allow users to start fresh conversations
function startNewConversation() {
  setCurrentThreadId(null);
  await AsyncStorage.removeItem('chat_thread_id');
  clearChatMessages();
}
```

### Testing Proactive Behavior

**Test these messages in your mobile app:**

| Message | Expected AI Behavior |
|---------|---------------------|
| "I have a debt of $2000" | Offers to add to tracking |
| "I want to save for a MacBook" | Suggests creating goal |
| "I overspent this week" | Offers budget tracking |
| "I'm traveling next month" | Suggests travel budget |
| "I just got paid $3000" | Suggests fund allocation |

### Response Format Notes

**Clean Text Output:**
- No `\n` escape sequences (real newlines)
- No `\t` tab characters
- Bullet points use `-` or `*`
- Short paragraphs (2-3 sentences)

**Example Response Structure:**
```
Got it, $2,000 in debt.

Do you want me to add this to tracking? I'll need:
- Creditor name
- Monthly payment
- Due date
```

---

### Get Chat History

**Endpoint**: `GET /chat/history/{thread_id}?limit=20`

**Headers**:
```
Authorization: Bearer <access_token>
```

**Response** (200 OK):
```json
{
  "thread_id": "thread_abc123",
  "message_count": 4,
  "messages": [
    {
      "role": "user",
      "content": "How much did I spend on groceries?",
      "timestamp": "2025-01-15T10:00:00Z"
    },
    {
      "role": "assistant",
      "content": "You spent $150.00 on groceries this month.",
      "timestamp": "2025-01-15T10:00:01Z"
    }
  ]
}
```

---

### Speech to Text

**Endpoint**: `POST /chat/speech-to-text`

**Headers**:
```
Authorization: Bearer <access_token>
Content-Type: multipart/form-data
```

**Request**:
- Form data with field name: `file`
- Supported formats: audio/mpeg, audio/wav, audio/mp4, audio/m4a, audio/webm

**Response** (200 OK):
```json
{
  "transcript": "Add an expense of fifty dollars for groceries"
}
```

**Note**: Currently returns placeholder. Integrate with OpenAI Whisper or similar STT service in production.

---

### Clear Chat History

**Endpoint**: `POST /chat/clear?thread_id={thread_id}`

**Headers**:
```
Authorization: Bearer <access_token>
```

**Query Parameters**:
- `thread_id` (optional): If provided, clears specific thread. If omitted, clears all user threads.

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Chat thread thread_abc123 cleared successfully"
}
```

Or if clearing all:
```json
{
  "success": true,
  "message": "All chat history cleared (3 threads)",
  "cleared_threads": 3
}
```

---

## 💰 Expenses

### Add Expense

**Endpoint**: `POST /expenses`

**Headers**:
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request**:
```json
{
  "amount": 50.00,                              // Required
  "category": "groceries",                      // Required: see categories below
  "note": "Weekly shopping at Whole Foods",     // Optional
  "timestamp": "2025-01-15T14:30:00Z"          // Optional, defaults to now
}
```

**Expense Categories**:
- `groceries`
- `dining`
- `transportation`
- `utilities`
- `entertainment`
- `healthcare`
- `shopping`
- `rent`
- `other`

**Response** (201 Created):
```json
{
  "success": true,
  "message": "Expense of $50.00 recorded",
  "expense": {
    "id": "expense-uuid",
    "user_id": "user-uuid",
    "amount": 50.00,
    "category": "groceries",
    "note": "Weekly shopping at Whole Foods",
    "timestamp": "2025-01-15T14:30:00Z",
    "created_at": "2025-01-15T14:30:00Z"
  }
}
```

---

### List Expenses

**Endpoint**: `GET /expenses?category=groceries&limit=50`

**Headers**:
```
Authorization: Bearer <access_token>
```

**Query Parameters**:
- `category` (optional): Filter by category
- `limit` (optional): Max records (1-500), default: 100

**Response** (200 OK):
```json
[
  {
    "id": "expense-uuid-1",
    "user_id": "user-uuid",
    "amount": 50.00,
    "category": "groceries",
    "note": "Weekly shopping",
    "timestamp": "2025-01-15T14:30:00Z",
    "created_at": "2025-01-15T14:30:00Z"
  },
  {
    "id": "expense-uuid-2",
    "user_id": "user-uuid",
    "amount": 25.00,
    "category": "dining",
    "note": "Lunch",
    "timestamp": "2025-01-14T12:00:00Z",
    "created_at": "2025-01-14T12:00:00Z"
  }
]
```

---

### Get Spending Summary

**Endpoint**: `GET /expenses/summary?period=last_30d`

**Headers**:
```
Authorization: Bearer <access_token>
```

**Query Parameters**:
- `period` (optional): `last_7d`, `last_30d`, `this_month`, default: `last_30d`

**Response** (200 OK):
```json
{
  "user_id": "user-uuid",
  "period": "2024-12-16 to 2025-01-15",
  "total": 850.00,
  "by_category": {
    "groceries": 300.00,
    "dining": 200.00,
    "transportation": 150.00,
    "utilities": 100.00,
    "entertainment": 100.00
  },
  "transaction_count": 23
}
```

---

## 💳 Debts

### Add Debt

**Endpoint**: `POST /debts`

**Headers**:
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request**:
```json
{
  "creditor": "Chase Credit Card",      // Required
  "total_amount": 5000.00,              // Required
  "remaining_amount": 3500.00,          // Required
  "monthly_payment": 200.00,            // Required
  "due_date": 15                        // Required: day of month (1-31)
}
```

**Response** (201 Created):
```json
{
  "success": true,
  "message": "Debt to Chase Credit Card recorded",
  "debt": {
    "id": "debt-uuid",
    "user_id": "user-uuid",
    "creditor": "Chase Credit Card",
    "total_amount": 5000.00,
    "remaining_amount": 3500.00,
    "monthly_payment": 200.00,
    "due_date": 15,
    "created_at": "2025-01-15T10:00:00Z"
  }
}
```

---

### Get Debt Summary

**Endpoint**: `GET /debts/summary?month=2025-01`

**Headers**:
```
Authorization: Bearer <access_token>
```

**Query Parameters**:
- `month` (optional): YYYY-MM format, defaults to current month

**Response** (200 OK):
```json
{
  "user_id": "user-uuid",
  "month": "2025-01",
  "total_debt": 8500.00,
  "monthly_obligations": 450.00,
  "debts": [
    {
      "id": "debt-uuid-1",
      "user_id": "user-uuid",
      "creditor": "Chase Credit Card",
      "total_amount": 5000.00,
      "remaining_amount": 3500.00,
      "monthly_payment": 200.00,
      "due_date": 15,
      "created_at": "2025-01-01T10:00:00Z"
    },
    {
      "id": "debt-uuid-2",
      "user_id": "user-uuid",
      "creditor": "Student Loan",
      "total_amount": 20000.00,
      "remaining_amount": 5000.00,
      "monthly_payment": 250.00,
      "due_date": 1,
      "created_at": "2025-01-01T10:00:00Z"
    }
  ]
}
```

---

## ⚠️ Error Handling

### Common Error Codes

| Status Code | Meaning | Common Causes |
|-------------|---------|---------------|
| 400 | Bad Request | Invalid input data, missing required fields |
| 401 | Unauthorized | Missing token, invalid token, expired token |
| 404 | Not Found | Resource doesn't exist or doesn't belong to user |
| 500 | Internal Server Error | Backend error, database connection issue |

### Error Response Format

```json
{
  "detail": "Error message describing what went wrong"
}
```

### Token Expiration

When a token expires, you'll receive a 401 response:

```json
{
  "detail": "Could not validate credentials"
}
```

**Action**: Prompt user to sign in again and request new OTP.

---

## 📱 Mobile Implementation Examples

### iOS (Swift + URLSession)

```swift
import Foundation

class PuldonAPI {
    static let baseURL = "http://localhost:8000"

    // Sign In - Request OTP
    func requestOTP(phoneNumber: String, completion: @escaping (Result<OTPResponse, Error>) -> Void) {
        let url = URL(string: "\(Self.baseURL)/auth/signin/request-otp")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["phone_number": phoneNumber]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1)))
                return
            }

            if let otpResponse = try? JSONDecoder().decode(OTPResponse.self, from: data) {
                completion(.success(otpResponse))
            }
        }.resume()
    }

    // Verify OTP
    func verifyOTP(phoneNumber: String, otp: String, completion: @escaping (Result<TokenResponse, Error>) -> Void) {
        let url = URL(string: "\(Self.baseURL)/auth/signin/verify-otp")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["phone_number": phoneNumber, "otp": otp]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
               let tokenResponse = try? JSONDecoder().decode(TokenResponse.self, from: data) {
                // Store token in Keychain
                KeychainHelper.save(token: tokenResponse.accessToken)
                completion(.success(tokenResponse))
            }
        }.resume()
    }

    // Get Dashboard (Authenticated)
    func getDashboard(completion: @escaping (Result<Dashboard, Error>) -> Void) {
        guard let token = KeychainHelper.getToken() else {
            completion(.failure(NSError(domain: "No token", code: 401)))
            return
        }

        let url = URL(string: "\(Self.baseURL)/dashboard")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
               let dashboard = try? JSONDecoder().decode(Dashboard.self, from: data) {
                completion(.success(dashboard))
            }
        }.resume()
    }
}

// Models
struct OTPResponse: Codable {
    let message: String
    let otpCode: String?

    enum CodingKeys: String, CodingKey {
        case message
        case otpCode = "otp_code"
    }
}

struct TokenResponse: Codable {
    let accessToken: String
    let tokenType: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}

struct Dashboard: Codable {
    let netWorth: Double
    let notInvestedMoney: Double
    let insights: [String]
    let overview: [SectorOverview]

    enum CodingKeys: String, CodingKey {
        case netWorth = "net_worth"
        case notInvestedMoney = "not_invested_money"
        case insights, overview
    }
}

struct SectorOverview: Codable {
    let sector: String
    let portionPercent: Double

    enum CodingKeys: String, CodingKey {
        case sector
        case portionPercent = "portion_percent"
    }
}
```

---

### Android (Kotlin + Retrofit)

```kotlin
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.*

// API Interface
interface PuldonAPI {
    @POST("auth/signin/request-otp")
    suspend fun requestOTP(@Body request: OTPRequest): OTPResponse

    @POST("auth/signin/verify-otp")
    suspend fun verifyOTP(@Body request: VerifyOTPRequest): TokenResponse

    @GET("dashboard")
    suspend fun getDashboard(@Header("Authorization") token: String): Dashboard

    @GET("goals")
    suspend fun getGoals(@Header("Authorization") token: String): List<Goal>

    @POST("goals")
    suspend fun createGoal(
        @Header("Authorization") token: String,
        @Body goal: CreateGoalRequest
    ): GoalResponse

    @POST("chat")
    suspend fun sendMessage(
        @Header("Authorization") token: String,
        @Body message: ChatRequest
    ): ChatResponse
}

// Data Classes
data class OTPRequest(val phone_number: String)
data class OTPResponse(val message: String, val otp_code: String?)
data class VerifyOTPRequest(val phone_number: String, val otp: String)
data class TokenResponse(val access_token: String, val token_type: String)

data class Dashboard(
    val net_worth: Double,
    val not_invested_money: Double,
    val insights: List<String>,
    val overview: List<SectorOverview>
)

data class SectorOverview(val sector: String, val portion_percent: Double)

data class Goal(
    val id: String,
    val name: String,
    val icon: String?,
    val description: String?,
    val progress: Double,
    val current_contribution: Double,
    val total_contribution: Double,
    val days_left: Int?,
    val monthly_recurring_contribution: Double,
    val color: String?
)

// Retrofit Setup
object RetrofitClient {
    private const val BASE_URL = "http://localhost:8000/"

    val api: PuldonAPI by lazy {
        Retrofit.Builder()
            .baseUrl(BASE_URL)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(PuldonAPI::class.java)
    }
}

// Usage in ViewModel
class AuthViewModel : ViewModel() {
    fun signIn(phoneNumber: String, otp: String) {
        viewModelScope.launch {
            try {
                val response = RetrofitClient.api.verifyOTP(
                    VerifyOTPRequest(phoneNumber, otp)
                )

                // Save token to EncryptedSharedPreferences
                saveToken(response.access_token)

                _authState.value = AuthState.Success
            } catch (e: Exception) {
                _authState.value = AuthState.Error(e.message)
            }
        }
    }
}
```

---

### React Native (JavaScript/TypeScript)

```typescript
import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

const API_BASE_URL = 'http://localhost:8000';

// Axios instance with interceptor for auth
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add token to all requests
api.interceptors.request.use(async (config) => {
  const token = await AsyncStorage.getItem('access_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// API Methods
export const PuldonAPI = {
  // Auth
  async requestOTP(phoneNumber: string) {
    const response = await api.post('/auth/signin/request-otp', {
      phone_number: phoneNumber,
    });
    return response.data;
  },

  async verifyOTP(phoneNumber: string, otp: string) {
    const response = await api.post('/auth/signin/verify-otp', {
      phone_number: phoneNumber,
      otp: otp,
    });

    // Save token
    await AsyncStorage.setItem('access_token', response.data.access_token);

    return response.data;
  },

  async signUp(data: {
    phone_number: string;
    full_name: string;
    gender?: string;
    date_of_birth?: string;
    email?: string;
  }) {
    const response = await api.post('/auth/signup', data);
    return response.data;
  },

  // Dashboard
  async getDashboard() {
    const response = await api.get('/dashboard');
    return response.data;
  },

  // Goals
  async getGoals() {
    const response = await api.get('/goals');
    return response.data;
  },

  async createGoal(goal: {
    name: string;
    icon?: string;
    description?: string;
    total_contribution: number;
    current_contribution?: number;
    deadline?: string;
    color?: string;
  }) {
    const response = await api.post('/goals', goal);
    return response.data;
  },

  async deleteGoal(goalId: string) {
    const response = await api.delete(`/goals/${goalId}`);
    return response.data;
  },

  // Chat - Enhanced with memory system
  async sendMessage(message: string, threadId?: string) {
    const response = await api.post('/chat', {
      message,
      thread_id: threadId,  // Always pass for context continuity
    });
    return response.data;
    // Returns: { reply, thread_id, tool_calls }
  },

  async getChatHistory(threadId: string, limit: number = 20) {
    const response = await api.get(`/chat/history/${threadId}?limit=${limit}`);
    return response.data;
  },

  async clearChatHistory(threadId?: string) {
    const params = threadId ? `?thread_id=${threadId}` : '';
    const response = await api.post(`/chat/clear${params}`);
    return response.data;
  },

  // Logout
  async logout() {
    await AsyncStorage.removeItem('access_token');
  },
};

// ============================================================================
// Usage Examples
// ============================================================================

// Example 1: Sign In Screen
import { PuldonAPI } from './api';

function SignInScreen() {
  const [phone, setPhone] = useState('');
  const [otp, setOTP] = useState('');
  const [showOTPInput, setShowOTPInput] = useState(false);

  const handleRequestOTP = async () => {
    try {
      const response = await PuldonAPI.requestOTP(phone);
      Alert.alert('Success', response.message);
      setShowOTPInput(true);

      // In dev mode, auto-fill OTP
      if (response.otp_code) {
        setOTP(response.otp_code);
      }
    } catch (error) {
      Alert.alert('Error', error.message);
    }
  };

  const handleVerifyOTP = async () => {
    try {
      await PuldonAPI.verifyOTP(phone, otp);
      navigation.navigate('Dashboard');
    } catch (error) {
      Alert.alert('Error', 'Invalid OTP');
    }
  };

  return (
    <View>
      <TextInput
        value={phone}
        onChangeText={setPhone}
        placeholder="Phone Number"
      />
      <Button title="Request OTP" onPress={handleRequestOTP} />

      {showOTPInput && (
        <>
          <TextInput
            value={otp}
            onChangeText={setOTP}
            placeholder="Enter OTP"
          />
          <Button title="Verify" onPress={handleVerifyOTP} />
        </>
      )}
    </View>
  );
}

// Example 2: Enhanced Chat Screen with Memory
function ChatScreen() {
  const [messages, setMessages] = useState([]);
  const [inputText, setInputText] = useState('');
  const [threadId, setThreadId] = useState(null);
  const [isTyping, setIsTyping] = useState(false);

  // Load saved thread ID on mount
  useEffect(() => {
    loadThreadId();
  }, []);

  const loadThreadId = async () => {
    const savedThreadId = await AsyncStorage.getItem('chat_thread_id');
    if (savedThreadId) {
      setThreadId(savedThreadId);
      // Optionally load chat history
      const history = await PuldonAPI.getChatHistory(savedThreadId);
      setMessages(history.messages);
    }
  };

  const sendMessage = async () => {
    if (!inputText.trim()) return;

    // Add user message to UI
    const userMessage = {
      role: 'user',
      content: inputText,
      timestamp: new Date().toISOString(),
    };
    setMessages((prev) => [...prev, userMessage]);
    setInputText('');
    setIsTyping(true);

    try {
      // Send to API with thread context
      const response = await PuldonAPI.sendMessage(inputText, threadId);

      // Save thread ID for continuity
      if (!threadId) {
        setThreadId(response.thread_id);
        await AsyncStorage.setItem('chat_thread_id', response.thread_id);
      }

      // Add AI response to UI
      const aiMessage = {
        role: 'assistant',
        content: response.reply,
        timestamp: new Date().toISOString(),
        tool_calls: response.tool_calls,
      };
      setMessages((prev) => [...prev, aiMessage]);
    } catch (error) {
      Alert.alert('Error', 'Failed to send message');
    } finally {
      setIsTyping(false);
    }
  };

  const startNewConversation = async () => {
    setThreadId(null);
    setMessages([]);
    await AsyncStorage.removeItem('chat_thread_id');
  };

  return (
    <View style={styles.container}>
      {/* Header with new chat button */}
      <View style={styles.header}>
        <Text style={styles.title}>Financial Coach</Text>
        <TouchableOpacity onPress={startNewConversation}>
          <Text style={styles.newChatBtn}>New Chat</Text>
        </TouchableOpacity>
      </View>

      {/* Messages list */}
      <FlatList
        data={messages}
        keyExtractor={(item, index) => index.toString()}
        renderItem={({ item }) => (
          <View
            style={[
              styles.messageBubble,
              item.role === 'user' ? styles.userBubble : styles.aiBubble,
            ]}
          >
            <Text style={styles.messageText}>{item.content}</Text>
            {item.tool_calls && (
              <Text style={styles.toolCalls}>
                Actions: {item.tool_calls.join(', ')}
              </Text>
            )}
          </View>
        )}
      />

      {/* Typing indicator */}
      {isTyping && (
        <View style={styles.typingIndicator}>
          <Text>AI is typing...</Text>
        </View>
      )}

      {/* Input area */}
      <View style={styles.inputContainer}>
        <TextInput
          style={styles.input}
          value={inputText}
          onChangeText={setInputText}
          placeholder="Type a message..."
          multiline
        />
        <TouchableOpacity style={styles.sendButton} onPress={sendMessage}>
          <Text style={styles.sendButtonText}>Send</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f5f5f5' },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    padding: 16,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  title: { fontSize: 18, fontWeight: 'bold' },
  newChatBtn: { color: '#2196F3' },
  messageBubble: {
    margin: 8,
    padding: 12,
    borderRadius: 12,
    maxWidth: '80%',
  },
  userBubble: {
    alignSelf: 'flex-end',
    backgroundColor: '#2196F3',
  },
  aiBubble: {
    alignSelf: 'flex-start',
    backgroundColor: '#fff',
  },
  messageText: { fontSize: 16 },
  toolCalls: { fontSize: 12, color: '#666', marginTop: 4 },
  typingIndicator: { padding: 8, alignItems: 'center' },
  inputContainer: {
    flexDirection: 'row',
    padding: 8,
    backgroundColor: '#fff',
  },
  input: {
    flex: 1,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 20,
    paddingHorizontal: 16,
    paddingVertical: 8,
    marginRight: 8,
  },
  sendButton: {
    backgroundColor: '#2196F3',
    borderRadius: 20,
    paddingHorizontal: 20,
    justifyContent: 'center',
  },
  sendButtonText: { color: '#fff', fontWeight: 'bold' },
});

// Example 3: Dashboard Screen
function DashboardScreen() {
  const [dashboard, setDashboard] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadDashboard();
  }, []);

  const loadDashboard = async () => {
    try {
      const data = await PuldonAPI.getDashboard();
      setDashboard(data);
    } catch (error) {
      Alert.alert('Error', 'Failed to load dashboard');
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <ActivityIndicator />;

  return (
    <ScrollView style={styles.container}>
      <View style={styles.card}>
        <Text style={styles.label}>Net Worth</Text>
        <Text style={styles.value}>${dashboard.net_worth.toFixed(2)}</Text>
      </View>

      <View style={styles.card}>
        <Text style={styles.label}>Liquid Cash</Text>
        <Text style={styles.value}>
          ${dashboard.not_invested_money.toFixed(2)}
        </Text>
      </View>

      <View style={styles.card}>
        <Text style={styles.sectionTitle}>Insights</Text>
        {dashboard.insights.map((insight, index) => (
          <Text key={index} style={styles.insight}>
            • {insight}
          </Text>
        ))}
      </View>

      <View style={styles.card}>
        <Text style={styles.sectionTitle}>Portfolio Breakdown</Text>
        {dashboard.overview.map((sector, index) => (
          <View key={index} style={styles.sectorRow}>
            <Text>{sector.sector}</Text>
            <Text>{sector.portion_percent.toFixed(1)}%</Text>
          </View>
        ))}
      </View>
    </ScrollView>
  );
}
```

---

## 🧪 Testing

### Postman Collection

Import this environment:

```json
{
  "name": "Puldon API",
  "values": [
    {
      "key": "base_url",
      "value": "http://localhost:8000",
      "enabled": true
    },
    {
      "key": "access_token",
      "value": "",
      "enabled": true
    }
  ]
}
```

After signing in, set `access_token` variable from the response.

---

## 🔒 Security Best Practices

1. **Token Storage**:
   - iOS: Use Keychain
   - Android: Use EncryptedSharedPreferences
   - React Native: Use react-native-keychain

2. **HTTPS Only**: Use HTTPS in production

3. **Token Refresh**: Implement token refresh when approaching expiration (currently 7 days)

4. **OTP Security**:
   - Don't log OTPs in production
   - Limit OTP request rate (implement on mobile side)
   - OTP expires in 5 minutes

5. **Input Validation**: Validate phone numbers on client side (E.164 format)

---

## 📞 Support

**API Documentation**: http://localhost:8000/docs (Swagger UI)

**API Info Endpoint**: http://localhost:8000/api/info

**Questions**: Contact backend team

---

## 🚀 Quick Start Checklist

- [ ] Get API base URL from backend team
- [ ] Implement sign up flow
- [ ] Implement sign in flow (request OTP → verify OTP)
- [ ] Store JWT token securely
- [ ] Test authenticated endpoints with token
- [ ] Implement token expiration handling
- [ ] Test all CRUD operations for goals
- [ ] Integrate chat functionality
- [ ] Handle error responses
- [ ] Test on both iOS and Android

---

**Last Updated**: January 2025
**API Version**: 1.0.0
