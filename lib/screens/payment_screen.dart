import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/charging_session_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/glow_button.dart';
import '../utils/theme.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<ChargingSessionProvider>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Checkout', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Success Animation
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.neonGreen.withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonGreen.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          )
                        ]
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: AppTheme.neonGreen,
                        size: 80,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Charging Complete!',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please review your receipt and proceed to payment.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  
                  // Digital Receipt Card
                  GlassCard(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Text(
                          'RECEIPT',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            letterSpacing: 4,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildSummaryRow(context, 'Energy Delivered', '${session.kwhDelivered.toStringAsFixed(2)} kWh'),
                        const SizedBox(height: 16),
                        _buildSummaryRow(context, 'Duration', _formatDuration(session.durationSeconds)),
                        const SizedBox(height: 16),
                        _buildSummaryRow(context, 'Rate', '฿${session.activeConnector?.pricePerKwh} / kWh'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Divider(color: Colors.white12, thickness: 1),
                        ),
                        _buildSummaryRow(
                          context,
                          'Total Amount',
                          '฿${session.currentCost.toStringAsFixed(2)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Payment Buttons
                  SizedBox(
                    width: double.infinity,
                    child: GlowButton(
                      text: 'Pay via PromptPay',
                      icon: Icons.qr_code,
                      color: AppTheme.neonGreen,
                      onPressed: () => _showMockPaymentDialog(context, session),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => _showMockPaymentDialog(context, session),
                      icon: const Icon(Icons.credit_card, color: Colors.white),
                      label: const Text('Pay via Credit Card', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal 
            ? Theme.of(context).textTheme.titleLarge 
            : Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
        ),
        Text(
          value,
          style: isTotal 
            ? Theme.of(context).textTheme.displaySmall?.copyWith(color: AppTheme.neonGreen)
            : Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showMockPaymentDialog(BuildContext context, ChargingSessionProvider session) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: AppTheme.electricBlue.withOpacity(0.3))),
          title: Center(child: Text('Processing Payment', style: Theme.of(context).textTheme.titleLarge)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const CircularProgressIndicator(color: AppTheme.neonGreen),
              const SizedBox(height: 24),
              Text(
                'Simulating API call to Payment Gateway...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );

    // Simulate payment processing delay
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close dialog
        session.completePayment();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.backgroundBlack),
                const SizedBox(width: 12),
                Text('Payment Successful! Thank you.', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.backgroundBlack)),
              ],
            ),
            backgroundColor: AppTheme.neonGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
        
        session.reset();
        context.go('/'); // Return home and clear stack
      }
    });
  }
}
