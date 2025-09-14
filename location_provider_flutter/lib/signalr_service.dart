import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:location_provider_flutter/config/app_config.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// class SignalRServiceClass {
//   late final HubConnection _hubConnection;

//   SignalRServiceClass() {
//     final hubUrl =
//         // "https://bus-management-backend-d5behmecb0fzg6eq.southindia-01.azurewebsites.net/location";
//         "https://localhost:7050/location-hub";

//     _hubConnection = HubConnectionBuilder()
//         .withUrl(hubUrl,
//             options: HttpConnectionOptions(
//               transport: HttpTransportType.WebSockets,
//             ))
//         .withAutomaticReconnect(
//       retryDelays: [0, 2000, 5000, 10000], // in milliseconds
//     ).build();

//     _hubConnection.on("receiveAcknowledgement", confirmConnection);
//     _hubConnection.onclose(
//       ({error}) => print("connection closed"),
//     );
//   }

//   Future<void> startConnection() async {
//     print("connecting...");
//     await _hubConnection.start()?.catchError((error) => print(error));
//   }

//   void confirmConnection(arguements) {
//     print("connected");
//   }

//   Future<void> sendLocation(var location) async {
//     print(location);
//     await _hubConnection.invoke("BusLocationToClients",
//         args: [location.latitude, location.longitude]);
//   }
// }

// class SignalRServiceClass {
//   late final HubConnection _hubConnection;
//   bool _isConnecting = false;

//   SignalRServiceClass() {
//     if (Platform.isAndroid && kDebugMode) {
//       HttpOverrides.global = MyHttpOverrides();
//     }

//     final hubUrl = Platform.isAndroid
//         ? "https://10.0.2.2:7050/location-hub"
//         : "https://localhost:7050/location-hub";

//     // rest of your code

//     _hubConnection = HubConnectionBuilder()
//         .withUrl(hubUrl,
//             options: HttpConnectionOptions(
//               transport: HttpTransportType.WebSockets,
//             ))
//         .withAutomaticReconnect(
//       retryDelays: [0, 2000, 5000, 10000], // in milliseconds
//     ).build();

//     _hubConnection.on("receiveAcknowledgement", confirmConnection);

//     _hubConnection.onreconnecting(({Exception? error}) {
//       print('Connection lost. Reconnecting... Error: $error');
//       _isConnecting = true;
//     });

//     _hubConnection.onreconnected(({String? connectionId}) {
//       print('Reconnected. ConnectionId: $connectionId');
//       _isConnecting = false;
//     });

//     _hubConnection.onclose(({Exception? error}) {
//       print("Connection closed. Error: $error");
//       _isConnecting = false;
//     });
//   }

//   Future<void> startConnection() async {
//     if (_hubConnection.state == HubConnectionState.Connected) {
//       print("Already connected");
//       return;
//     }

//     if (_isConnecting) {
//       print("Connection already in progress");
//       return;
//     }

//     try {
//       _isConnecting = true;
//       print("Connecting...");
//       await _hubConnection.start();
//       print("Connected successfully");
//       _isConnecting = false;
//     } catch (error) {
//       _isConnecting = false;
//       print("Failed to connect: $error");
//       rethrow;
//     }
//   }

//   void confirmConnection(arguments) {
//     print("Connection confirmed with server");
//   }

//   Future<void> sendLocation(var location) async {
//     // Ensure connection is established
//     if (_hubConnection.state != HubConnectionState.Connected) {
//       print(
//           "Connection not established. Current state: ${_hubConnection.state}");

//       // Try to reconnect if not already connecting
//       if (!_isConnecting) {
//         await startConnection();
//       }

//       // Wait a bit for connection to establish
//       int retries = 0;
//       while (_hubConnection.state != HubConnectionState.Connected &&
//           retries < 10) {
//         await Future.delayed(Duration(milliseconds: 500));
//         retries++;
//       }

//       if (_hubConnection.state != HubConnectionState.Connected) {
//         throw Exception("Cannot send location: Connection not established");
//       }
//     }

//     try {
//       print(
//           "Sending location: lat=${location.latitude}, lng=${location.longitude}");
//       await _hubConnection.invoke("BusLocationToClients",
//           args: [location.latitude, location.longitude]);
//       print("Location sent successfully");
//     } catch (error) {
//       print("Error sending location: $error");
//       rethrow;
//     }
//   }

//   bool get isConnected => _hubConnection.state == HubConnectionState.Connected;

//   Future<void> stopConnection() async {
//     try {
//       await _hubConnection.stop();
//       print("Connection stopped");
//     } catch (error) {
//       print("Error stopping connection: $error");
//     }
//   }
// }

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback = (cert, host, port) => true;
//   }
// }

class SignalRServiceClass {
  late final HubConnection _hubConnection;
  bool _isConnecting = false;
  final routeId = 1;

  SignalRServiceClass() {
    if (Platform.isAndroid && kDebugMode) {
      HttpOverrides.global = MyHttpOverrides();
    }

    final hubUrl = AppConfig.hubUrl;
    print(hubUrl);

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

  Future<void> sendLocation(var location) async {
    if (_hubConnection.state != HubConnectionState.Connected) {
      throw Exception(
          "Cannot send location: Connection not established (current state: ${_hubConnection.state})");
    }

    try {
      print(
          "Sending location: lat=${location.latitude}, lng=${location.longitude}");
      await _hubConnection.invoke(
        "SendLocationUpdate",
        args: [routeId, location.latitude, location.longitude],
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
