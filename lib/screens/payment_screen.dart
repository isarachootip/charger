import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/charging_session_provider.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<ChargingSessionProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Checkout'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              'Charging Complete',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildSummaryRow('Energy Delivered', '${session.kwhDelivered.toStringAsFixed(2)} kWh'),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Duration', _formatDuration(session.durationSeconds)),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Rate', '฿${session.activeConnector?.pricePerKwh} / kWh'),
                    const Divider(height: 32, thickness: 2),
                    _buildSummaryRow(
                      'Total Amount',
                      '฿${session.currentCost.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                _showMockPaymentDialog(context, session);
              },
              icon: const Icon(Icons.qr_code, color: Colors.white),
              label: const Text('Pay via PromptPay', style: TextStyle(color: Colors.white, fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF134A81), // Bank blue color
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                _showMockPaymentDialog(context, session);
              },
              icon: const Icon(Icons.credit_card),
              label: const Text('Pay via Credit Card', style: TextStyle(fontSize: 18)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 24 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.teal : Colors.black,
          ),
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
          title: const Text('Processing Payment'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Simulating API call to Payment Gateway...'),
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
          const SnackBar(content: Text('Payment Successful! Thank you.'), backgroundColor: Colors.green),
        );
        
        session.reset();
        context.go('/'); // Return home and clear stack
      }
    });
  }
}
