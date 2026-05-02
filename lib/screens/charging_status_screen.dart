import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';
import '../providers/charging_session_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/glow_button.dart';
import '../utils/theme.dart';

class ChargingStatusScreen extends StatelessWidget {
  const ChargingStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Charging Dashboard', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
                  AppTheme.surfaceLight,
                  AppTheme.backgroundBlack,
                  AppTheme.backgroundBlack,
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Consumer<ChargingSessionProvider>(
              builder: (context, session, child) {
                if (session.activeConnector == null) {
                  return Center(child: Text('No active session.', style: Theme.of(context).textTheme.bodyLarge));
                }

                if (session.state == ChargingState.paying) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.pushReplacement('/payment');
                  });
                  return const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen));
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
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.electricBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.electricBlue.withOpacity(0.3)),
                              ),
                              child: Text(
                                'Connector: ${session.activeConnector?.type} (${session.activeConnector?.powerKw} kW)',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.electricBlue),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Animated Charging Graphic
                      SizedBox(
                        height: 280,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glowing background for charging state
                            if (isCharging)
                              Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.neonGreen.withOpacity(0.15),
                                      blurRadius: 60,
                                      spreadRadius: 30,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: AppTheme.neonGreen.withOpacity(0.5),
                                    width: 2,
                                  )
                                ),
                              ),
                            
                            // Lottie Animation (Fallback to Icon if failing)
                            if (isCharging)
                              Lottie.network(
                                'https://lottie.host/80dc178f-ef81-4eb2-8af5-430939eb9f8c/u3A1rC9OqA.json',
                                width: 280,
                                height: 280,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.bolt, size: 100, color: AppTheme.neonGreen);
                                },
                              )
                            else
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _getStatusColor(session.state).withOpacity(0.3),
                                    width: 4,
                                  )
                                ),
                                child: Icon(
                                  Icons.ev_station,
                                  size: 80,
                                  color: _getStatusColor(session.state).withOpacity(0.8),
                                ),
                              ),

                            // Central Text
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isCharging)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.backgroundBlack.withOpacity(0.4),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                                        ),
                                        child: Text(
                                          '${session.kwhDelivered.toStringAsFixed(2)} kWh',
                                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                            color: AppTheme.neonGreen,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                Text(
                                  _getStatusText(session.state),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(session.state),
                                    letterSpacing: 2.0,
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
                              _buildStatColumn(context, 'Time', _formatDuration(session.durationSeconds)),
                              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
                              _buildStatColumn(context, 'Cost', '฿${session.currentCost.toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 48),

                      // Action Buttons
                      if (session.state == ChargingState.idle)
                        SizedBox(
                          width: double.infinity,
                          child: GlowButton(
                            text: 'Start Charging', 
                            color: AppTheme.neonGreen, 
                            icon: Icons.power,
                            onPressed: session.startCharging,
                          ),
                        )
                      else if (isStarting)
                        const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen))
                      else if (isCharging)
                        SizedBox(
                          width: double.infinity,
                          child: GlowButton(
                            text: 'Stop Charging', 
                            color: AppTheme.errorRed, 
                            icon: Icons.stop,
                            onPressed: session.stopCharging,
                          ),
                        )
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

  Widget _buildStatColumn(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.displaySmall),
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
        return AppTheme.electricBlue;
      case ChargingState.starting:
        return AppTheme.warningOrange;
      case ChargingState.charging:
        return AppTheme.neonGreen;
      default:
        return AppTheme.errorRed;
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
