import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const NBAAIApp());
}

class NBAAIApp extends StatelessWidget {
  const NBAAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "NBA AI Predictor",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        primaryColor: const Color(0xFF38BDF8),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String backendUrl = "https://nba-ai-backend.onrender.com";

  bool isLoading = false;
  Map<String, dynamic>? currentPrediction;

  Future<void> fetchPrediction(String home, String visitor) async {
    setState(() {
      isLoading = true;
      currentPrediction = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$backendUrl/api/v1/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'home_team': home,
          'visitor_team': visitor,
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        setState(() {
          currentPrediction = jsonDecode(response.body);
        });
      } else {
        _showError('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _showError('Excepción: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏀 NBA AI Predictor 2026'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Partidos Destacados de Hoy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: isLoading ? null : () => fetchPrediction('Celtics', 'Knicks'),
                  child: const Text('Celtics vs Knicks', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: isLoading ? null : () => fetchPrediction('Magic', 'Wolves'),
                  child: const Text('Magic vs Wolves', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text(
                      'Conectando con la IA...',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              )
            else if (currentPrediction != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resultado del Análisis:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      jsonEncode(currentPrediction),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
