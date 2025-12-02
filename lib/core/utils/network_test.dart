import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Test network connectivity and API reachability
class NetworkTest {
  /// Test if device has internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Test if API server is reachable
  static Future<bool> canReachApiServer(String host) async {
    try {
      // Extract host from URL if full URL is provided
      final uri = Uri.parse(host.startsWith('http') ? host : 'http://$host');
      final hostname = uri.host;

      final result = await InternetAddress.lookup(hostname);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Test API endpoint with Dio
  static Future<Map<String, dynamic>> testApiEndpoint(String baseUrl) async {
    final dio = Dio();

    // Configure Dio to work with HTTP and self-signed certificates
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) => true, // Accept all status codes
    );

    final results = <String, dynamic>{
      'baseUrl': baseUrl,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      // Test 1: Basic connectivity
      results['hasInternet'] = await hasInternetConnection();

      // Test 2: Can reach API server
      results['canReachServer'] = await canReachApiServer(baseUrl);

      // Test 3: Try to hit docs endpoint
      try {
        final response = await dio.get('/docs');
        results['docsEndpoint'] = {
          'success': true,
          'statusCode': response.statusCode,
          'hasData': response.data != null,
        };
      } catch (e) {
        results['docsEndpoint'] = {
          'success': false,
          'error': e.toString(),
        };
      }

      // Test 4: Try to hit root endpoint
      try {
        final response = await dio.get('/');
        results['rootEndpoint'] = {
          'success': true,
          'statusCode': response.statusCode,
          'hasData': response.data != null,
        };
      } catch (e) {
        results['rootEndpoint'] = {
          'success': false,
          'error': e.toString(),
        };
      }

      results['overallSuccess'] = true;
    } catch (e) {
      results['overallSuccess'] = false;
      results['error'] = e.toString();
    }

    dio.close();
    return results;
  }

  /// Run all network tests
  static Future<void> runAllTests(String apiUrl) async {
    print('\n========================================');
    print('🔍 NETWORK DIAGNOSTICS');
    print('========================================\n');

    print('Testing API: $apiUrl\n');

    // Test 1: Internet connectivity
    print('1️⃣ Testing internet connectivity...');
    final hasInternet = await hasInternetConnection();
    print('   ${hasInternet ? "✅" : "❌"} Internet: ${hasInternet ? "Connected" : "Not connected"}\n');

    // Test 2: API server reachability
    print('2️⃣ Testing API server reachability...');
    final canReach = await canReachApiServer(apiUrl);
    print('   ${canReach ? "✅" : "❌"} Server: ${canReach ? "Reachable" : "Not reachable"}\n');

    // Test 3: API endpoints
    print('3️⃣ Testing API endpoints...');
    final apiTest = await testApiEndpoint(apiUrl);

    print('   Docs endpoint: ${apiTest['docsEndpoint']['success'] ? "✅" : "❌"}');
    if (!apiTest['docsEndpoint']['success']) {
      print('      Error: ${apiTest['docsEndpoint']['error']}');
    }

    print('   Root endpoint: ${apiTest['rootEndpoint']['success'] ? "✅" : "❌"}');
    if (!apiTest['rootEndpoint']['success']) {
      print('      Error: ${apiTest['rootEndpoint']['error']}');
    }

    print('\n========================================');
    print('📊 SUMMARY');
    print('========================================\n');

    if (hasInternet && canReach) {
      print('✅ Network is working correctly!');
      print('✅ API server is reachable!');

      if (apiTest['docsEndpoint']['success'] || apiTest['rootEndpoint']['success']) {
        print('✅ API endpoints are responding!');
      } else {
        print('⚠️  API endpoints are not responding as expected.');
        print('   This might be a configuration issue.');
      }
    } else {
      if (!hasInternet) {
        print('❌ No internet connection detected.');
        print('   Please check your network settings.');
      }
      if (!canReach) {
        print('❌ Cannot reach API server at $apiUrl');
        print('   Possible issues:');
        print('   - Server is down');
        print('   - Wrong IP address or port');
        print('   - Firewall blocking connection');
        print('   - iOS simulator network issues');
      }
    }

    print('\n========================================\n');
  }

  /// Print iOS simulator network troubleshooting guide
  static void printIosSimulatorGuide() {
    print('\n========================================');
    print('🍎 iOS SIMULATOR TROUBLESHOOTING');
    print('========================================\n');

    print('If you\'re getting "No internet connection" on iOS Simulator:\n');

    print('1️⃣ RESTART SIMULATOR');
    print('   - Stop the app (Cmd + .)\n');
    print('   - Close simulator\n');
    print('   - Reopen and run again\n');

    print('2️⃣ CHECK INFO.PLIST');
    print('   File: ios/Runner/Info.plist');
    print('   Should contain:\n');
    print('   <key>NSAppTransportSecurity</key>');
    print('   <dict>');
    print('       <key>NSAllowsArbitraryLoads</key>');
    print('       <true/>');
    print('   </dict>\n');

    print('3️⃣ RESET NETWORK SETTINGS');
    print('   On simulator: Settings → General → Transfer or Reset → Reset → Reset Network Settings\n');

    print('4️⃣ CHECK MAC NETWORK');
    print('   Make sure your Mac has internet connection');
    print('   Simulator uses Mac\'s network connection\n');

    print('5️⃣ TRY DIFFERENT SIMULATOR');
    print('   Sometimes specific simulator versions have issues');
    print('   Try iPhone 15 Pro or iPhone 14\n');

    print('6️⃣ CLEAN AND REBUILD');
    print('   Run: flutter clean && flutter pub get && flutter run\n');

    print('========================================\n');
  }
}
