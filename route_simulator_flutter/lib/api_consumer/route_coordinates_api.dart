import 'api_client.dart';
import 'package:route_simulator_flutter/models/routeCoordinates.dart';

final ApiClient _apiClient = ApiClient();

Future<List<RouteCoordinate>> getRouteCoordinates(int routeId) async {
  final List<dynamic> data = await _apiClient.get("/RouteCoordinate/$routeId");
  return data
      .map((json) => RouteCoordinate.fromJson(json as Map<String, dynamic>))
      .toList();
}
