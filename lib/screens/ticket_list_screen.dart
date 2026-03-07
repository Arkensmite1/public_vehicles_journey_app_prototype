import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  List<Map<String, dynamic>> _tickets = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    try {
      final t = await ApiService.getMyTickets();
      setState(() => _tickets = t);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Tickets")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("Error: $_error"))
              : _tickets.isEmpty
                  ? const Center(child: Text("No bookings yet"))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _tickets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final t = _tickets[i];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            leading: const Icon(Icons.directions_bus),
                            title: Text(t['busName']?.toString() ?? 'Bus'),
                            subtitle: Text("From ${t['from']} to ${t['to']}"),
                            trailing: Text("₹${t['fare'] ?? '--'}",
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
    );
  }
}
