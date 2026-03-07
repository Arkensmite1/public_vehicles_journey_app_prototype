import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BusResultsScreen extends StatefulWidget {
  static const routeName = '/results';

  final String from;
  final String to;
  final DateTime travelDate;

  const BusResultsScreen({
    super.key,
    required this.from,
    required this.to,
    required this.travelDate,
  });

  @override
  State<BusResultsScreen> createState() => _BusResultsScreenState();
}

class _BusResultsScreenState extends State<BusResultsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _buses = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.getBuses(
        widget.from,
        widget.to,
        widget.travelDate.toIso8601String().split('T').first,
      );
      setState(() => _buses = res);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = "${widget.travelDate.day}/${widget.travelDate.month}/${widget.travelDate.year}";
    return Scaffold(
      appBar: AppBar(title: Text("${widget.from} → ${widget.to} • $dateStr")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("Error: $_error"))
              : _buses.isEmpty
                  ? const Center(child: Text("No buses found"))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (_, i) {
                        final b = _buses[i];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.directions_bus)),
                            title: Text(b['name']?.toString() ?? 'Bus'),
                            subtitle: Text("Dep: ${b['departureTime'] ?? '--'}  •  Dur: ${b['duration'] ?? '--'}"),
                            trailing: Text("₹${b['fare'] ?? '--'}",
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: _buses.length,
                    ),
    );
  }
}
