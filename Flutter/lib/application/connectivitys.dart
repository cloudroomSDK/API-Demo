import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class Connectivitys {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  connectivityInit() {
    _checkConnectivity();
  }

  connectivityDispose() {
    _connectivitySubscription?.cancel();
  }

  _checkConnectivity() {
    Connectivity().checkConnectivity().then((ConnectivityResult result) {
      _connectionStatus = result;
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        connectivityConnect();
      }
      _connectivitySubscription =
          _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    });
  }

  _updateConnectionStatus(ConnectivityResult result) {
    if (_connectionStatus != result) {
      _connectionStatus = result;
      if (result == ConnectivityResult.none) {
        connectivityDisconnect();
      } else if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        connectivityConnect();
      }
    }
  }

  // void checkConnectivityConnect() {}

  // void checkConnectivityyDisconnect() {}

  // ConnectivityResult.wifi || ConnectivityResult.mobile
  void connectivityConnect() {}

  // ConnectivityResult.none
  void connectivityDisconnect() {}
}
