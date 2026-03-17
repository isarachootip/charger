import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/charging_session_provider.dart';

class ChargingStatusScreen extends StatelessWidget {
  const ChargingStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charging Dashboard'),
        automaticallyImplyLeading: false, // Prevent going back while charging
      ),
      body: Consumer<ChargingSessionProvider>(
        builder: (context, session, child) {
          if (session.activeConnector == null) {
            return const Center(child: Text('No active session.'));
          }

          // Handle auto-navigation to payment
          if (session.state == ChargingState.paying) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.pushReplacement('/payment');
            });
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  session.activeStation?.name ?? 'Unknown Station',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Connector: ${session.activeConnector?.type} (${session.activeConnector?.powerKw} kW)',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Charging Animation / Status Circle
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getStatusColor(session.state),
                        width: 10,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getStatusText(session.state),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(session.state),
                            ),
                          ),
                          if (session.state == ChargingState.charging) ...[
                            const SizedBox(height: 8),
                            Text(
                              '${session.kwhDelivered.toStringAsFixed(2)} kWh',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Live Stats
                if (session.state == ChargingState.charging) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Time', _formatDuration(session.durationSeconds)),
                      _buildStatColumn('Est. Cost', '฿${session.currentCost.toStringAsFixed(2)}'),
                    ],
                  ),
                  const Spacer(),
                ],

                if (session.state != ChargingState.charging && session.state != ChargingState.idle && session.state != ChargingState.starting) const Spacer(),

                // Action Buttons
                if (session.state == ChargingState.idle)
                  ElevatedButton(
                    onPressed: () => session.startCharging(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Start Charging', style: TextStyle(color: Colors.white, fontSize: 18)),
                  )
                else if (session.state == ChargingState.starting)
                  const Center(child: CircularProgressIndicator())
                else if (session.state == ChargingState.charging)
                  ElevatedButton(
                    onPressed: () => session.stopCharging(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Stop Charging', style: TextStyle(color: Colors.white, fontSize: 18)),
                  )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(ChargingState state) {
    switch (state) {
      case ChargingState.idle:
        return Colors.blue;
      case ChargingState.starting:
        return Colors.amber;
      case ChargingState.charging:
        return Colors.green;
      case ChargingState.stopped:
      case ChargingState.paying:
      case ChargingState.completed:
        return Colors.red;
    }
  }

  String _getStatusText(ChargingState state) {
    switch (state) {
      case ChargingState.idle:
        return 'Ready';
      case ChargingState.starting:
        return 'Starting...';
      case ChargingState.charging:
        return 'Charging';
      case ChargingState.stopped:
      case ChargingState.paying:
      case ChargingState.completed:
        return 'Stopped';
    }
  }
}
