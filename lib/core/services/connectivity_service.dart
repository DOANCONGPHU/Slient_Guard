import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  ConnectivityService() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 1500), () async {
        final connected = await isConnected;
        if (_lastState != connected) {
          if (_lastState == false && connected == true) {
            _onNetworkRestoredController.add(null);
          }
          _lastState = connected;
          _onConnectivityChangedController.add(connected);
        }
      });
    });
  }

  final _onConnectivityChangedController = StreamController<bool>.broadcast();
  final _onNetworkRestoredController = StreamController<void>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _debounceTimer;
  bool? _lastState;

  Stream<bool> get onConnectivityChanged =>
      _onConnectivityChangedController.stream;
  Stream<void> get onNetworkRestored => _onNetworkRestoredController.stream;

  Future<bool> get isConnected async {
    final hasConnection = await InternetConnection().hasInternetAccess;
    return hasConnection;
  }

  void dispose() {
    _debounceTimer?.cancel();
    _connectivitySubscription?.cancel();
    _onConnectivityChangedController.close();
    _onNetworkRestoredController.close();
  }
}
