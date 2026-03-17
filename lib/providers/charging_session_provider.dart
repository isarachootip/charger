import 'dart:async';
import 'package:flutter/material.dart';
import '../models/station.dart';

enum ChargingState { idle, starting, charging, stopped, paying, completed }

class ChargingSessionProvider with ChangeNotifier {
  ChargingState _state = ChargingState.idle;
  Connector? _activeConnector;
  Station? _activeStation;

  double _kwhDelivered = 0.0;
  int _durationSeconds = 0;
  Timer? _timer;

  ChargingState get state => _state;
  Connector? get activeConnector => _activeConnector;
  Station? get activeStation => _activeStation;
  double get kwhDelivered => _kwhDelivered;
  int get durationSeconds => _durationSeconds;

  double get currentCost {
    if (_activeConnector == null) return 0.0;
    return _kwhDelivered * _activeConnector!.pricePerKwh;
  }

  void prepareSession(Station station, Connector connector) {
    _activeStation = station;
    _activeConnector = connector;
    _state = ChargingState.idle;
    _kwhDelivered = 0.0;
    _durationSeconds = 0;
    notifyListeners();
  }

  void startCharging() {
    if (_activeConnector == null) return;
    _state = ChargingState.starting;
    notifyListeners();

    // Simulate API delay
    Future.delayed(const Duration(seconds: 2), () {
      _state = ChargingState.charging;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _durationSeconds++;
        // Simulate gaining kWh (e.g., 50kW charger = ~0.0138 kWh per second)
        _kwhDelivered += (_activeConnector!.powerKw / 3600);
        notifyListeners();
      });
    });
  }

  void stopCharging() {
    _timer?.cancel();
    _state = ChargingState.stopped;
    notifyListeners();
    
    // Auto transition to paying
    Future.delayed(const Duration(seconds: 1), () {
      _state = ChargingState.paying;
      notifyListeners();
    });
  }

  void completePayment() {
    _state = ChargingState.completed;
    notifyListeners();
  }
  
  void reset() {
    _timer?.cancel();
    _state = ChargingState.idle;
    _activeConnector = null;
    _activeStation = null;
    _kwhDelivered = 0.0;
    _durationSeconds = 0;
    notifyListeners();
  }
}
