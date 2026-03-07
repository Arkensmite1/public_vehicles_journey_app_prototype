// ignore_for_file: prefer_const_declarations

import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/fare_calculator_screen.dart';
import 'screens/ticket_list_screen.dart';
import 'screens/history_screen.dart';
import 'screens/nearest_bus_screen.dart';
import 'screens/bus_results_screen.dart';

void main() {
  runApp(const BusApp());
}

class BusApp extends StatelessWidget {
  const BusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF6EC1FF); // light blue accent

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Where is My Bus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFFBFE6FF),
          foregroundColor: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF3F7FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E6EC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E6EC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: seed, width: 1.5),
          ),
          labelStyle: const TextStyle(color: Colors.black54),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/fare': (_) => const FareCalculatorScreen(),
        '/tickets': (_) => const TicketListScreen(),
        '/history': (_) => const HistoryScreen(),
        '/nearest': (_) => const NearestBusScreen(),
      },
      // For BusResultsScreen which needs arguments
      onGenerateRoute: (settings) {
        if (settings.name == BusResultsScreen.routeName) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => BusResultsScreen(
              from: args['from'],
              to: args['to'],
              travelDate: args['travelDate'],
            ),
          );
        }
        return null;
      },
    );
  }
}
