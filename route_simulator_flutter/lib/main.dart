import 'package:flutter/material.dart';
import 'package:route_simulator_flutter/api_consumer/route_coordinates_api.dart';
import 'package:route_simulator_flutter/movement_simulator.dart';
import 'signalr_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final SignalRService signalrservice = SignalRService();
void main() async {
  await dotenv.load(fileName: ".env");
  await signalrservice.startConnection();
  int routeId = 1;
  runApp(MyApp());

  final routeCoords = await getRouteCoordinates(1);
  // print(routeCoords);

  final mock =
      MockLocationStreamer(routeCoords, interval: Duration(seconds: 1));

  mock.start().listen((coord) {
    signalrservice.sendLocation(routeId, coord);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }
}
