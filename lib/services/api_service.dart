import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  /// 🌐 Use your backend's base URL here
  /// - For Flutter Web: http://localhost:5000
  /// - For Android Emulator: http://10.0.2.2:5000
  /// - For Real Device: http://<your-local-IP>:5000
  static const String baseUrl = 'http://localhost:5000';

  /// Get saved token from SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Login and store JWT token
  static Future<bool> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (res.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', jsonDecode(res.body)['token']);
      return true;
    }
    return false;
  }

  /// Register new user
  static Future<bool> register(String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );
    return res.statusCode == 201;
  }

  /// Search routes based on source and destination
  static Future<List<Map<String, dynamic>>> searchRoutes(String from, String to) async {
    final token = await getToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/journey/search'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${token ?? ''}",
      },
      body: jsonEncode({"from": from, "to": to}),
    );

    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    }
    return [];
  }

  /// Get bus list
  static Future<List<Map<String, dynamic>>> getBuses(
    String source,
    String destination,
    String date,
  ) async {
    final token = await getToken();
    final uri = Uri.parse(
      '$baseUrl/api/buses/search?source=$source&destination=$destination&date=$date',
    );

    final res = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer ${token ?? ''}",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      final body = json.decode(res.body);
      return List<Map<String, dynamic>>.from(body['buses'] ?? []);
    } else {
      throw Exception('Failed to load bus list');
    }
  }

  /// Book a bus ticket
  static Future<bool> bookTicket(Map<String, dynamic> ticketData) async {
    final token = await getToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/tickets/book'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${token ?? ''}",
      },
      body: jsonEncode(ticketData),
    );
    return res.statusCode == 201;
  }

  /// View user's booked tickets
  static Future<List<Map<String, dynamic>>> getMyTickets() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/api/tickets/my'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${token ?? ''}",
      },
    );
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    }
    return [];
  }

  /// Get user's search history
  static Future<List<Map<String, dynamic>>> getSearchHistory() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/api/users/me'),
      headers: {
        "Authorization": "Bearer ${token ?? ''}",
      },
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(body['searchHistory'] ?? []);
    }
    return [];
  }

  /// Calculate fare based on `from` and `to` cities
  static Future<int> calculateFare(String from, String to) async {
    final token = await getToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/fare/calculate'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${token ?? ''}",
      },
      body: jsonEncode({"from": from, "to": to}),
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return body['fare'] ?? 0;
    } else {
      throw Exception('Failed to calculate fare');
    }
  }

  /// Logout by clearing saved token
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
  }
}
