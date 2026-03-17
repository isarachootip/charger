import 'package:flutter/material.dart';
import '../models/station.dart';

class StationProvider with ChangeNotifier {
  final List<Station> _stations = [
    Station(
      id: 'ST_001',
      name: 'EV Station - Central Plaza',
      address: '123 Main St, City Center',
      latitude: 13.7563,
      longitude: 100.5018,
      status: 'Available',
      connectors: [
        Connector(
          id: 'CONN_001_1',
          type: 'CCS2',
          powerKw: 120.0,
          pricePerKwh: 7.5,
          status: 'Available',
        ),
        Connector(
          id: 'CONN_001_2',
          type: 'Type 2',
          powerKw: 22.0,
          pricePerKwh: 5.5,
          status: 'Occupied',
        ),
      ],
    ),
    Station(
      id: 'ST_002',
      name: 'EV Station - Highway Rest Area',
      address: 'KM 45 Highway',
      latitude: 13.8000,
      longitude: 100.5500,
      status: 'Available',
      connectors: [
        Connector(
          id: 'CONN_002_1',
          type: 'CCS2',
          powerKw: 50.0,
          pricePerKwh: 6.5,
          status: 'Available',
        ),
      ],
    ),
  ];

  List<Station> get stations => _stations;

  Station? getStationById(String id) {
    try {
      return _stations.firstWhere((station) => station.id == id);
    } catch (e) {
      return null;
    }
  }
}
