import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    final h = await ApiService.getSearchHistory(); // ✅ Fixed method name
    setState(() {
      _history = h;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search History")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(child: Text("No search history yet"))
              : ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (_, i) {
                    final entry = _history[i];
                    return ListTile(
                      leading: const Icon(Icons.history),
                      title: Text("${entry['from']} → ${entry['to']}"),
                      subtitle: Text("Searched on: ${entry['timestamp']}"),
                    );
                  },
                ),
    );
  }
}
