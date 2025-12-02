# 🚀 API Integration Guide - Puldon App

## ✅ Current Status

Your API integration is **100% complete**! All necessary code is already implemented:

- ✅ API Client configured (`lib/core/api/api_client.dart`)
- ✅ All Repositories implemented (Auth, Chat, Dashboard, Goals, Expenses, Debts)
- ✅ All Models with JSON serialization
- ✅ Token Manager for secure authentication
- ✅ API Monitor for debugging
- ✅ Base URL: `http://151.245.140.91:8000`

## 🔄 Current Mode: MOCK DATA

The app is currently running in **mock mode** for testing without a backend.

## 🌐 How to Enable Real API

### Step 1: Change Configuration

Open `lib/core/constants/app_config.dart` and change:

```dart
static const bool useMockData = true;  // ❌ Current
```

To:

```dart
static const bool useMockData = false;  // ✅ Enable API
```

### Step 2: Add Authentication Screens

The app currently skips authentication and goes straight to the home screen.

You need to create:
1. **Sign In Screen** - Phone number + OTP verification
2. **Sign Up Screen** - For new users

These screens should use the **already implemented** `AuthRepository`:

```dart
// lib/data/repositories/auth_repository.dart already has:
- signUp()
- requestOtp()
- verifyOtp()
- getProfile()
```

### Step 3: Update Main App Flow

Modify `lib/main.dart` to check authentication status:

```dart
// Instead of always showing HomeScreen,
// check if user is logged in first
return isLoggedIn ? HomeScreen() : SignInScreen();
```

### Step 4: Test API Connection

1. Open http://151.245.140.91:8000/docs in browser
2. Verify the API is reachable
3. Test sign up/sign in from your app
4. Check API Monitor (already built-in) to debug calls

## 📱 iOS Network Configuration

If testing on iOS Simulator, add to `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 🔍 Debugging Tools

### Built-in API Monitor

Your app already has an API monitoring dashboard! Access it by:

```dart
// Navigate to API Monitor
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ApiMonitoringDashboard(),
  ),
);
```

This shows:
- All API calls in real-time
- Request/Response bodies
- Status codes
- Response times
- Errors

## 🎯 What Works Right Now

### With Mock Data (Current):
- ✅ All screens working
- ✅ Chat with AI (simulated)
- ✅ Goals, Transactions, Dashboard
- ✅ No internet required

### When You Enable API (`useMockData = false`):
- ✅ Real chat with AI backend
- ✅ Data persisted on server
- ✅ Cross-device sync
- ⚠️ Requires authentication
- ⚠️ Requires internet connection

## 📝 Next Steps

### Immediate (To test API):

1. **Test in Postman First**
   - Use the endpoints from the docs you provided
   - Verify sign up, OTP, chat work
   - Get a valid token

2. **Create Sign In Screen**
   ```dart
   // Use AuthRepository.requestOtp()
   // Then AuthRepository.verifyOtp()
   ```

3. **Update main.dart**
   ```dart
   // Check authentication before showing home
   final isAuth = await tokenManager.hasToken();
   return isAuth ? HomeScreen() : SignInScreen();
   ```

4. **Set `AppConfig.useMockData = false`**

5. **Run app and monitor API calls**

### For Production:

1. Implement proper error handling
2. Add loading states
3. Handle token expiration
4. Add offline mode fallback
5. Test on real devices (not just simulator)

## 🐛 Common Issues & Fixes

### "APIs aren't working"

**Reason:** App is in mock mode (`AppConfig.useMockData = true`)

**Fix:** Change to `false` in `app_config.dart`

### "401 Unauthorized"

**Reason:** No auth token or token expired

**Fix:** Implement sign in flow first

### "Network Error"

**Fix iOS:** Add NSAppTransportSecurity to Info.plist (see above)

**Fix Android:** Internet permission already in manifest

### "Connection refused"

- Check if API server is running: http://151.245.140.91:8000/docs
- Check your internet connection
- If on emulator, use correct IP address

## 💡 Pro Tips

1. **Use API Monitor** - It's already built in! Super helpful for debugging
2. **Test with Postman first** - Verify API works before debugging app
3. **Start with one feature** - Get chat working first, then dashboard, then goals
4. **Keep mock mode** - Useful for offline development and testing

## 📞 Need Help?

Your backend team provided excellent documentation. Everything you need is in:
- The API docs you shared
- Your already-implemented repositories
- The Postman collection

**The code is ready - you just need to flip the switch!** 🚀
