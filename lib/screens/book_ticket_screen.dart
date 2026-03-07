import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BookTicketScreen extends StatefulWidget {
  final dynamic bus;

  const BookTicketScreen({super.key, required this.bus});

  @override
  State<BookTicketScreen> createState() => _BookTicketScreenState();
}

class _BookTicketScreenState extends State<BookTicketScreen> {
  bool _loading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _book() async {
    setState(() => _loading = true);
    final success = await ApiService.bookTicket(widget.bus['_id']);
    setState(() => _loading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ticket booked!")),
      );
      Navigator.pop(context);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.bus;
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
            Text(b['busName'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("From: ${b['from']}"),
            Text("To: ${b['to']}"),
            Text("Duration: ${b['duration']}"),
            Text("Fare: ₹${b['fare']}"),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _book,
                    child: const Text("Confirm Booking"),
                  ),
          ],
        ),
      ),
    ),
  ),
    ));
  }
}
