// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FareCalculatorScreen extends StatefulWidget {
  const FareCalculatorScreen({super.key});

  @override
  State<FareCalculatorScreen> createState() => _FareCalculatorScreenState();
}

class _FareCalculatorScreenState extends State<FareCalculatorScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _locations = const ['Delhi', 'Agra', 'Lucknow', 'Kanpur', 'Varanasi'];
  String? _from;
  String? _to;
  int? _fare;
  bool _loading = false;

  Future<void> _calculate() async {
    if (_from == null || _to == null || _from == _to) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select valid locations")),
      );
      return;
    }
    try {
      setState(() {
        _loading = true;
        _fare = null;
      });
      final result = await ApiService.calculateFare(_from!, _to!);
      setState(() => _fare = result);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to calculate fare: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  body: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF2193b0), // teal-blue
          Color(0xFF6dd5ed), // light aqua-blue
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            _panel(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "From"),
                    items: _locations.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _from = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "To"),
                    items: _locations.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _to = v),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _calculate,
                      icon: const Icon(Icons.calculate),
                      label: const Text("Calculate Fare"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(),
            if (_fare != null) _fareCard(_fare!),
          ],
        ),
      ),
    ))));
  }

  Widget _panel({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F4FF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: child,
      );

  Widget _fareCard(int fare) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFD7EEFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long, size: 34),
          const SizedBox(width: 12),
          const Text("Estimated Fare", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text("₹$fare", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
