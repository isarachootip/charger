import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/station_provider.dart';
import '../providers/charging_session_provider.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final TextEditingController _fallbackController = TextEditingController();
  bool _isProcessing = false;

  void _processQrCode(String code) {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    // Mock logic: Assuming the QR code text is just the connector ID (e.g., CONN_001_1)
    final stationProvider = Provider.of<StationProvider>(context, listen: false);
    
    // Find station that has this connector
    for (var station in stationProvider.stations) {
      for (var connector in station.connectors) {
        if (connector.id == code || code == 'mock') {
          // If code is 'mock', just auto select the first available connector for demo purposes
          final c = code == 'mock' ? station.connectors.first : connector;
          
          Provider.of<ChargingSessionProvider>(context, listen: false)
              .prepareSession(station, c);
              
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Charger Found!'), backgroundColor: Colors.green),
          );
          
          context.pushReplacement('/charging');
          return;
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid QR Code / Charger Not Found'), backgroundColor: Colors.red),
    );
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    _processQrCode(barcode.rawValue!);
                    break;
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Or enter Charger ID manually (e.g., CONN_001_1):'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _fallbackController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Charger ID',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          if (_fallbackController.text.isNotEmpty) {
                            _processQrCode(_fallbackController.text);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _processQrCode('mock'),
                    child: const Text('Simulate Successful Scan (Demo)'),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
