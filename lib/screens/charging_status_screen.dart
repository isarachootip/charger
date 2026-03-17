import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../providers/charging_session_provider.dart';
import '../widgets/glass_card.dart';

class ChargingStatusScreen extends StatelessWidget {
  const ChargingStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Charging Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false, 
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F3460),
                  Color(0xFF16213E),
                  Color(0xFF1A1A2E),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Consumer<ChargingSessionProvider>(
              builder: (context, session, child) {
                if (session.activeConnector == null) {
                  return const Center(child: Text('No active session.', style: TextStyle(color: Colors.white)));
                }

                if (session.state == ChargingState.paying) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.pushReplacement('/payment');
                  });
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)));
                }

                final isCharging = session.state == ChargingState.charging;
                final isStarting = session.state == ChargingState.starting;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              session.activeStation?.name ?? 'Unknown Station',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Connector: ${session.activeConnector?.type} (${session.activeConnector?.powerKw} kW)',
                                style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Animated Charging Graphic
                      SizedBox(
                        height: 250,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glowing background for charging state
                            if (isCharging)
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00E676).withOpacity(0.3),
                                      blurRadius: 50,
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                            
                            // Lottie Animation (Fallback to Icon if failing)
                            if (isCharging)
                              Lottie.network(
                                'https://lottie.host/80dc178f-ef81-4eb2-8af5-430939eb9f8c/u3A1rC9OqA.json', // Sample abstract energy ring
                                width: 250,
                                height: 250,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.bolt, size: 100, color: Color(0xFF00E676));
                                },
                              )
                            else
                              Icon(
                                Icons.ev_station,
                                size: 120,
                                color: _getStatusColor(session.state).withOpacity(0.8),
                              ),

                            // Central Text
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isCharging)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                      child: Text(
                                        '${session.kwhDelivered.toStringAsFixed(2)} kWh',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  _getStatusText(session.state),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(session.state),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Live Stats Grid
                      if (isCharging || session.state == ChargingState.stopped)
                        GlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatColumn('Time', _formatDuration(session.durationSeconds)),
                              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
                              _buildStatColumn('Cost', '฿${session.currentCost.toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 40),

                      // Action Buttons
                      if (session.state == ChargingState.idle)
                        _buildActionBtn('Start Charging', theme.primaryColor, session.startCharging)
                      else if (isStarting)
                        const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)))
                      else if (isCharging)
                        _buildActionBtn('Stop Charging', Colors.redAccent, session.stopCharging)
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, Color color, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6))),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
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
        return const Color(0xFF00B0FF);
      case ChargingState.starting:
        return Colors.orangeAccent;
      case ChargingState.charging:
        return const Color(0xFF00E676);
      default:
        return Colors.redAccent;
    }
  }

  String _getStatusText(ChargingState state) {
    switch (state) {
      case ChargingState.idle:
        return 'READY TO CHARGE';
      case ChargingState.starting:
        return 'COMMUNICATING...';
      case ChargingState.charging:
        return 'CHARGING';
      default:
        return 'STOPPED';
    }
  }
}
