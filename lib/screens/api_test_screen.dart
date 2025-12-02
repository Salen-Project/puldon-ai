import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String _status = 'Ready to test';
  Color _statusColor = Colors.grey;
  bool _testing = false;
  final List<String> _logs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Connection Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _statusColor,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(_getStatusIcon(), color: _statusColor, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    _status,
                    style: AppTextStyles.h4.copyWith(color: _statusColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Test Button
            ElevatedButton(
              onPressed: _testing ? null : _testConnection,
              child: _testing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Test API Connection'),
            ),
            const SizedBox(height: 24),

            // Logs
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassLight),
                ),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _logs[index],
                        style: AppTextStyles.bodySmall.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    if (_testing) return Icons.sync;
    if (_status.contains('Success')) return Icons.check_circle;
    if (_status.contains('Failed')) return Icons.error;
    return Icons.info_outline;
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _logs.clear();
      _status = 'Testing...';
      _statusColor = Colors.orange;
    });

    _log('🔍 Starting API Connection Test');
    _log('Base URL: https://151.245.140.91');
    _log('');

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    // Accept self-signed certificates for testing
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      },
    );

    try {
      // Test 1: Health Check
      _log('Test 1: Health Check Endpoint');
      final healthResponse = await dio.get('https://151.245.140.91/health');
      
      if (healthResponse.statusCode == 200) {
        _log('✅ Health Check: SUCCESS');
        _log('   Response: ${healthResponse.data}');
      }
      _log('');

      // Test 2: Docs endpoint
      _log('Test 2: API Documentation');
      try {
        final docsResponse = await dio.get('https://151.245.140.91/docs');
        
        if (docsResponse.statusCode == 200) {
          _log('✅ API Docs: Available');
          _log('   Visit: https://151.245.140.91/docs');
        }
      } catch (e) {
        if (e is DioException && e.response?.statusCode == 403) {
          _log('⚠️  API Docs: Protected (403 Forbidden)');
          _log('   This is normal - docs may require auth');
        } else {
          _log('⚠️  API Docs: ${e.toString()}');
        }
      }
      _log('');

      // Test 3: Try protected endpoint without auth (should get 401)
      _log('Test 3: Protected Endpoint Test');
      try {
        await dio.get('https://151.245.140.91/dashboard');
        _log('⚠️  Dashboard accessible without auth (unexpected)');
      } catch (e) {
        if (e is DioException && e.response?.statusCode == 401) {
          _log('✅ Authentication required (401) - Working correctly!');
        } else {
          _log('⚠️  Got: ${e.toString().split('\n').first}');
        }
      }
      _log('');

      setState(() {
        _status = '✅ API Connection Successful!';
        _statusColor = Colors.green;
        _testing = false;
      });

      _log('🎉 SUCCESS: API is reachable and working!');
      _log('');
      _log('Next Steps:');
      _log('1. Test authentication in Postman');
      _log('2. Get a valid auth token');
      _log('3. Update your app to use the token');

    } on DioException catch (e) {
      setState(() {
        _status = '❌ Connection Failed';
        _statusColor = Colors.red;
        _testing = false;
      });

      _log('');
      _log('❌ ERROR: Cannot connect to API');
      _log('Error Type: ${e.type}');
      _log('Error Message: ${e.message}');
      _log('');
      _log('Possible Causes:');
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        _log('1. ❌ API server might be down');
        _log('2. ❌ Check your internet connection');
        _log('3. ❌ Firewall might be blocking the connection');
        _log('4. ❌ IP address might be wrong');
        _log('');
        _log('Quick Tests:');
        _log('• Open https://151.245.140.91/docs in browser');
        _log('• Ping 151.245.140.91 from terminal');
        _log('• Check if you can access the server from WiFi');
      } else {
        _log('Unexpected error type');
        _log('Full error: $e');
      }

    } catch (e) {
      setState(() {
        _status = '❌ Unexpected Error';
        _statusColor = Colors.red;
        _testing = false;
      });

      _log('');
      _log('❌ UNEXPECTED ERROR');
      _log('Error: $e');
    }
  }

  void _log(String message) {
    setState(() {
      _logs.add(message);
    });
    print(message);
  }
}

