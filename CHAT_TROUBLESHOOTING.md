# Chat Network Error Troubleshooting Guide

## Problem
You're getting a network error when trying to use the chat feature after signing in.

## Root Cause Analysis

Based on the code investigation, here are the potential issues:

### 1. **MultiProvider Recreation Issue** ✅ FIXED
**Problem**: The `ChatProvider` was created once at app startup. When you signed in later, it still had `chatRepository: null`.

**Fix Applied**: Added a `key` to `MultiProvider` in `main.dart:60` that changes when auth state changes, forcing provider recreation.

```dart
key: ValueKey('multiProvider_auth_${authState.isAuthenticated}'),
```

### 2. **Authentication Token Not Being Sent** (Possible)
**Problem**: The chat endpoint requires `Authorization: Bearer <token>` header, but the token might not be attached.

**Check**: Look at ApiClient interceptor at `lib/core/api/api_client.dart:188-208`

### 3. **Chat Endpoint URL Mismatch**
**Expected**: `POST https://151.245.140.91/chat`
**Your Code**: `lib/core/api/api_endpoints.dart:20` ✅ Correct

### 4. **Request Format Mismatch**
**Expected by API**:
```json
{
  "message": "your message",
  "thread_id": "optional_thread_id"
}
```

**Your Code**: `lib/data/models/chat_model.dart:6-20` ✅ Correct

## Debugging Steps

### Step 1: Check if You're Actually Logged In

1. Run the app
2. Before trying chat, check the console for auth logs
3. Look for this in logs:
   ```
   ✅ Token saved: eyJhbGciOiJIUzI1NiI...
   ✅ User authenticated: true
   ```

### Step 2: Use the Network Debug Screen

1. Navigate to Network Debug Screen in your app
2. Tap "Run Diagnostics"
3. Check if all tests pass:
   - ✅ Internet: Connected
   - ✅ Server: Reachable
   - ✅ API endpoints: Responding

### Step 3: Check API Monitor

Your app has API monitoring enabled (`lib/core/api/api_monitor.dart`). Check the API dashboard in your app to see:
- What requests are being made
- What status codes are returned
- Request/response headers and body

### Step 4: Manual API Test

Test the chat endpoint manually from your Mac:

```bash
# 1. Sign in and get token
curl -k -X POST https://151.245.140.91/auth/signin/request-otp \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "+1234567890"}'

# Note the OTP code returned (dev mode)

curl -k -X POST https://151.245.140.91/auth/signin/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "+1234567890", "otp": "YOUR_OTP"}'

# Copy the access_token from response

# 2. Test chat endpoint
curl -k -X POST https://151.245.140.91/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{"message": "Hello"}'
```

Expected response:
```json
{
  "reply": "AI response here",
  "thread_id": "thread_abc123",
  "tool_calls": null
}
```

If this fails with `{"detail":"Not authenticated"}`, the token is invalid.

## Common Issues & Solutions

### Issue 1: "Not authenticated" Error
**Cause**: No token or invalid token
**Solution**:
1. Make sure you're signed in
2. Check that token is being saved: `lib/data/repositories/auth_repository.dart:50`
3. Check that token is being attached to requests: `lib/core/api/api_client.dart:193`

### Issue 2: "Connection Timeout"
**Cause**: Network issues or slow server
**Solution**:
1. Increase timeout in `lib/core/api/api_client.dart:56-58` (currently 10 seconds)
2. Check server is running and responsive
3. Try from a physical device instead of simulator

### Issue 3: Provider Not Updated After Login
**Cause**: MultiProvider not recreating ChatProvider
**Solution**: Already fixed! The `key` prop forces recreation.

### Issue 4: iOS Simulator Network Issues
**Cause**: iOS Simulator sometimes has network problems
**Solution**:
1. Completely quit Simulator (not just stop app)
2. Run: `flutter clean && flutter pub get`
3. Try a different simulator (Settings > Devices)
4. Try a physical device

## Verification Checklist

After applying fixes, verify:

- [ ] App rebuilds without errors
- [ ] You can sign in successfully
- [ ] Network Debug Screen shows all green
- [ ] Chat sends a message
- [ ] You see AI response (not mock data)
- [ ] Check console logs for "POST /chat" with status 200
- [ ] Second message in same conversation works (thread continuity)

## Expected Behavior

### Before Login:
- Chat uses mock responses
- No API calls made
- ChatProvider has `chatRepository: null`

### After Login:
- ChatProvider recreated with real repository
- Chat makes API calls to `/chat`
- You see real AI responses from server
- Thread ID is maintained across messages

## Code Changes Made

### 1. `lib/main.dart`
- Added `key` to MultiProvider for recreation on auth changes
- Lines 60

### 2. `lib/providers/chat_provider.dart`
- Made `_chatRepository` mutable
- Added `updateRepository()` method
- Lines 10, 18-20

## Logs to Look For

### Success Pattern:
```
✅ Auth state changed: authenticated
🔄 MultiProvider recreating with new key
✅ ChatProvider created with repository
📤 POST /chat
📥 Response 200: {"reply":"...","thread_id":"..."}
```

### Failure Pattern:
```
❌ POST /chat
❌ NetworkException: No internet connection
```
OR
```
❌ POST /chat
❌ ServerException: 401 Unauthorized
```

## Still Having Issues?

If you're still getting network errors after following this guide:

1. **Check console output** - Share the exact error logs
2. **Run Network Diagnostics** - Share the results
3. **Test manually with curl** - Does the endpoint work outside the app?
4. **Try physical device** - Simulator might have network issues
5. **Check backend logs** - Is the server receiving requests?

## Quick Test Command

Run this to rebuild and test:

```bash
flutter clean
flutter pub get
flutter run

# Then in the app:
# 1. Sign in
# 2. Go to chat
# 3. Send message: "Hello"
# 4. Check console for API calls
```

---

**Last Updated**: January 2025
**Status**: Fix applied, waiting for verification
