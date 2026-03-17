import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/station_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stationProvider = Provider.of<StationProvider>(context);
    final stations = stationProvider.stations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Stations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Profile action placeholder
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: stations.length,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, index) {
          final station = stations[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              leading: const Icon(Icons.ev_station, size: 48, color: Colors.teal),
              title: Text(
                station.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(station.address),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: station.status == 'Available' ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(station.status),
                      const Spacer(),
                      Text('${station.connectors.length} Connectors')
                    ],
                  )
                ],
              ),
              onTap: () {
                context.push('/station/${station.id}');
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/scanner');
        },
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        label: const Text('Scan to Charge', style: TextStyle(color: Colors.white)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
