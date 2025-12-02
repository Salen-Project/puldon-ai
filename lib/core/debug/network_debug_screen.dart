import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/network_test.dart';
import '../constants/app_config.dart';

/// Debug screen to test network connectivity
class NetworkDebugScreen extends StatefulWidget {
  const NetworkDebugScreen({super.key});

  @override
  State<NetworkDebugScreen> createState() => _NetworkDebugScreenState();
}

class _NetworkDebugScreenState extends State<NetworkDebugScreen> {
  bool _isLoading = false;
  String _results = 'Tap "Run Diagnostics" to test network connectivity';
  bool _hasInternet = false;
  bool _canReachServer = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('Network Diagnostics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // API Info
              _buildInfoCard(
                title: 'API Configuration',
                children: [
                  _buildInfoRow('Base URL', AppConfig.apiBaseUrl),
                  _buildInfoRow('Mock Mode', AppConfig.useMockData ? 'Enabled' : 'Disabled'),
                  _buildInfoRow('API Monitor', AppConfig.enableApiMonitor ? 'Enabled' : 'Disabled'),
                ],
              ),

              const SizedBox(height: 24),

              // Status Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatusCard(
                      'Internet',
                      _hasInternet,
                      Icons.wifi,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatusCard(
                      'API Server',
                      _canReachServer,
                      Icons.dns,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Run Diagnostics Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _runDiagnostics,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Run Diagnostics',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Results
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Results',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.white70),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _results));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Results copied to clipboard'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 400),
                      child: SingleChildScrollView(
                        child: Text(
                          _results,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Tips
              _buildInfoCard(
                title: 'Quick Tips',
                children: [
                  _buildTipRow('1', 'Make sure API server is running'),
                  _buildTipRow('2', 'Try restarting iOS Simulator'),
                  _buildTipRow('3', 'Run: flutter clean && flutter pub get'),
                  _buildTipRow('4', 'Check Info.plist has NSAppTransportSecurity'),
                  _buildTipRow('5', 'Try a different iOS Simulator'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipRow(String number, String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String label, bool status, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: status
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status ? Colors.green : Colors.red,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: status ? Colors.green : Colors.red,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status ? 'OK' : 'Failed',
            style: TextStyle(
              color: status ? Colors.green : Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isLoading = true;
      _results = 'Running diagnostics...\n\n';
    });

    try {
      final buffer = StringBuffer();
      buffer.writeln('========================================');
      buffer.writeln('🔍 NETWORK DIAGNOSTICS');
      buffer.writeln('========================================\n');

      buffer.writeln('Testing API: ${AppConfig.apiBaseUrl}\n');

      // Test 1: Internet connectivity
      buffer.writeln('1️⃣ Testing internet connectivity...');
      final hasInternet = await NetworkTest.hasInternetConnection();
      buffer.writeln('   ${hasInternet ? "✅" : "❌"} Internet: ${hasInternet ? "Connected" : "Not connected"}\n');

      // Test 2: API server reachability
      buffer.writeln('2️⃣ Testing API server reachability...');
      final canReach = await NetworkTest.canReachApiServer(AppConfig.apiBaseUrl);
      buffer.writeln('   ${canReach ? "✅" : "❌"} Server: ${canReach ? "Reachable" : "Not reachable"}\n');

      // Test 3: API endpoints
      buffer.writeln('3️⃣ Testing API endpoints...');
      final apiTest = await NetworkTest.testApiEndpoint(AppConfig.apiBaseUrl);

      buffer.writeln('   Docs endpoint: ${apiTest['docsEndpoint']['success'] ? "✅" : "❌"}');
      if (!apiTest['docsEndpoint']['success']) {
        buffer.writeln('      Error: ${apiTest['docsEndpoint']['error']}');
      }

      buffer.writeln('   Root endpoint: ${apiTest['rootEndpoint']['success'] ? "✅" : "❌"}');
      if (!apiTest['rootEndpoint']['success']) {
        buffer.writeln('      Error: ${apiTest['rootEndpoint']['error']}');
      }

      buffer.writeln('\n========================================');
      buffer.writeln('📊 SUMMARY');
      buffer.writeln('========================================\n');

      if (hasInternet && canReach) {
        buffer.writeln('✅ Network is working correctly!');
        buffer.writeln('✅ API server is reachable!');

        if (apiTest['docsEndpoint']['success'] || apiTest['rootEndpoint']['success']) {
          buffer.writeln('✅ API endpoints are responding!');
          buffer.writeln('\n🎉 Everything looks good! You can use the app now.');
        } else {
          buffer.writeln('⚠️  API endpoints are not responding as expected.');
          buffer.writeln('   This might be a configuration issue.');
        }
      } else {
        if (!hasInternet) {
          buffer.writeln('❌ No internet connection detected.');
          buffer.writeln('   Please check your network settings.');
        }
        if (!canReach) {
          buffer.writeln('❌ Cannot reach API server at ${AppConfig.apiBaseUrl}');
          buffer.writeln('   Possible issues:');
          buffer.writeln('   - Server is down');
          buffer.writeln('   - Wrong IP address or port');
          buffer.writeln('   - Firewall blocking connection');
          buffer.writeln('   - iOS simulator network issues');
          buffer.writeln('\n💡 Try:');
          buffer.writeln('   1. Restart iOS Simulator');
          buffer.writeln('   2. Run: flutter clean && flutter pub get');
          buffer.writeln('   3. Try a different simulator');
          buffer.writeln('   4. Check NETWORK_TROUBLESHOOTING.md');
        }
      }

      buffer.writeln('\n========================================');

      setState(() {
        _results = buffer.toString();
        _hasInternet = hasInternet;
        _canReachServer = canReach;
      });
    } catch (e) {
      setState(() {
        _results = 'Error running diagnostics:\n\n$e\n\nPlease check console for details.';
        _hasInternet = false;
        _canReachServer = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
