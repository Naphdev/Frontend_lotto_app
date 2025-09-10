import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectivityProvider with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  bool _isConnected = true;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;

  // Getters
  bool get isConnected => _isConnected;
  ConnectivityResult get connectionStatus => _connectionStatus;
  bool get isOffline => !_isConnected;

  // Initialize connectivity monitoring
  void initializeConnectivity() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
      onError: (error) {
        debugPrint('Connectivity error: $error');
      },
    );

    // Check initial connectivity status
    _checkInitialConnectivity();
  }

  // Check initial connectivity
  Future<void> _checkInitialConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('Error checking initial connectivity: $e');
    }
  }

  // Update connection status
  void _updateConnectionStatus(ConnectivityResult result) {
    _connectionStatus = result;
    _isConnected = result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;

    notifyListeners();
  }

  // Check if specific connection type is available
  bool hasConnectionType(ConnectivityResult type) {
    return _connectionStatus == type;
  }

  // Get connection type as string
  String get connectionTypeString {
    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.none:
        return 'ไม่มีการเชื่อมต่อ';
      default:
        return 'ไม่ทราบ';
    }
  }

  // Dispose
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
