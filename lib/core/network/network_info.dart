import 'package:connectivity_plus/connectivity_plus.dart';

/// Network information utility for checking connectivity status
abstract class NetworkInfo {
  /// Check if device is connected to the internet
  Future<bool> get isConnected;

  /// Get current connectivity status
  Future<ConnectivityResult> get connectivityStatus;

  /// Stream of connectivity changes
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
}

/// Implementation of NetworkInfo using connectivity_plus package
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return _isConnectedResult(result);
  }

  @override
  Future<ConnectivityResult> get connectivityStatus async {
    final results = await connectivity.checkConnectivity();
    // Return the first result or none if empty
    return results.isNotEmpty ? results.first : ConnectivityResult.none;
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return connectivity.onConnectivityChanged;
  }

  /// Helper method to determine if connectivity result indicates connection
  bool _isConnectedResult(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;

    for (var result in results) {
      if (result != ConnectivityResult.none) {
        return true;
      }
    }
    return false;
  }
}
