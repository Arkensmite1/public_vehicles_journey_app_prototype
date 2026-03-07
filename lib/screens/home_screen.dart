// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'bus_results_screen.dart';
import 'fare_calculator_screen.dart';
import 'ticket_list_screen.dart';
import 'history_screen.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _from;
  String? _to;
  DateTime? _travelDate;

  final _locations = ['Delhi', 'Agra', 'Lucknow', 'Kanpur', 'Varanasi'];

  void _logout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _travelDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _travelDate = picked);
    }
  }

  void _findBuses() {
    if (_from != null && _to != null && _from != _to && _travelDate != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BusResultsScreen(
            from: _from!,
            to: _to!,
            travelDate: _travelDate!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select valid route and travel date")),
      );
    }
  }

  Future<void> _findNearestBusStand() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location services are disabled.")),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission denied.")),
          );
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final jsonStr = await rootBundle.loadString('assets/bus_stands.json');
      final List<dynamic> stands = json.decode(jsonStr);

      double minDistance = double.infinity;
      Map<String, dynamic>? nearestStand;

      for (var stand in stands) {
        double dist = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          stand['latitude'],
          stand['longitude'],
        );

        if (dist < minDistance) {
          minDistance = dist;
          nearestStand = stand;
        }
      }

      if (nearestStand != null) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Nearest Bus Stand"),
            content: Text(
              "${nearestStand!['name'] ?? 'Unknown'}\n"
              "(${nearestStand['city'] ?? 'Unknown'})\n"
              "Distance: ${minDistance.toStringAsFixed(2)} meters",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error finding location: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text("Where is My Bus?"),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            const Text(
              "Plan Your Journey",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.lightBlue[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Depart From"),
                    items: _locations
                        .map((city) =>
                            DropdownMenuItem(value: city, child: Text(city)))
                        .toList(),
                    value: _from,
                    onChanged: (value) => setState(() => _from = value),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Destination"),
                    items: _locations
                        .map((city) =>
                            DropdownMenuItem(value: city, child: Text(city)))
                        .toList(),
                    value: _to,
                    onChanged: (value) => setState(() => _to = value),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Select Travel Date"),
                    subtitle: Text(
                      _travelDate != null
                          ? "${_travelDate!.day}/${_travelDate!.month}/${_travelDate!.year}"
                          : "No date selected",
                    ),
                    trailing: ElevatedButton(
                      onPressed: _pickDate,
                      child: const Text("Pick Date"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _findBuses,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("Find Buses", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              "Quick Access",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildTile("Fare Calculator", Icons.calculate, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const FareCalculatorScreen()));
                }),
                _buildTile("My Tickets", Icons.confirmation_num, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const TicketListScreen()));
                }),
                _buildTile("Search History", Icons.history, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HistoryScreen()));
                }),
                _buildTile("Nearest Bus Stand", Icons.location_on, _findNearestBusStand),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildTile(String title, IconData icon, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.lightBlue[100],
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.black87),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
