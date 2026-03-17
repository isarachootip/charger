import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/station_provider.dart';
import '../providers/charging_session_provider.dart';

class StationDetailsScreen extends StatelessWidget {
  final String stationId;

  const StationDetailsScreen({super.key, required this.stationId});

  @override
  Widget build(BuildContext context) {
    final stationProvider = Provider.of<StationProvider>(context);
    final station = stationProvider.getStationById(stationId);

    if (station == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Station not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Station Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              station.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(station.address, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            const Text(
              'Connectors',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...station.connectors.map((connector) {
              final isAvailable = connector.status == 'Available';
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            connector.type,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Chip(
                            label: Text(
                              connector.status,
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: isAvailable ? Colors.green : Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Power: ${connector.powerKw} kW'),
                      Text('Price: ฿${connector.pricePerKwh} / kWh'),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isAvailable
                              ? () {
                                  // Set active session context and simulate jumping to charging control
                                  Provider.of<ChargingSessionProvider>(context, listen: false)
                                      .prepareSession(station, connector);
                                  context.push('/charging');
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAvailable ? Colors.teal : Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            isAvailable ? 'Prepare to Charge' : 'Not Available',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
