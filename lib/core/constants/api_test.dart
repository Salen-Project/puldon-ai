import 'package:dio/dio.dart';

/// Quick API Test - Run this to verify backend connectivity
class ApiTest {
  static Future<void> testConnection() async {
    final dio = Dio();
    
    print('🔍 Testing API Connection...');
    print('Base URL: https://151.245.140.91');
    print('');
    
    try {
      // Test 1: Health Check
      print('Test 1: Health Check');
      final healthResponse = await dio.get('https://151.245.140.91/health');
      print('✅ Health Check: ${healthResponse.data}');
      print('');
      
      // Test 2: API Docs
      print('Test 2: API Docs Available');
      final docsResponse = await dio.get('https://151.245.140.91/docs');
      if (docsResponse.statusCode == 200) {
        print('✅ API Docs: Available at https://151.245.140.91/docs');
      }
      print('');
      
      print('🎉 SUCCESS: API is reachable and working!');
      print('');
      print('Next steps:');
      print('1. Test authentication in Postman');
      print('2. Create Sign In screen in your app');
      print('3. Set AppConfig.useMockData = false');
      
    } catch (e) {
      print('❌ ERROR: Cannot connect to API');
      print('Error: $e');
      print('');
      print('Possible fixes:');
      print('1. Check if API server is running');
      print('2. Check your internet connection');
      print('3. If on iOS, add NSAppTransportSecurity to Info.plist');
      print('4. Try opening https://151.245.140.91/docs in browser');
    }
  }
}

/// Run this test:
/// 
/// void main() async {
///   await ApiTest.testConnection();
/// }



