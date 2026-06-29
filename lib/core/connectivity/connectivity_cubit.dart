import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/services/connectivity_service.dart';

abstract class ConnectivityState {
  const ConnectivityState();
}

class ConnectivityOnline extends ConnectivityState {
  const ConnectivityOnline();
}

class ConnectivityOffline extends ConnectivityState {
  const ConnectivityOffline();
}

class ConnectivityCubit extends Cubit<ConnectivityState>
    with WidgetsBindingObserver {
  ConnectivityCubit(this._connectivityService)
    : super(const ConnectivityOnline()) {
    WidgetsBinding.instance.addObserver(this);
    _checkInitialState();
    _subscription = _connectivityService.onConnectivityChanged.listen((
      isOnline,
    ) {
      if (isOnline) {
        emit(const ConnectivityOnline());
      } else {
        emit(const ConnectivityOffline());
      }
    });
  }

  final ConnectivityService _connectivityService;
  StreamSubscription<bool>? _subscription;

  Future<void> _checkInitialState() async {
    final isOnline = await _connectivityService.isConnected;
    if (isOnline) {
      emit(const ConnectivityOnline());
    } else {
      emit(const ConnectivityOffline());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('[ConnectivityCubit] didChangeAppLifecycleState: $state');
    if (state == AppLifecycleState.resumed) {
      _checkInitialState();
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    return super.close();
  }
}
