# 📖 Puldon API - Complete Documentation

## Table of Contents
- [Overview](#overview)
- [Base URL](#base-url)
- [Authentication](#authentication)
- [API Endpoints](#api-endpoints)
  - [Authentication](#authentication-endpoints)
  - [Dashboard](#dashboard-endpoints)
  - [Chat](#chat-endpoints)
  - [Expenses](#expenses-endpoints)
  - [Goals](#goals-endpoints)
  - [Debts](#debts-endpoints)
- [Error Handling](#error-handling)
- [Rate Limiting](#rate-limiting)
- [Code Examples](#code-examples)

---

## Overview

Puldon is an AI-powered personal finance assistant API that helps users manage their finances through conversational AI, track expenses, set financial goals, and manage debts.

**Version:** 1.0.0  
**Authentication:** JWT with Phone + OTP  
**Content-Type:** application/json

---

## Base URL

```
http://151.245.140.91:8000
```

### Interactive Documentation
- **Swagger UI:** http://151.245.140.91:8000/docs
- **ReDoc:** http://151.245.140.91:8000/redoc

---

## Authentication

Puldon uses JWT (JSON Web Token) based authentication with phone number and OTP verification.

### Authentication Flow

```
1. Sign Up (First Time Users)
   ↓
2. Request OTP
   ↓
3. Verify OTP & Get Token
   ↓
4. Use Token in All Subsequent Requests
   Header: Authorization: Bearer {token}
```

### Token Usage

Include the JWT token in the Authorization header for all protected endpoints:

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## API Endpoints

# Authentication Endpoints

## 1. Sign Up

Register a new user with phone number and profile information.

**Endpoint:** `POST /auth/signup`  
**Authentication:** Not required

### Request Body

```json
{
  "phone_number": "+1234567890",
  "full_name": "John Doe",
  "gender": "male",
  "date_of_birth": "1990-01-15",
  "email": "john@example.com",
  "image_id": null
}
```

### Request Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| phone_number | string | Yes | Phone number with country code (10-20 chars) |
| full_name | string | Yes | User's full name (1-200 chars) |
| gender | string | No | Gender (max 50 chars) |
| date_of_birth | date | No | Date of birth (YYYY-MM-DD) |
| email | string | No | Email address (valid email format) |
| image_id | string | No | Avatar/profile image identifier |

### Response

**Status:** `200 OK`

```json
{
  "success": true,
  "message": "User registered successfully. Please sign in to continue.",
  "user_id": "uuid-here"
}
```

### Error Responses

**400 Bad Request** - Phone number already registered
```json
{
  "detail": "Phone number already registered"
}
```

**500 Internal Server Error**
```json
{
  "detail": "Failed to register user: {error message}"
}
```

---

## 2. Request OTP

Request an OTP code for sign in.

**Endpoint:** `POST /auth/signin/request-otp`  
**Authentication:** Not required

### Request Body

```json
{
  "phone_number": "+1234567890"
}
```

### Request Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| phone_number | string | Yes | Registered phone number (10-20 chars) |

### Response

**Status:** `200 OK`

**Development Mode:**
```json
{
  "message": "OTP sent to +1234567890",
  "otp_code": "123456"
}
```

**Production Mode:**
```json
{
  "message": "OTP sent to +1234567890"
}
```

> **Note:** In development mode, the OTP is returned in the response. In production, it would be sent via SMS.

### OTP Details
- **Length:** 6 digits
- **Expiry:** 5 minutes
- **Type:** Numeric

### Error Responses

**404 Not Found** - Phone number not registered
```json
{
  "detail": "Phone number not registered. Please sign up first."
}
```

---

## 3. Verify OTP & Get Token

Verify OTP code and receive JWT access token.

**Endpoint:** `POST /auth/signin/verify-otp`  
**Authentication:** Not required

### Request Body

```json
{
  "phone_number": "+1234567890",
  "otp": "123456"
}
```

### Request Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| phone_number | string | Yes | Phone number (10-20 chars) |
| otp | string | Yes | OTP code (4-6 chars) |

### Response

**Status:** `200 OK`

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyLWlkIiwicGhvbmUiOiIrMTIzNDU2Nzg5MCIsImV4cCI6MTcwMDAwMDAwMH0.signature",
  "token_type": "bearer"
}
```

### Token Information
- **Type:** JWT (JSON Web Token)
- **Algorithm:** HS256
- **Expiration:** Check token payload
- **Usage:** Include in Authorization header as `Bearer {token}`

### Error Responses

**401 Unauthorized** - Invalid or expired OTP
```json
{
  "detail": "Invalid or expired OTP code"
}
```

**404 Not Found** - User not found
```json
{
  "detail": "User not found"
}
```

---

## 4. Get Profile

Get the current user's profile information.

**Endpoint:** `GET /auth/profile`  
**Authentication:** Required

### Headers

```
Authorization: Bearer {your_jwt_token}
```

### Response

**Status:** `200 OK`

```json
{
  "id": "user-uuid",
  "phone_number": "+1234567890",
  "full_name": "John Doe",
  "gender": "male",
  "date_of_birth": "1990-01-15",
  "email": "john@example.com",
  "image_id": null,
  "created_at": "2025-01-01T00:00:00Z"
}
```

### Error Responses

**401 Unauthorized** - Missing or invalid token
```json
{
  "detail": "Not authenticated"
}
```

---

## 5. Update Profile

Update the current user's profile information.

**Endpoint:** `PATCH /auth/profile`  
**Authentication:** Required

### Request Body

```json
{
  "full_name": "John Smith",
  "gender": "male",
  "date_of_birth": "1990-01-15",
  "email": "johnsmith@example.com",
  "image_id": "avatar-123"
}
```

### Request Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| full_name | string | No | User's full name (1-200 chars) |
| gender | string | No | Gender (max 50 chars) |
| date_of_birth | date | No | Date of birth (YYYY-MM-DD) |
| email | string | No | Email address |
| image_id | string | No | Avatar/profile image identifier |

> **Note:** Only provided fields will be updated. Null/missing fields are ignored.

### Response

**Status:** `200 OK`

```json
{
  "success": true,
  "message": "Profile updated successfully",
  "user": {
    "id": "user-uuid",
    "phone_number": "+1234567890",
    "full_name": "John Smith",
    "gender": "male",
    "date_of_birth": "1990-01-15",
    "email": "johnsmith@example.com",
    "image_id": "avatar-123",
    "created_at": "2025-01-01T00:00:00Z",
    "updated_at": "2025-01-15T10:30:00Z"
  }
}
```

---

## 6. Request Phone Update OTP

Request OTP to update phone number.

**Endpoint:** `POST /auth/profile/phone/request-otp`  
**Authentication:** Required

### Request Body

```json
{
  "new_phone_number": "+0987654321"
}
```

### Response

**Status:** `200 OK`

**Development Mode:**
```json
{
  "message": "OTP sent to +0987654321",
  "otp_code": "654321"
}
```

### Error Responses

**400 Bad Request** - Phone number already in use
```json
{
  "detail": "Phone number already in use"
}
```

---

## 7. Verify Phone Update OTP

Verify OTP and update phone number.

**Endpoint:** `POST /auth/profile/phone/verify-otp`  
**Authentication:** Required

### Request Body

```json
{
  "new_phone_number": "+0987654321",
  "otp": "654321"
}
```

### Response

**Status:** `200 OK`

```json
{
  "success": true,
  "message": "Phone number updated successfully",
  "new_phone_number": "+0987654321"
}
```

### Error Responses

**401 Unauthorized** - Invalid or expired OTP
```json
{
  "detail": "Invalid or expired OTP code"
}
```

---

# Dashboard Endpoints

## Get Dashboard

Get financial dashboard overview for the current user.

**Endpoint:** `GET /dashboard`  
**Authentication:** Required

### Headers

```
Authorization: Bearer {your_jwt_token}
```

### Response

**Status:** `200 OK`

```json
{
  "net_worth": 50000.00,
  "not_invested_money": 15000.00,
  "insights": [
    "Your debt is 10.5% of your savings. Great job!",
    "You're 65.3% towards your 3 active goal(s). Keep it up!",
    "Your net worth is positive at $50,000.00. Keep building your wealth!"
  ],
  "overview": [
    {
      "sector": "savings",
      "portion_percent": 75.5
    },
    {
      "sector": "debt",
      "portion_percent": 24.5
    }
  ]
}
```

### Response Schema

| Field | Type | Description |
|-------|------|-------------|
| net_worth | float | Total net worth (assets - liabilities) |
| not_invested_money | float | Cash/liquid assets not in investments |
| insights | array[string] | AI-generated insights and recommendations |
| overview | array[object] | Sector breakdown of portfolio |

### Overview Object

| Field | Type | Description |
|-------|------|-------------|
| sector | string | Sector name (e.g., "savings", "debt", "cash") |
| portion_percent | float | Percentage (0-100) |

### Dashboard Calculation Logic

- **Net Worth** = Total Savings - Total Debt
- **Not Invested Money** = Total Savings (simplified, no investment tracking yet)
- **Insights** generated based on:
  - Debt-to-savings ratio
  - Goal progress
  - Monthly spending patterns
  - Overall financial health

---

# Chat Endpoints

## 1. Send Chat Message

Main conversational endpoint for Puldon AI - Smart Financial Coach.

**Endpoint:** `POST /chat`  
**Authentication:** Required

### Request Body

```json
{
  "thread_id": null,
  "message": "I just spent $42 on groceries"
}
```

### Request Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| thread_id | string | No | Chat thread ID (creates new if not provided) |
| message | string | Yes | User's message (min 1 char) |

### Response

**Status:** `200 OK`

```json
{
  "reply": "Got it! I've recorded $42.00 for groceries. Your total grocery spending this month is now $156.00.",
  "thread_id": "thread_abc123xyz",
  "tool_calls": ["add_expense"]
}
```

### Response Schema

| Field | Type | Description |
|-------|------|-------------|
| reply | string | AI assistant's response |
| thread_id | string | Thread ID for this conversation |
| tool_calls | array[string] | List of tools/functions used (optional) |

### Available Tools

The AI can execute the following tools:
- `add_expense` - Record an expense
- `add_goal` - Create a financial goal
- `update_goal` - Update goal progress
- `add_debt` - Record a debt
- `get_spending_summary` - Get spending statistics
- `get_goal_progress` - Get goal progress
- `get_financial_snapshot` - Get overall financial overview

### Chat Pipeline (11 Steps)

1. Resolve thread (create if needed)
2. Save user message
3. Build active memory context
4. Retrieve passive memories (vector search)
5. Build enriched LLM prompt
6. LLM selects and executes tools
7. LLM generates final reply
8. Save assistant reply
9. Update thread summary
10. Extract and save new memories
11. Return response

### Example Conversations

**Track Expense:**
```json
// Request
{
  "message": "Paid $120 for dinner tonight"
}

// Response
{
  "reply": "I've recorded your $120 dinner expense. Looks like you're enjoying dining out this month!",
  "thread_id": "thread_xyz",
  "tool_calls": ["add_expense"]
}
```

**Set Goal:**
```json
// Request
{
  "message": "I want to save $10,000 for a vacation by December"
}

// Response
{
  "reply": "Great goal! I've created your vacation savings goal of $10,000 with a deadline of December 2025. That's about $833 per month if you start now.",
  "thread_id": "thread_xyz",
  "tool_calls": ["add_goal", "calculate_monthly_target"]
}
```

**Financial Advice:**
```json
// Request
{
  "message": "How am I doing financially this month?"
}

// Response
{
  "reply": "You're doing well! You've spent $856 so far this month, with groceries being your biggest category at $342. You've saved $500 towards your goals, and you're on track to meet your emergency fund target.",
  "thread_id": "thread_xyz",
  "tool_calls": ["get_spending_summary", "get_goal_progress"]
}
```

---

## 2. Get Chat History

Retrieve chat history for a specific thread.

**Endpoint:** `GET /chat/history/{thread_id}`  
**Authentication:** Required

### URL Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| thread_id | string | Yes | Thread identifier |

### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| limit | integer | 20 | Maximum number of messages to retrieve |

### Example Request

```
GET /chat/history/thread_abc123?limit=50
Authorization: Bearer {your_token}
```

### Response

**Status:** `200 OK`

```json
{
  "thread_id": "thread_abc123",
  "message_count": 8,
  "messages": [
    {
      "role": "user",
      "content": "I just spent $42 on groceries",
      "timestamp": "2025-01-15T10:30:00Z"
    },
    {
      "role": "assistant",
      "content": "Got it! I've recorded $42.00 for groceries.",
      "timestamp": "2025-01-15T10:30:02Z"
    },
    {
      "role": "user",
      "content": "How much have I spent this month?",
      "timestamp": "2025-01-15T11:00:00Z"
    },
    {
      "role": "assistant",
      "content": "This month you've spent $523.50 across all categories...",
      "timestamp": "2025-01-15T11:00:03Z"
    }
  ]
}
```

---

## 3. Speech to Text

Convert speech audio to text transcript (placeholder implementation).

**Endpoint:** `POST /chat/speech-to-text`  
**Authentication:** Required  
**Content-Type:** multipart/form-data

### Request

```http
POST /chat/speech-to-text
Authorization: Bearer {your_token}
Content-Type: multipart/form-data

file: [audio file]
```

### Supported Audio Formats

- `audio/mpeg` (.mp3)
- `audio/wav` (.wav)
- `audio/mp4` (.mp4)
- `audio/m4a` (.m4a)
- `audio/webm` (.webm)

### Response

**Status:** `200 OK`

```json
{
  "transcript": "I just spent forty two dollars on groceries"
}
```

> **Note:** This is currently a placeholder implementation. Integration with services like OpenAI Whisper, Google Speech-to-Text, or AWS Transcribe is recommended.

### Integration Example (OpenAI Whisper)

```python
from openai import OpenAI

client = OpenAI()
transcript = client.audio.transcriptions.create(
    model="whisper-1",
    file=audio_content
)
```

---

## 4. Clear Chat History

Clear chat history for the current user.

**Endpoint:** `POST /chat/clear`  
**Authentication:** Required

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| thread_id | string | No | Thread ID to clear (if None, clears all) |

### Example Requests

**Clear Specific Thread:**
```http
POST /chat/clear?thread_id=thread_abc123
Authorization: Bearer {your_token}
```

**Clear All Threads:**
```http
POST /chat/clear
Authorization: Bearer {your_token}
```

### Response

**Status:** `200 OK`

**Single Thread:**
```json
{
  "success": true,
  "message": "Chat thread thread_abc123 cleared successfully"
}
```

**All Threads:**
```json
{
  "success": true,
  "message": "All chat history cleared (3 threads)",
  "cleared_threads": 3
}
```

### Error Responses

**404 Not Found** - Thread not found or access denied
```json
{
  "detail": "Thread not found or access denied"
}
```

---

# Expenses Endpoints

## 1. Add Expense

Add a new expense record.

**Endpoint:** `POST /expenses`  
**Authentication:** Required

### Request Body

```json
{
  "amount": 42.50,
  "category": "groceries",
  "note": "Weekly grocery shopping at Whole Foods",
  "timestamp": "2025-01-15T10:30:00Z"
}
```

### Request Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| amount | float | Yes | Expense amount (must be positive) |
| category | string | Yes | Expense category (see categories below) |
| note | string | No | Optional note (max 500 chars) |
| timestamp | datetime | No | Expense timestamp (defaults to now) |

### Expense Categories

- `groceries`
- `dining`
- `transportation`
- `utilities`
- `entertainment`
- `healthcare`
- `shopping`
- `rent`
- `other`

### Response

**Status:** `201 Created`

```json
{
  "success": true,
  "message": "Expense of $42.50 recorded",
  "expense": {
    "id": "expense-uuid",
    "user_id": "user-uuid",
    "amount": 42.50,
    "category": "groceries",
    "note": "Weekly grocery shopping at Whole Foods",
    "timestamp": "2025-01-15T10:30:00Z",
    "created_at": "2025-01-15T10:30:00Z"
  }
}
```

---

## 2. Get Expenses

Get expense records with optional filtering.

**Endpoint:** `GET /expenses`  
**Authentication:** Required

### Query Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| category | string | No | None | Filter by category |
| limit | integer | No | 100 | Max records (1-500) |

### Example Requests

**Get All Expenses:**
```
GET /expenses
Authorization: Bearer {your_token}
```

**Filter by Category:**
```
GET /expenses?category=groceries&limit=50
Authorization: Bearer {your_token}
```

### Response

**Status:** `200 OK`

```json
[
  {
    "id": "expense-uuid-1",
    "user_id": "user-uuid",
    "amount": 42.50,
    "category": "groceries",
    "note": "Weekly grocery shopping",
    "timestamp": "2025-01-15T10:30:00Z",
    "created_at": "2025-01-15T10:30:00Z"
  },
  {
    "id": "expense-uuid-2",
    "user_id": "user-uuid",
    "amount": 18.99,
    "category": "groceries",
    "note": "Fresh produce",
    "timestamp": "2025-01-14T15:20:00Z",
    "created_at": "2025-01-14T15:20:00Z"
  }
]
```

---

## 3. Get Spending Summary

Get spending summary for a specified time period.

**Endpoint:** `GET /expenses/summary`  
**Authentication:** Required

### Query Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| period | string | No | last_30d | Time period |

### Supported Periods

- `last_7d` - Last 7 days
- `last_30d` - Last 30 days
- `this_month` - Current calendar month
- `last_month` - Previous calendar month
- `this_year` - Current calendar year

### Example Request

```
GET /expenses/summary?period=this_month
Authorization: Bearer {your_token}
```

### Response

**Status:** `200 OK`

```json
{
  "user_id": "user-uuid",
  "period": "this_month",
  "total": 1256.75,
  "by_category": {
    "groceries": 342.50,
    "dining": 245.00,
    "transportation": 150.25,
    "utilities": 320.00,
    "entertainment": 85.00,
    "shopping": 114.00
  },
  "transaction_count": 28
}
```

### Response Schema

| Field | Type | Description |
|-------|------|-------------|
| user_id | string | User identifier |
| period | string | Time period queried |
| total | float | Total spending amount |
| by_category | object | Breakdown by category |
| transaction_count | integer | Number of transactions |

---

# Goals Endpoints

## 1. List Goals

Get all financial goals for the current user.

**Endpoint:** `GET /goals`  
**Authentication:** Required

### Response

**Status:** `200 OK`

```json
[
  {
    "id": "goal-uuid-1",
    "name": "Emergency Fund",
    "icon": "💰",
    "description": "Save for emergencies",
    "progress": 65.5,
    "current_contribution": 6550.00,
    "total_contribution": 10000.00,
    "days_left": 245,
    "monthly_recurring_contribution": 500.00,
    "color": "#4CAF50"
  },
  {
    "id": "goal-uuid-2",
    "name": "Vacation to Hawaii",
    "icon": "🏝️",
    "description": "Dream vacation savings",
    "progress": 42.3,
    "current_contribution": 2115.00,
    "total_contribution": 5000.00,
    "days_left": 180,
    "monthly_recurring_contribution": 300.00,
    "color": "#2196F3"
  }
]
```

### Response Schema

| Field | Type | Description |
|-------|------|-------------|
| id | string | Goal identifier |
| name | string | Goal name |
| icon | string | Emoji icon |
| description | string | Goal description |
| progress | float | Progress percentage (0-100) |
| current_contribution | float | Current saved amount |
| total_contribution | float | Target amount |
| days_left | integer | Days until deadline (null if no deadline) |
| monthly_recurring_contribution | float | Monthly contribution amount |
| color | string | Color code for UI |

---

## 2. Get Goal Detail

Get detailed information for a specific goal with contribution history.

**Endpoint:** `GET /goals/{goal_id}`  
**Authentication:** Required

### URL Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| goal_id | string | Yes | Goal identifier |

### Example Request

```
GET /goals/goal-uuid-1
Authorization: Bearer {your_token}
```

### Response

**Status:** `200 OK`

```json
{
  "id": "goal-uuid-1",
  "name": "Emergency Fund",
  "icon": "💰",
  "description": "Save for emergencies",
  "current_contribution": 6550.00,
  "total_contribution": 10000.00,
  "days_left": 245,
  "monthly_recurring_contribution": 500.00,
  "color": "#4CAF50",
  "contribution_history": [
    {
      "amount": 500.00,
      "date": "2025-01-15",
      "currency_type": "USD"
    },
    {
      "amount": 500.00,
      "date": "2024-12-15",
      "currency_type": "USD"
    },
    {
      "amount": 1000.00,
      "date": "2024-11-15",
      "currency_type": "USD"
    }
  ]
}
```

### Error Responses

**404 Not Found** - Goal not found
```json
{
  "detail": "Goal not found"
}
```

---

## 3. Create Goal

Create a new financial goal.

**Endpoint:** `POST /goals`  
**Authentication:** Required

### Request Body

```json
{
  "name": "Emergency Fund",
  "icon": "💰",
  "description": "Save for emergencies",
  "total_contribution": 10000.00,
  "current_contribution": 0.00,
  "deadline": "2025-12-31T00:00:00Z",
  "color": "#4CAF50",
  "monthly_recurring_contribution": 500.00
}
```

### Request Schema

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| name | string | Yes | - | Goal name (1-200 chars) |
| icon | string | No | 🎯 | Emoji icon (max 10 chars) |
| description | string | No | null | Goal description (max 1000 chars) |
| total_contribution | float | Yes | - | Target amount (must be positive) |
| current_contribution | float | No | 0.0 | Current saved amount |
| deadline | datetime | No | null | Target deadline |
| color | string | No | #4CAF50 | Color code (max 20 chars) |
| monthly_recurring_contribution | float | No | 0.0 | Monthly contribution amount |

> **Note:** You can use either `total_contribution` or `target_amount` (alias).

### Response

**Status:** `201 Created`

```json
{
  "success": true,
  "message": "Goal 'Emergency Fund' created successfully",
  "goal": {
    "id": "goal-uuid",
    "user_id": "user-uuid",
    "name": "Emergency Fund",
    "icon": "💰",
    "description": "Save for emergencies",
    "target_amount": 10000.00,
    "current_amount": 0.00,
    "deadline": "2025-12-31T00:00:00Z",
    "color": "#4CAF50",
    "monthly_recurring_contribution": 500.00,
    "status": "active",
    "created_at": "2025-01-15T10:30:00Z"
  }
}
```

---

## 4. Update Goal

Update an existing goal.

**Endpoint:** `PUT /goals/{goal_id}`  
**Authentication:** Required

### URL Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| goal_id | string | Yes | Goal identifier |

### Request Body

```json
{
  "name": "Updated Emergency Fund",
  "current_contribution": 7050.00,
  "monthly_recurring_contribution": 600.00
}
```

### Request Schema

All fields are optional. Only provided fields will be updated.

| Field | Type | Description |
|-------|------|-------------|
| name | string | Goal name (1-200 chars) |
| icon | string | Emoji icon (max 10 chars) |
| description | string | Goal description (max 1000 chars) |
| total_contribution | float | Target amount |
| current_contribution | float | Current saved amount |
| deadline | datetime | Target deadline |
| color | string | Color code |

### Response

**Status:** `200 OK`

```json
{
  "success": true,
  "message": "Goal updated successfully",
  "goal": {
    "id": "goal-uuid",
    "user_id": "user-uuid",
    "name": "Updated Emergency Fund",
    "icon": "💰",
    "description": "Save for emergencies",
    "target_amount": 10000.00,
    "current_amount": 7050.00,
    "deadline": "2025-12-31T00:00:00Z",
    "color": "#4CAF50",
    "monthly_recurring_contribution": 600.00,
    "status": "active",
    "created_at": "2025-01-01T00:00:00Z",
    "updated_at": "2025-01-15T10:30:00Z"
  }
}
```

---

## 5. Delete Goal

Delete a goal and all associated contribution history.

**Endpoint:** `DELETE /goals/{goal_id}`  
**Authentication:** Required

### URL Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| goal_id | string | Yes | Goal identifier |

### Response

**Status:** `200 OK`

```json
{
  "success": true,
  "message": "Goal 'Emergency Fund' deleted successfully"
}
```

### Error Responses

**404 Not Found**
```json
{
  "detail": "Goal not found"
}
```

---

## 6. Update Goal Progress (Legacy)

Update the current saved amount for a goal.

**Endpoint:** `PATCH /goals/{goal_id}/progress`  
**Authentication:** Required

> **Note:** This is a legacy endpoint. Consider using `PUT /goals/{goal_id}` instead.

### URL Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| goal_id | string | Yes | Goal identifier |

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| current_amount | float | Yes | New current amount (>= 0) |

### Example Request

```
PATCH /goals/goal-uuid-1/progress?current_amount=7500.00
Authorization: Bearer {your_token}
```

### Response

**Status:** `200 OK`

```json
{
  "success": true,
  "message": "Goal progress updated to $7500.00",
  "goal": {
    "id": "goal-uuid-1",
    "current_amount": 7500.00,
    "target_amount": 10000.00
  }
}
```

---

# Debts Endpoints

## 1. Add Debt

Add a new debt record.

**Endpoint:** `POST /debts`  
**Authentication:** Required

### Request Body

```json
{
  "creditor": "Chase Credit Card",
  "total_amount": 5000.00,
  "remaining_amount": 3250.00,
  "monthly_payment": 250.00,
  "due_date": 15
}
```

### Request Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| creditor | string | Yes | Creditor name (1-200 chars) |
| total_amount | float | Yes | Total/original debt amount |
| remaining_amount | float | Yes | Current remaining amount |
| monthly_payment | float | Yes | Monthly payment amount |
| due_date | integer | Yes | Day of month payment is due (1-31) |

### Response

**Status:** `201 Created`

```json
{
  "success": true,
  "message": "Debt to Chase Credit Card recorded",
  "debt": {
    "id": "debt-uuid",
    "user_id": "user-uuid",
    "creditor": "Chase Credit Card",
    "total_amount": 5000.00,
    "remaining_amount": 3250.00,
    "monthly_payment": 250.00,
    "due_date": 15,
    "created_at": "2025-01-15T10:30:00Z"
  }
}
```

---

## 2. Get Debt Summary

Get debt summary for the current user.

**Endpoint:** `GET /debts/summary`  
**Authentication:** Required

### Query Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| month | string | No | Current | Month in YYYY-MM format |

### Example Requests

**Current Month:**
```
GET /debts/summary
Authorization: Bearer {your_token}
```

**Specific Month:**
```
GET /debts/summary?month=2025-01
Authorization: Bearer {your_token}
```

### Response

**Status:** `200 OK`

```json
{
  "user_id": "user-uuid",
  "month": "2025-01",
  "total_debt": 8750.00,
  "monthly_obligations": 650.00,
  "debts": [
    {
      "id": "debt-uuid-1",
      "user_id": "user-uuid",
      "creditor": "Chase Credit Card",
      "total_amount": 5000.00,
      "remaining_amount": 3250.00,
      "monthly_payment": 250.00,
      "due_date": 15,
      "created_at": "2025-01-01T00:00:00Z"
    },
    {
      "id": "debt-uuid-2",
      "user_id": "user-uuid",
      "creditor": "Student Loan",
      "total_amount": 20000.00,
      "remaining_amount": 5500.00,
      "monthly_payment": 400.00,
      "due_date": 1,
      "created_at": "2024-09-01T00:00:00Z"
    }
  ]
}
```

### Response Schema

| Field | Type | Description |
|-------|------|-------------|
| user_id | string | User identifier |
| month | string | Month queried (YYYY-MM) |
| total_debt | float | Total remaining debt |
| monthly_obligations | float | Sum of monthly payments |
| debts | array | List of all debt records |

---

# Error Handling

## Standard Error Response Format

All error responses follow this structure:

```json
{
  "detail": "Error message describing what went wrong"
}
```

## HTTP Status Codes

| Code | Meaning | Description |
|------|---------|-------------|
| 200 | OK | Request succeeded |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Invalid request data |
| 401 | Unauthorized | Missing or invalid authentication |
| 404 | Not Found | Resource not found |
| 500 | Internal Server Error | Server-side error |

## Common Error Scenarios

### 401 Unauthorized

**Cause:** Missing, invalid, or expired JWT token

**Example Response:**
```json
{
  "detail": "Not authenticated"
}
```

**Solution:** 
1. Sign in again to get a new token
2. Ensure token is included in Authorization header
3. Check token hasn't expired

### 400 Bad Request

**Cause:** Invalid request data

**Example Response:**
```json
{
  "detail": "Phone number already registered"
}
```

**Solutions:**
- Validate input data before sending
- Check required fields are provided
- Ensure data types match schema
- Verify value constraints (min/max, positive numbers, etc.)

### 404 Not Found

**Cause:** Resource doesn't exist or user doesn't have access

**Example Response:**
```json
{
  "detail": "Goal not found"
}
```

**Solutions:**
- Verify resource ID is correct
- Ensure resource belongs to authenticated user
- Check resource hasn't been deleted

### 500 Internal Server Error

**Cause:** Server-side error

**Example Response:**
```json
{
  "detail": "Failed to create goal: database connection error"
}
```

**Solutions:**
- Retry the request
- Check server logs
- Contact support if persists

---

# Rate Limiting

Currently, there are no explicit rate limits enforced. However, best practices recommend:

- **Authentication Endpoints:** Max 5 requests per minute per IP
- **Chat Endpoint:** Max 60 requests per minute per user
- **Other Endpoints:** Max 120 requests per minute per user

These are guidelines; actual implementation may vary.

---

# Code Examples

## JavaScript / React Native

### Setup

```javascript
// config.js
export const API_BASE_URL = 'http://151.245.140.91:8000';

// api.js
import AsyncStorage from '@react-native-async-storage/async-storage';
import { API_BASE_URL } from './config';

class PuldonAPI {
  constructor() {
    this.baseURL = API_BASE_URL;
  }

  async getToken() {
    return await AsyncStorage.getItem('jwt_token');
  }

  async setToken(token) {
    await AsyncStorage.setItem('jwt_token', token);
  }

  async clearToken() {
    await AsyncStorage.removeItem('jwt_token');
  }

  async request(endpoint, options = {}) {
    const token = await this.getToken();
    
    const headers = {
      'Content-Type': 'application/json',
      ...options.headers,
    };

    if (token && !options.skipAuth) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const response = await fetch(`${this.baseURL}${endpoint}`, {
      ...options,
      headers,
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.detail || 'Request failed');
    }

    return await response.json();
  }
}

export default new PuldonAPI();
```

### Authentication

```javascript
// Sign Up
async function signUp(phoneNumber, fullName, email) {
  try {
    const response = await api.request('/auth/signup', {
      method: 'POST',
      skipAuth: true,
      body: JSON.stringify({
        phone_number: phoneNumber,
        full_name: fullName,
        email: email,
      }),
    });
    console.log('Sign up successful:', response);
    return response;
  } catch (error) {
    console.error('Sign up error:', error);
    throw error;
  }
}

// Request OTP
async function requestOTP(phoneNumber) {
  try {
    const response = await api.request('/auth/signin/request-otp', {
      method: 'POST',
      skipAuth: true,
      body: JSON.stringify({
        phone_number: phoneNumber,
      }),
    });
    console.log('OTP sent:', response);
    return response;
  } catch (error) {
    console.error('OTP request error:', error);
    throw error;
  }
}

// Verify OTP
async function verifyOTP(phoneNumber, otp) {
  try {
    const response = await api.request('/auth/signin/verify-otp', {
      method: 'POST',
      skipAuth: true,
      body: JSON.stringify({
        phone_number: phoneNumber,
        otp: otp,
      }),
    });
    
    // Store token
    await api.setToken(response.access_token);
    console.log('Signed in successfully');
    return response;
  } catch (error) {
    console.error('OTP verification error:', error);
    throw error;
  }
}
```

### Dashboard

```javascript
async function getDashboard() {
  try {
    const dashboard = await api.request('/dashboard', {
      method: 'GET',
    });
    console.log('Dashboard:', dashboard);
    return dashboard;
  } catch (error) {
    console.error('Dashboard error:', error);
    throw error;
  }
}
```

### Chat

```javascript
async function sendChatMessage(message, threadId = null) {
  try {
    const response = await api.request('/chat', {
      method: 'POST',
      body: JSON.stringify({
        message: message,
        thread_id: threadId,
      }),
    });
    console.log('AI Response:', response.reply);
    return response;
  } catch (error) {
    console.error('Chat error:', error);
    throw error;
  }
}

// Usage
const response = await sendChatMessage('I spent $42 on groceries');
console.log(response.reply);
// Store thread_id for next message
const threadId = response.thread_id;
```

### Expenses

```javascript
async function addExpense(amount, category, note = null) {
  try {
    const response = await api.request('/expenses', {
      method: 'POST',
      body: JSON.stringify({
        amount: amount,
        category: category,
        note: note,
      }),
    });
    console.log('Expense added:', response);
    return response;
  } catch (error) {
    console.error('Add expense error:', error);
    throw error;
  }
}

async function getSpendingSummary(period = 'last_30d') {
  try {
    const summary = await api.request(`/expenses/summary?period=${period}`, {
      method: 'GET',
    });
    console.log('Spending summary:', summary);
    return summary;
  } catch (error) {
    console.error('Summary error:', error);
    throw error;
  }
}
```

### Goals

```javascript
async function createGoal(goalData) {
  try {
    const response = await api.request('/goals', {
      method: 'POST',
      body: JSON.stringify({
        name: goalData.name,
        icon: goalData.icon,
        description: goalData.description,
        total_contribution: goalData.targetAmount,
        current_contribution: goalData.currentAmount || 0,
        deadline: goalData.deadline,
        color: goalData.color,
        monthly_recurring_contribution: goalData.monthlyAmount || 0,
      }),
    });
    console.log('Goal created:', response);
    return response;
  } catch (error) {
    console.error('Create goal error:', error);
    throw error;
  }
}

async function getGoals() {
  try {
    const goals = await api.request('/goals', {
      method: 'GET',
    });
    console.log('Goals:', goals);
    return goals;
  } catch (error) {
    console.error('Get goals error:', error);
    throw error;
  }
}

async function updateGoal(goalId, updates) {
  try {
    const response = await api.request(`/goals/${goalId}`, {
      method: 'PUT',
      body: JSON.stringify(updates),
    });
    console.log('Goal updated:', response);
    return response;
  } catch (error) {
    console.error('Update goal error:', error);
    throw error;
  }
}

async function deleteGoal(goalId) {
  try {
    const response = await api.request(`/goals/${goalId}`, {
      method: 'DELETE',
    });
    console.log('Goal deleted:', response);
    return response;
  } catch (error) {
    console.error('Delete goal error:', error);
    throw error;
  }
}
```

---

## Python

```python
import requests
from typing import Optional, Dict, Any

class PuldonAPI:
    def __init__(self, base_url: str = "http://151.245.140.91:8000"):
        self.base_url = base_url
        self.token: Optional[str] = None
    
    def set_token(self, token: str):
        """Set JWT token for authenticated requests"""
        self.token = token
    
    def _request(self, method: str, endpoint: str, 
                 data: Optional[Dict] = None,
                 params: Optional[Dict] = None,
                 skip_auth: bool = False) -> Dict[str, Any]:
        """Make HTTP request"""
        url = f"{self.base_url}{endpoint}"
        headers = {"Content-Type": "application/json"}
        
        if self.token and not skip_auth:
            headers["Authorization"] = f"Bearer {self.token}"
        
        response = requests.request(
            method=method,
            url=url,
            json=data,
            params=params,
            headers=headers
        )
        
        response.raise_for_status()
        return response.json()
    
    # Authentication
    def sign_up(self, phone_number: str, full_name: str, 
                email: Optional[str] = None) -> Dict:
        """Register new user"""
        return self._request("POST", "/auth/signup", data={
            "phone_number": phone_number,
            "full_name": full_name,
            "email": email
        }, skip_auth=True)
    
    def request_otp(self, phone_number: str) -> Dict:
        """Request OTP for sign in"""
        return self._request("POST", "/auth/signin/request-otp", data={
            "phone_number": phone_number
        }, skip_auth=True)
    
    def verify_otp(self, phone_number: str, otp: str) -> Dict:
        """Verify OTP and get token"""
        result = self._request("POST", "/auth/signin/verify-otp", data={
            "phone_number": phone_number,
            "otp": otp
        }, skip_auth=True)
        
        # Store token
        self.set_token(result["access_token"])
        return result
    
    # Dashboard
    def get_dashboard(self) -> Dict:
        """Get dashboard overview"""
        return self._request("GET", "/dashboard")
    
    # Chat
    def send_message(self, message: str, thread_id: Optional[str] = None) -> Dict:
        """Send chat message to AI"""
        return self._request("POST", "/chat", data={
            "message": message,
            "thread_id": thread_id
        })
    
    # Expenses
    def add_expense(self, amount: float, category: str, 
                    note: Optional[str] = None) -> Dict:
        """Add expense"""
        return self._request("POST", "/expenses", data={
            "amount": amount,
            "category": category,
            "note": note
        })
    
    def get_spending_summary(self, period: str = "last_30d") -> Dict:
        """Get spending summary"""
        return self._request("GET", "/expenses/summary", params={
            "period": period
        })
    
    # Goals
    def create_goal(self, name: str, target_amount: float, **kwargs) -> Dict:
        """Create financial goal"""
        data = {
            "name": name,
            "total_contribution": target_amount,
            **kwargs
        }
        return self._request("POST", "/goals", data=data)
    
    def get_goals(self) -> list:
        """Get all goals"""
        return self._request("GET", "/goals")
    
    def update_goal(self, goal_id: str, **updates) -> Dict:
        """Update goal"""
        return self._request("PUT", f"/goals/{goal_id}", data=updates)
    
    def delete_goal(self, goal_id: str) -> Dict:
        """Delete goal"""
        return self._request("DELETE", f"/goals/{goal_id}")


# Usage Example
if __name__ == "__main__":
    api = PuldonAPI()
    
    # Sign up
    api.sign_up("+1234567890", "John Doe", "john@example.com")
    
    # Sign in
    otp_response = api.request_otp("+1234567890")
    print(f"OTP: {otp_response.get('otp_code')}")
    
    api.verify_otp("+1234567890", "123456")
    
    # Get dashboard
    dashboard = api.get_dashboard()
    print(f"Net Worth: ${dashboard['net_worth']:.2f}")
    
    # Chat with AI
    response = api.send_message("I spent $42 on groceries")
    print(f"AI: {response['reply']}")
    
    # Create goal
    goal = api.create_goal(
        name="Emergency Fund",
        target_amount=10000,
        icon="💰",
        monthly_recurring_contribution=500
    )
    print(f"Goal created: {goal['goal']['id']}")
```

---

## Swift (iOS)

```swift
import Foundation

class PuldonAPI {
    static let shared = PuldonAPI()
    private let baseURL = "http://151.245.140.91:8000"
    private var token: String?
    
    // MARK: - Token Management
    
    func setToken(_ token: String) {
        self.token = token
        // Store in Keychain for security
        KeychainHelper.save(token, forKey: "jwt_token")
    }
    
    func getToken() -> String? {
        if let token = self.token {
            return token
        }
        // Load from Keychain
        return KeychainHelper.load(forKey: "jwt_token")
    }
    
    func clearToken() {
        self.token = nil
        KeychainHelper.delete(forKey: "jwt_token")
    }
    
    // MARK: - Network Request
    
    private func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        skipAuth: Bool = false,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if !skipAuth, let token = getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try? JSONEncoder().encode(body)
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Authentication
    
    struct SignUpRequest: Codable {
        let phone_number: String
        let full_name: String
        let email: String?
    }
    
    struct SignUpResponse: Codable {
        let success: Bool
        let message: String
        let user_id: String
    }
    
    func signUp(phoneNumber: String, fullName: String, email: String?, 
                completion: @escaping (Result<SignUpResponse, Error>) -> Void) {
        let body = SignUpRequest(
            phone_number: phoneNumber,
            full_name: fullName,
            email: email
        )
        request(endpoint: "/auth/signup", method: "POST", 
                body: body, skipAuth: true, completion: completion)
    }
    
    struct OTPRequest: Codable {
        let phone_number: String
    }
    
    struct OTPResponse: Codable {
        let message: String
        let otp_code: String?
    }
    
    func requestOTP(phoneNumber: String, 
                    completion: @escaping (Result<OTPResponse, Error>) -> Void) {
        let body = OTPRequest(phone_number: phoneNumber)
        request(endpoint: "/auth/signin/request-otp", method: "POST",
                body: body, skipAuth: true, completion: completion)
    }
    
    struct VerifyOTPRequest: Codable {
        let phone_number: String
        let otp: String
    }
    
    struct TokenResponse: Codable {
        let access_token: String
        let token_type: String
    }
    
    func verifyOTP(phoneNumber: String, otp: String,
                   completion: @escaping (Result<TokenResponse, Error>) -> Void) {
        let body = VerifyOTPRequest(phone_number: phoneNumber, otp: otp)
        request(endpoint: "/auth/signin/verify-otp", method: "POST",
                body: body, skipAuth: true) { (result: Result<TokenResponse, Error>) in
            switch result {
            case .success(let response):
                self.setToken(response.access_token)
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Dashboard
    
    struct Dashboard: Codable {
        let net_worth: Double
        let not_invested_money: Double
        let insights: [String]
        let overview: [SectorOverview]
    }
    
    struct SectorOverview: Codable {
        let sector: String
        let portion_percent: Double
    }
    
    func getDashboard(completion: @escaping (Result<Dashboard, Error>) -> Void) {
        request(endpoint: "/dashboard", completion: completion)
    }
    
    // MARK: - Chat
    
    struct ChatRequest: Codable {
        let message: String
        let thread_id: String?
    }
    
    struct ChatResponse: Codable {
        let reply: String
        let thread_id: String
        let tool_calls: [String]?
    }
    
    func sendMessage(_ message: String, threadId: String? = nil,
                     completion: @escaping (Result<ChatResponse, Error>) -> Void) {
        let body = ChatRequest(message: message, thread_id: threadId)
        request(endpoint: "/chat", method: "POST", body: body, completion: completion)
    }
    
    // MARK: - Goals
    
    struct Goal: Codable {
        let id: String
        let name: String
        let icon: String?
        let description: String?
        let progress: Double
        let current_contribution: Double
        let total_contribution: Double
        let days_left: Int?
        let monthly_recurring_contribution: Double
        let color: String?
    }
    
    func getGoals(completion: @escaping (Result<[Goal], Error>) -> Void) {
        request(endpoint: "/goals", completion: completion)
    }
    
    struct CreateGoalRequest: Codable {
        let name: String
        let icon: String?
        let description: String?
        let total_contribution: Double
        let current_contribution: Double?
        let deadline: String?
        let color: String?
        let monthly_recurring_contribution: Double?
    }
    
    func createGoal(name: String, targetAmount: Double, icon: String? = nil,
                    completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // Implementation here
    }
}
```

---

## Kotlin (Android)

```kotlin
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.IOException

class PuldonAPI {
    private val baseURL = "http://151.245.140.91:8000"
    private val client = OkHttpClient()
    private var token: String? = null
    
    // Token management
    fun setToken(token: String) {
        this.token = token
        // Store in EncryptedSharedPreferences
    }
    
    fun getToken(): String? = token
    
    fun clearToken() {
        token = null
    }
    
    // Generic request function
    private fun request(
        endpoint: String,
        method: String = "GET",
        body: JSONObject? = null,
        skipAuth: Boolean = false,
        callback: Callback
    ) {
        val url = baseURL + endpoint
        val requestBuilder = Request.Builder().url(url)
        
        // Add headers
        requestBuilder.addHeader("Content-Type", "application/json")
        if (!skipAuth && token != null) {
            requestBuilder.addHeader("Authorization", "Bearer $token")
        }
        
        // Add body if present
        if (body != null) {
            val mediaType = "application/json".toMediaType()
            val requestBody = body.toString().toRequestBody(mediaType)
            requestBuilder.method(method, requestBody)
        } else {
            requestBuilder.method(method, null)
        }
        
        client.newCall(requestBuilder.build()).enqueue(callback)
    }
    
    // Sign Up
    fun signUp(
        phoneNumber: String,
        fullName: String,
        email: String?,
        callback: Callback
    ) {
        val body = JSONObject().apply {
            put("phone_number", phoneNumber)
            put("full_name", fullName)
            email?.let { put("email", it) }
        }
        
        request("/auth/signup", "POST", body, skipAuth = true, callback)
    }
    
    // Request OTP
    fun requestOTP(phoneNumber: String, callback: Callback) {
        val body = JSONObject().apply {
            put("phone_number", phoneNumber)
        }
        
        request("/auth/signin/request-otp", "POST", body, skipAuth = true, callback)
    }
    
    // Verify OTP
    fun verifyOTP(phoneNumber: String, otp: String, callback: (String?) -> Unit) {
        val body = JSONObject().apply {
            put("phone_number", phoneNumber)
            put("otp", otp)
        }
        
        request("/auth/signin/verify-otp", "POST", body, skipAuth = true, object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                callback(null)
            }
            
            override fun onResponse(call: Call, response: Response) {
                response.body?.string()?.let { responseBody ->
                    val json = JSONObject(responseBody)
                    val accessToken = json.getString("access_token")
                    setToken(accessToken)
                    callback(accessToken)
                }
            }
        })
    }
    
    // Get Dashboard
    fun getDashboard(callback: Callback) {
        request("/dashboard", callback = callback)
    }
    
    // Send Chat Message
    fun sendMessage(message: String, threadId: String? = null, callback: Callback) {
        val body = JSONObject().apply {
            put("message", message)
            threadId?.let { put("thread_id", it) }
        }
        
        request("/chat", "POST", body, callback = callback)
    }
    
    // Add Expense
    fun addExpense(
        amount: Double,
        category: String,
        note: String? = null,
        callback: Callback
    ) {
        val body = JSONObject().apply {
            put("amount", amount)
            put("category", category)
            note?.let { put("note", it) }
        }
        
        request("/expenses", "POST", body, callback = callback)
    }
    
    // Get Goals
    fun getGoals(callback: Callback) {
        request("/goals", callback = callback)
    }
    
    // Create Goal
    fun createGoal(
        name: String,
        targetAmount: Double,
        icon: String? = null,
        monthlyContribution: Double? = null,
        callback: Callback
    ) {
        val body = JSONObject().apply {
            put("name", name)
            put("total_contribution", targetAmount)
            icon?.let { put("icon", it) }
            monthlyContribution?.let { put("monthly_recurring_contribution", it) }
        }
        
        request("/goals", "POST", body, callback = callback)
    }
}

// Usage Example
fun main() {
    val api = PuldonAPI()
    
    // Sign in flow
    api.requestOTP("+1234567890", object : Callback {
        override fun onFailure(call: Call, e: IOException) {
            println("Error: ${e.message}")
        }
        
        override fun onResponse(call: Call, response: Response) {
            val body = response.body?.string()
            println("OTP Response: $body")
            
            // Verify OTP
            api.verifyOTP("+1234567890", "123456") { token ->
                if (token != null) {
                    println("Signed in! Token: $token")
                    
                    // Get dashboard
                    api.getDashboard(object : Callback {
                        override fun onFailure(call: Call, e: IOException) {
                            println("Error: ${e.message}")
                        }
                        
                        override fun onResponse(call: Call, response: Response) {
                            println("Dashboard: ${response.body?.string()}")
                        }
                    })
                }
            }
        }
    })
}
```

---

## Testing with cURL

### Sign Up
```bash
curl -X POST http://151.245.140.91:8000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "phone_number": "+1234567890",
    "full_name": "John Doe",
    "email": "john@example.com"
  }'
```

### Request OTP
```bash
curl -X POST http://151.245.140.91:8000/auth/signin/request-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone_number": "+1234567890"
  }'
```

### Verify OTP
```bash
curl -X POST http://151.245.140.91:8000/auth/signin/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone_number": "+1234567890",
    "otp": "123456"
  }'
```

### Get Dashboard
```bash
curl -X GET http://151.245.140.91:8000/dashboard \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Send Chat Message
```bash
curl -X POST http://151.245.140.91:8000/chat \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "I spent $42 on groceries"
  }'
```

### Create Goal
```bash
curl -X POST http://151.245.140.91:8000/goals \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Emergency Fund",
    "icon": "💰",
    "total_contribution": 10000,
    "monthly_recurring_contribution": 500
  }'
```

---

## Postman Collection

Import the Postman collection for easy testing:

**File:** `Puldon_API.postman_collection.json`

Available in the repository root. Import it into Postman to test all endpoints with pre-configured requests.

---

## Support & Contact

For questions, issues, or feature requests:

- **Documentation:** http://151.245.140.91:8000/docs
- **API Status:** http://151.245.140.91:8000/health
- **Repository:** Contact your backend team

---

**Last Updated:** January 15, 2025  
**API Version:** 1.0.0

---

**Happy Coding! 🚀**

