class RouteCoordinate {
  final int coordId;
  final int routeId;
  final int sequence;
  final double lat;
  final double lng;

  RouteCoordinate({
    required this.coordId,
    required this.routeId,
    required this.sequence,
    required this.lat,
    required this.lng,
  });

  factory RouteCoordinate.fromJson(Map<String, dynamic> json) {
    return RouteCoordinate(
      coordId: json['coordId'],
      routeId: json['routeId'],
      sequence: json['sequence'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}
