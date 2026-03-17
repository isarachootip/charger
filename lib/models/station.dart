class Station {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final List<Connector> connectors;
  final String status; // e.g., 'Available', 'In Use', 'Offline'

  Station({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.connectors,
    required this.status,
  });
}

class Connector {
  final String id;
  final String type; // e.g., 'CCS2', 'Type 2'
  final double powerKw;
  final double pricePerKwh;
  final String status; // 'Available', 'Occupied'

  Connector({
    required this.id,
    required this.type,
    required this.powerKw,
    required this.pricePerKwh,
    required this.status,
  });
}
