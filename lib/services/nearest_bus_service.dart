import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';

class NearestBusService {
  /// Request permission and get current location
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission permanently denied.");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Load bus stands from JSON file in assets
  static Future<List<dynamic>> loadBusStands() async {
    final jsonStr = await rootBundle.loadString('assets/bus_stands.json');
    return json.decode(jsonStr);
  }

  /// Calculate distance using Haversine formula (in meters)
  static double haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // Earth radius in meters
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _degToRad(double deg) => deg * pi / 180;

  /// Get nearest bus stands sorted by distance
  static Future<List<Map<String, dynamic>>> getNearestStands() async {
    final position = await getCurrentLocation();
    final List<dynamic> stands = await loadBusStands();

    final List<Map<String, dynamic>> withDistance = stands.map((stand) {
      final distance = haversine(
        position.latitude,
        position.longitude,
        stand['latitude'],
        stand['longitude'],
      );
      return {
        'name': stand['name'],
        'city': stand['city'],
        'latitude': stand['latitude'],
        'longitude': stand['longitude'],
        'distance': distance,
      };
    }).toList();

    withDistance.sort((a, b) => a['distance'].compareTo(b['distance']));
    return withDistance;
  }
}
