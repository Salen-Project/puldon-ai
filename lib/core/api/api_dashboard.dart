import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'api_monitor.dart';

/// API Monitoring Dashboard
/// Shows real-time API call tracking with details
class ApiMonitoringDashboard extends ConsumerStatefulWidget {
  const ApiMonitoringDashboard({super.key});

  @override
  ConsumerState<ApiMonitoringDashboard> createState() =>
      _ApiMonitoringDashboardState();
}

class _ApiMonitoringDashboardState
    extends ConsumerState<ApiMonitoringDashboard> {
  String? selectedMethod;
  StatusFilter statusFilter = StatusFilter.all;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final monitor = ref.watch(apiMonitorProvider.notifier);
    final stats = monitor.getStats();

    final filter = ApiCallFilter(
      method: selectedMethod,
      statusFilter: statusFilter,
      searchQuery: searchQuery.isEmpty ? null : searchQuery,
    );
    final filteredCalls = ref.watch(filteredApiCallsProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 API Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All'),
                  content:
                      const Text('Are you sure you want to clear all API logs?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        monitor.clearAll();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Clear all logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Cards
          _buildStatsSection(stats),

          // Filters
          _buildFiltersSection(),

          // API Calls List
          Expanded(
            child: filteredCalls.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: filteredCalls.length,
                    itemBuilder: (context, index) {
                      final call = filteredCalls[index];
                      return _buildApiCallCard(call);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              stats['total'].toString(),
              Icons.api,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Success',
              stats['success'].toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Errors',
              stats['error'].toString(),
              Icons.error,
              Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Avg Time',
              '${stats['avgDuration']}ms',
              Icons.timer,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by endpoint or method...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() => searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              setState(() => searchQuery = value);
            },
          ),
          const SizedBox(height: 8),
          // Chips for filtering
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildMethodChip('All', null),
                _buildMethodChip('GET', 'GET'),
                _buildMethodChip('POST', 'POST'),
                _buildMethodChip('PUT', 'PUT'),
                _buildMethodChip('PATCH', 'PATCH'),
                _buildMethodChip('DELETE', 'DELETE'),
                const SizedBox(width: 16),
                _buildStatusChip('All', StatusFilter.all),
                _buildStatusChip('Success', StatusFilter.success),
                _buildStatusChip('Errors', StatusFilter.error),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodChip(String label, String? method) {
    final isSelected = selectedMethod == method;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedMethod = selected ? method : null;
          });
        },
      ),
    );
  }

  Widget _buildStatusChip(String label, StatusFilter filter) {
    final isSelected = statusFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            statusFilter = selected ? filter : StatusFilter.all;
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No API calls yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Make an API call to see it here',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildApiCallCard(ApiCall call) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          _showApiCallDetails(call);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  _buildMethodBadge(call.method),
                  const SizedBox(width: 8),
                  _buildStatusBadge(call),
                  const Spacer(),
                  if (call.duration != null)
                    Text(
                      '${call.duration!.inMilliseconds}ms',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Endpoint
              Text(
                call.endpoint,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              // Timestamp
              Text(
                call.displayTime,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodBadge(String method) {
    Color color;
    switch (method.toUpperCase()) {
      case 'GET':
        color = Colors.blue;
        break;
      case 'POST':
        color = Colors.green;
        break;
      case 'PUT':
        color = Colors.orange;
        break;
      case 'PATCH':
        color = Colors.purple;
        break;
      case 'DELETE':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        method,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ApiCall call) {
    Color color;
    String text;

    if (call.error != null) {
      color = Colors.red;
      text = 'ERROR';
    } else if (call.statusCode == null) {
      color = Colors.orange;
      text = 'PENDING';
    } else if (call.isSuccess) {
      color = Colors.green;
      text = call.statusCode.toString();
    } else {
      color = Colors.red;
      text = call.statusCode.toString();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showApiCallDetails(ApiCall call) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return ApiCallDetailsSheet(
            call: call,
            scrollController: scrollController,
          );
        },
      ),
    );
  }
}

/// Detailed view of an API call
class ApiCallDetailsSheet extends StatelessWidget {
  final ApiCall call;
  final ScrollController scrollController;

  const ApiCallDetailsSheet({
    super.key,
    required this.call,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ListView(
        controller: scrollController,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Text(
            'API Call Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),

          // Overview
          _buildSection(
            'Overview',
            [
              _buildInfoRow('Method', call.method),
              _buildInfoRow('Endpoint', call.endpoint),
              _buildInfoRow('Status', call.statusText),
              if (call.statusCode != null)
                _buildInfoRow('Status Code', call.statusCode.toString()),
              if (call.duration != null)
                _buildInfoRow('Duration', '${call.duration!.inMilliseconds}ms'),
              _buildInfoRow(
                'Timestamp',
                DateFormat('yyyy-MM-dd HH:mm:ss').format(call.timestamp),
              ),
            ],
          ),

          const Divider(height: 32),

          // Request Headers
          if (call.requestHeaders != null)
            _buildSection(
              'Request Headers',
              [_buildJsonView(call.requestHeaders!)],
            ),

          const Divider(height: 32),

          // Request Body
          if (call.requestBody != null)
            _buildSection(
              'Request Body',
              [_buildJsonView(call.requestBody)],
            ),

          const Divider(height: 32),

          // Response Body
          if (call.responseBody != null)
            _buildSection(
              'Response Body',
              [_buildJsonView(call.responseBody)],
            ),

          // Error
          if (call.error != null) ...[
            const Divider(height: 32),
            _buildSection(
              'Error',
              [
                Text(
                  call.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonView(dynamic data) {
    String jsonString;
    try {
      if (data is String) {
        // Try to parse if it's a JSON string
        final parsed = jsonDecode(data);
        jsonString = const JsonEncoder.withIndent('  ').convert(parsed);
      } else {
        jsonString = const JsonEncoder.withIndent('  ').convert(data);
      }
    } catch (e) {
      jsonString = data.toString();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              jsonString,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonString));
              },
              tooltip: 'Copy to clipboard',
            ),
          ),
        ],
      ),
    );
  }
}
