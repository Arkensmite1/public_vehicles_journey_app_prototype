import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class NearestBusScreen extends StatefulWidget {
  const NearestBusScreen({super.key});

  @override
  State<NearestBusScreen> createState() => _NearestBusScreenState();
}

class _NearestBusScreenState extends State<NearestBusScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _nearest;
  double? _distanceM;

  @override
  void initState() {
    super.initState();
    _loadNearest();
  }

  Future<void> _loadNearest() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() => _error = "Location services are disabled.");
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          setState(() => _error = "Location permission denied.");
          return;
        }
      }
      if (perm == LocationPermission.deniedForever) {
        setState(() => _error = "Location permission permanently denied.");
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      final jsonStr = await rootBundle.loadString('assets/bus_stands.json');
      final List<dynamic> stands = json.decode(jsonStr);

      double minDist = double.infinity;
      Map<String, dynamic>? nearest;
      for (final s in stands) {
        final dist = Geolocator.distanceBetween(
          pos.latitude, pos.longitude,
          (s['latitude'] as num).toDouble(),
          (s['longitude'] as num).toDouble(),
        );
        if (dist < minDist) {
          minDist = dist;
          nearest = Map<String, dynamic>.from(s);
        }
      }

      setState(() {
        _nearest = nearest;
        _distanceM = minDist.isFinite ? minDist : null;
      });
    } catch (e) {
      setState(() => _error = "Failed to resolve nearest stand: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nearest = _nearest;

    return Scaffold(
      appBar: AppBar(title: const Text("Nearest Bus Stand")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _errorCard(_error!)
                : nearest == null
                    ? _errorCard("No bus stands found in asset.")
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _heroCard(
                            title: nearest['name']?.toString() ?? 'Unknown',
                            subtitle: nearest['city']?.toString() ?? '',
                            distanceText: _distanceM == null
                                ? ''
                                : "${_distanceM!.toStringAsFixed(0)} m away",
                          ),
                          const SizedBox(height: 16),
                          const Text("Nearby Alternatives", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Expanded(
                            child: FutureBuilder<List<dynamic>>(
                              future: _loadAll(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                final list = snapshot.data!;
                                return ListView.separated(
                                  itemCount: list.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                                  itemBuilder: (_, i) {
                                    final s = list[i] as Map<String, dynamic>;
                                    return Card(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      child: ListTile(
                                        leading: const Icon(Icons.directions_bus),
                                        title: Text(s['name'].toString()),
                                        subtitle: Text(s['city'].toString()),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadNearest,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Future<List<dynamic>> _loadAll() async {
    final jsonStr = await rootBundle.loadString('assets/bus_stands.json');
    return json.decode(jsonStr) as List<dynamic>;
  }

  Widget _heroCard({required String title, required String subtitle, required String distanceText}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFD7EEFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 26, child: Icon(Icons.location_on_rounded, size: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
            ]),
          ),
          if (distanceText.isNotEmpty)
            Text(distanceText, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _errorCard(String msg) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE5E5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Flexible(child: Text(msg)),
          ],
        ),
      ),
    );
  }
}
