class BusRoute {
  final String busId;
  final String from;
  final String to;
  final String departure;
  final String arrival;
  final int fare;

  BusRoute({
    required this.busId,
    required this.from,
    required this.to,
    required this.departure,
    required this.arrival,
    required this.fare,
  });

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    return BusRoute(
      busId: json['busId'],
      from: json['from'],
      to: json['to'],
      departure: json['departure'],
      arrival: json['arrival'],
      fare: json['fare'],
    );
  }
}
