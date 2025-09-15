import 'dart:async';

import 'package:route_simulator_flutter/models/routeCoordinates.dart';

/// Emits coordinates [lat, lng] one by one with a delay
class MockLocationStreamer {
  final List<RouteCoordinate> coordinates;
  final Duration interval;
  int step = 1;

  MockLocationStreamer(this.coordinates,
      {this.interval = const Duration(milliseconds: 1)});

  Stream<RouteCoordinate> start() async* {
    int batchSize = 100;
    for (int i = 0; i < coordinates.length; i += step) {
      yield coordinates[i];
      if ((i + 1) % batchSize == 0) {
        await Future.delayed(interval);
      }
    }
  }
}
