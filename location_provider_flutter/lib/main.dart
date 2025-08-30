import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'signalr_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final SignalRServiceClass signalrservice = SignalRServiceClass();
final Location locationController = Location();
void main() async {
  await dotenv.load(fileName: ".env.production");
  runApp(MyApp());
  await signalrservice.startConnection();
  locationController.requestPermission();
  await locationController.getLocation().then((LocationData newLocation) {
    signalrservice.sendLocation(newLocation);
  });
  locationController.onLocationChanged.listen((LocationData newLocation) {
    signalrservice.sendLocation(newLocation);
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
