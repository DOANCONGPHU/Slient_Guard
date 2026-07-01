import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  ConnectivityService();

  Future<void> initialize() async {
    if (kIsWeb) return;

    int attempts = 0;
    while (attempts < 5) {
      try {
        _statusSubscription?.cancel();
        _statusSubscription = InternetConnection()
            .onStatusChange
            .listen(_handleStatusChange);
        return; // success
      } catch (e) {
        attempts++;
        await Future.delayed(Duration(milliseconds: 300 * attempts));
      }
    }
  }

  void _handleStatusChange(InternetStatus status) {
    debugPrint('[ConnectivityService] onStatusChange fired: $status');
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () async {
      final connected = status == InternetStatus.connected;
      debugPrint('[ConnectivityService] debounce timer triggered, isConnected=$connected, lastState=$_lastState');
      
      if (_lastState == false && connected == true) {
        _onNetworkRestoredController.add(null);
      }
      _lastState = connected;
      _onConnectivityChangedController.add(connected);
    });
  }

  final _onConnectivityChangedController = StreamController<bool>.broadcast();
  final _onNetworkRestoredController = StreamController<void>.broadcast();

  StreamSubscription<InternetStatus>? _statusSubscription;
  Timer? _debounceTimer;
  bool? _lastState;

  Stream<bool> get onConnectivityChanged =>
      _onConnectivityChangedController.stream;
  Stream<void> get onNetworkRestored => _onNetworkRestoredController.stream;

  Future<bool> get isConnected async {
    if (kIsWeb) return true;
    if (_lastState != null) return _lastState!;
    final hasConnection = await InternetConnection().hasInternetAccess;
    return hasConnection;
  }

  void dispose() {
    _debounceTimer?.cancel();
    _statusSubscription?.cancel();
    _onConnectivityChangedController.close();
    _onNetworkRestoredController.close();
  }
}
