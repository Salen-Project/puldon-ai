# 🔍 API Monitor Dashboard - Usage Guide

A beautiful, real-time API monitoring dashboard that tracks all your API calls with detailed information.

---

## Features

✅ **Real-time Tracking** - See API calls as they happen
✅ **Detailed Information** - View request/response data, headers, status codes
✅ **Performance Metrics** - Track response times and success rates
✅ **Smart Filtering** - Filter by method, status, or search query
✅ **Statistics Dashboard** - See total calls, success rate, and average response time
✅ **Error Tracking** - Easily identify and debug failed requests
✅ **Copy to Clipboard** - Copy request/response data for debugging
✅ **Clean UI** - Beautiful, intuitive interface

---

## Quick Setup

### Method 1: Floating Action Button (Recommended)

Add a floating button to any screen:

```dart
import 'package:flutter/material.dart';
import 'package:salen_fin/core/api/api_monitor_button.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My App')),
      body: YourContent(),

      // Add this floating button
      floatingActionButton: ApiMonitorFloatingButton(),
    );
  }
}
```

### Method 2: Draggable Monitor (Always Visible)

Add a draggable monitor that stays on screen:

```dart
import 'package:flutter/material.dart';
import 'package:salen_fin/core/api/api_monitor_button.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          YourHomeScreen(),

          // Add draggable monitor
          DraggableApiMonitor(),
        ],
      ),
    );
  }
}
```

### Method 3: Mini Widget (In-Screen)

Add a mini monitor widget anywhere in your UI:

```dart
import 'package:salen_fin/core/api/api_monitor_button.dart';

// In your widget:
ApiMonitorMiniWidget()
```

### Method 4: Direct Navigation

Navigate to the dashboard programmatically:

```dart
import 'package:salen_fin/core/api/api_dashboard.dart';

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ApiMonitoringDashboard(),
  ),
);
```

---

## Dashboard Features

### 1. Statistics Cards

View key metrics at a glance:
- **Total** - Total number of API calls
- **Success** - Successful calls (2xx status codes)
- **Errors** - Failed calls (4xx, 5xx, network errors)
- **Avg Time** - Average response time in milliseconds

### 2. Search & Filters

**Search Bar:**
- Search by endpoint path (e.g., "/auth/login")
- Search by HTTP method (e.g., "POST")

**Method Filters:**
- All
- GET
- POST
- PUT
- PATCH
- DELETE

**Status Filters:**
- All
- Success (2xx)
- Errors (4xx, 5xx, network errors)

### 3. API Call Cards

Each card shows:
- **Method Badge** - Color-coded HTTP method
  - GET = Blue
  - POST = Green
  - PUT = Orange
  - PATCH = Purple
  - DELETE = Red
- **Status Badge** - Status code or error indicator
- **Endpoint** - Full API endpoint path
- **Response Time** - Duration in milliseconds
- **Timestamp** - When the call was made

### 4. Detailed View

Tap any API call card to see:

**Overview:**
- HTTP method
- Full endpoint URL
- Status text and code
- Response time
- Exact timestamp

**Request Headers:**
- All headers sent with the request
- JSON formatted
- Copy to clipboard

**Request Body:**
- Request payload
- Pretty-printed JSON
- Copy to clipboard

**Response Body:**
- Full API response
- Pretty-printed JSON
- Copy to clipboard

**Error Details (if failed):**
- Error message
- Stack trace (if available)

---

## Example Usage

### Monitor Authentication Flow

```dart
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: LoginForm(),

      // Add monitor button
      floatingActionButton: ApiMonitorFloatingButton(),
    );
  }
}

// When you make API calls:
final authRepo = ref.read(authRepositoryProvider);
await authRepo.requestOtp('+1234567890');  // Tracked!
await authRepo.verifyOtp('+1234567890', '123456');  // Tracked!

// Check the dashboard to see:
// - Request time
// - Response status
// - OTP code (in dev mode)
// - Any errors
```

### Debug Failed Requests

```dart
// Make an API call
try {
  final dashboard = await dashboardRepo.getDashboard();
} catch (e) {
  // Error occurred!
  // Open the API monitor to see:
  // - Error message
  // - Status code
  // - Request/response data
  // - Network details
}

// The monitor automatically tracks the error
// Tap the failed request to see full details
```

### Monitor Performance

```dart
// Make multiple API calls
await Future.wait([
  expenseRepo.getExpenses(),
  goalRepo.getGoals(),
  debtRepo.getDebtSummary(),
]);

// Check the dashboard to see:
// - Total calls: 3
// - Average response time
// - Which calls succeeded/failed
// - Performance bottlenecks
```

---

## API Monitor Configuration

### Enable/Disable Monitoring

The monitor is automatically enabled when you use the `apiClientProvider`.

To disable monitoring (e.g., in production):

```dart
// In lib/core/api/api_client.dart provider:
final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenManager = ref.watch(tokenManagerProvider);

  // Only enable monitoring in debug mode
  final apiMonitor = kDebugMode
    ? ref.watch(apiMonitorProvider.notifier)
    : null;

  return ApiClient(
    tokenManager: tokenManager,
    apiMonitor: apiMonitor,
  );
});
```

### Clear All Logs

From the dashboard:
1. Tap the trash icon in the app bar
2. Confirm the dialog
3. All logs are cleared

Programmatically:

```dart
final monitor = ref.read(apiMonitorProvider.notifier);
monitor.clearAll();
```

### Access Statistics

```dart
final monitor = ref.read(apiMonitorProvider.notifier);
final stats = monitor.getStats();

print('Total calls: ${stats['total']}');
print('Success rate: ${stats['success']}');
print('Error count: ${stats['error']}');
print('Avg duration: ${stats['avgDuration']}ms');
```

---

## Tips & Tricks

### 1. Quick Debugging

When an API call fails:
1. Open the API monitor
2. Find the failed request (red badge)
3. Tap to see details
4. Check error message and response
5. Copy request/response for investigation

### 2. Performance Optimization

Monitor response times to identify slow endpoints:
1. Filter by method or endpoint
2. Sort by response time
3. Identify bottlenecks
4. Optimize slow endpoints

### 3. Copy Request/Response

Need to share API data?
1. Open API call details
2. Tap the copy icon next to JSON data
3. Paste anywhere (Slack, email, bug reports)

### 4. Search Efficiently

- Search for specific endpoints: `/auth/login`
- Search for error codes: `401`
- Search for methods: `POST`
- Combine with filters for precise results

### 5. Monitor in Development

Keep the draggable monitor visible while developing:
```dart
// Wrap your app
Stack(
  children: [
    MyApp(),
    if (kDebugMode) DraggableApiMonitor(),
  ],
)
```

---

## Dashboard Shortcuts

### Filters
- Tap method chips to filter by HTTP method
- Tap status chips to filter by success/error
- Use search bar for text search
- Combine filters for precise results

### Actions
- **Tap card** - View full details
- **Tap copy icon** - Copy JSON to clipboard
- **Tap trash icon** - Clear all logs
- **Pull to refresh** - Refresh statistics

---

## What Gets Tracked?

✅ **All HTTP Methods** - GET, POST, PUT, PATCH, DELETE
✅ **Request Data** - Headers, body, query parameters
✅ **Response Data** - Status code, headers, body
✅ **Timing** - Request start time and duration
✅ **Errors** - Network errors, timeouts, HTTP errors
✅ **Authentication** - Token presence (not the actual token)

❌ **Not Tracked:**
- Actual JWT tokens (security)
- Passwords or sensitive data in plain text
- More than last 100 calls (memory management)

---

## Troubleshooting

### Monitor not showing calls

**Issue:** API calls not appearing in dashboard

**Solution:**
1. Ensure `ProviderScope` wraps your app
2. Check that you're using `apiClientProvider`
3. Verify repositories are using the API client
4. Make sure monitoring is enabled in API client provider

### Dashboard not opening

**Issue:** Dashboard doesn't open when tapped

**Solution:**
1. Check Navigator is available in context
2. Ensure MaterialApp wraps your app
3. Try using `Navigator.of(context, rootNavigator: true).push()`

### No statistics showing

**Issue:** Stats cards show all zeros

**Solution:**
1. Make at least one API call
2. Check that monitoring is enabled
3. Verify `apiMonitorProvider` is properly configured

---

## Advanced Usage

### Custom Filtering

```dart
// Filter calls programmatically
final monitor = ref.watch(apiMonitorProvider.notifier);

// Get only POST requests
final postCalls = monitor.filterByMethod('POST');

// Get only successful calls
final successCalls = monitor.filterByStatus(true);

// Get only errors
final errorCalls = monitor.filterByStatus(false);
```

### Export Logs

```dart
// Get all API calls
final allCalls = ref.watch(apiMonitorProvider);

// Convert to JSON
final json = allCalls.map((call) => {
  'method': call.method,
  'endpoint': call.endpoint,
  'status': call.statusCode,
  'duration': call.duration?.inMilliseconds,
  'timestamp': call.timestamp.toIso8601String(),
}).toList();

// Export or log
print(jsonEncode(json));
```

---

## Best Practices

1. **Use in Development** - Enable monitoring during development
2. **Disable in Production** - Remove monitor in production builds
3. **Clear Regularly** - Clear logs to free memory
4. **Monitor Performance** - Watch response times
5. **Debug Errors** - Use detailed view to debug failures

---

## Example Scenarios

### Scenario 1: Debug Login Failure

```dart
// User reports login failing
// 1. Add monitor to login screen
// 2. Reproduce the issue
// 3. Open monitor dashboard
// 4. Find the failed /auth/signin/verify-otp call
// 5. See: "Invalid OTP code" error
// 6. Fix: User entered wrong OTP
```

### Scenario 2: Optimize Load Time

```dart
// Dashboard loads slowly
// 1. Open monitor during dashboard load
// 2. See 5 API calls made
// 3. /expenses/summary takes 2000ms
// 4. Other calls take < 200ms
// 5. Fix: Optimize backend /expenses/summary endpoint
```

### Scenario 3: Track User Flow

```dart
// Track complete sign-up flow
// 1. Open monitor
// 2. User signs up
// 3. Monitor shows:
//    - POST /auth/signup - 200 OK - 150ms
//    - POST /auth/signin/request-otp - 200 OK - 100ms
//    - POST /auth/signin/verify-otp - 200 OK - 180ms
//    - GET /auth/profile - 200 OK - 120ms
// 4. All successful, average 137ms
```

---

## Summary

The API Monitor Dashboard provides:
- 🔍 Real-time API call tracking
- 📊 Performance metrics
- 🐛 Easy debugging
- 📋 Copy/paste functionality
- 🎨 Beautiful UI
- ⚡ Smart filtering

**Perfect for:**
- Development
- Debugging
- Performance monitoring
- API testing
- User support

Open the dashboard, make an API call, and see it tracked in real-time! 🚀
