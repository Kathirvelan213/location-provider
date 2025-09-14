import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:route_simulator_flutter/config/app_config.dart';
import 'package:signalr_netcore/signalr_client.dart';

class SignalRService {
  late final HubConnection _hubConnection;
  bool _isConnecting = false;

  SignalRService() {
    if (Platform.isAndroid && kDebugMode) {
      HttpOverrides.global = MyHttpOverrides();
    }

    final hubUrl = AppConfig.hubUrl;

    _hubConnection = HubConnectionBuilder()
        .withUrl(
      hubUrl,
      options: HttpConnectionOptions(
        transport: HttpTransportType.WebSockets,
      ),
    )
        .withAutomaticReconnect(
      retryDelays: [0, 2000, 5000, 10000], // ms
    ).build();
    _hubConnection.serverTimeoutInMilliseconds = 30000; // 30s
    _hubConnection.keepAliveIntervalInMilliseconds = 15000;
    // Handlers
    _hubConnection.on("receiveAcknowledgement", confirmConnection);

    _hubConnection.onreconnecting(({Exception? error}) {
      print("Connection lost. Reconnecting... Error: $error");
      _isConnecting = true;
    });

    _hubConnection.onreconnected(({String? connectionId}) {
      print("Reconnected. ConnectionId: $connectionId");
      _isConnecting = false;
    });

    _hubConnection.onclose(({Exception? error}) {
      print("Connection closed. Error: $error");
      _isConnecting = false;
    });
  }

  Future<void> startConnection() async {
    if (_hubConnection.state == HubConnectionState.Connected) {
      print("Already connected");
      return;
    }

    if (_isConnecting) {
      print("Connection already in progress");
      return;
    }

    try {
      _isConnecting = true;
      print("Connecting...");
      await _hubConnection.start();
      print("Connected successfully");
    } catch (error) {
      print("Failed to connect: $error");
      rethrow;
    } finally {
      _isConnecting = false;
    }
  }

  void confirmConnection(arguments) {
    print("Connection confirmed with server");
  }

  Future<void> sendLocation(int routeId, var location) async {
    if (_hubConnection.state != HubConnectionState.Connected) {
      throw Exception(
          "Cannot send location: Connection not established (current state: ${_hubConnection.state})");
    }

    try {
      print("Sending location: lat=${location.lat}, lng=${location.lng}");
      await _hubConnection.invoke(
        "SendLocationUpdate",
        args: [routeId, location.lat, location.lng],
      );
      print("Location sent successfully");
    } catch (error) {
      print("Error sending location: $error");
      rethrow;
    }
  }

  bool get isConnected => _hubConnection.state == HubConnectionState.Connected;

  Future<void> stopConnection() async {
    try {
      await _hubConnection.stop();
      print("Connection stopped");
    } catch (error) {
      print("Error stopping connection: $error");
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}
