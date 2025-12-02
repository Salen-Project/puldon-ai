import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_dashboard.dart';
import 'api_monitor.dart';

/// Floating button to open API monitoring dashboard
/// Add this to your app to easily access the monitor
class ApiMonitorFloatingButton extends ConsumerWidget {
  const ApiMonitorFloatingButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiCalls = ref.watch(apiMonitorProvider);
    final hasNewCalls = apiCalls.isNotEmpty;

    return FloatingActionButton(
      heroTag: 'api_monitor_fab',
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ApiMonitoringDashboard(),
          ),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.monitor_heart),
          if (hasNewCalls)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Center(
                  child: Text(
                    apiCalls.length > 99 ? '99+' : '${apiCalls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Alternative: Mini monitor widget that can be placed anywhere
class ApiMonitorMiniWidget extends ConsumerWidget {
  const ApiMonitorMiniWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monitor = ref.watch(apiMonitorProvider.notifier);
    final stats = monitor.getStats();

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ApiMonitoringDashboard(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.api, color: Colors.blue),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${stats['total']} calls',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${stats['success']} success, ${stats['error']} errors',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.blue, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Draggable floating monitor button (always visible)
class DraggableApiMonitor extends StatefulWidget {
  const DraggableApiMonitor({super.key});

  @override
  State<DraggableApiMonitor> createState() => _DraggableApiMonitorState();
}

class _DraggableApiMonitorState extends State<DraggableApiMonitor> {
  Offset position = const Offset(20, 100);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        feedback: _buildButton(isDragging: true),
        childWhenDragging: const SizedBox.shrink(),
        onDragEnd: (details) {
          setState(() {
            final screenSize = MediaQuery.of(context).size;
            final dx = details.offset.dx.clamp(
              0.0,
              screenSize.width - 60,
            );
            final dy = details.offset.dy.clamp(
              0.0,
              screenSize.height - 60,
            );
            position = Offset(dx, dy);
          });
        },
        child: _buildButton(),
      ),
    );
  }

  Widget _buildButton({bool isDragging = false}) {
    return Consumer(
      builder: (context, ref, child) {
        final apiCalls = ref.watch(apiMonitorProvider);

        return Material(
          elevation: isDragging ? 8 : 4,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: isDragging
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ApiMonitoringDashboard(),
                      ),
                    );
                  },
            customBorder: const CircleBorder(),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Center(
                    child: Icon(
                      Icons.monitor_heart,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  if (apiCalls.isNotEmpty)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Center(
                          child: Text(
                            apiCalls.length > 99
                                ? '99+'
                                : '${apiCalls.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
