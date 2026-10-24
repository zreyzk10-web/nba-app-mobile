import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const NBAAIApp());
}

class NBAAIApp extends StatelessWidget {
  const NBAAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NBA AI Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        primaryColor: const Color(0xFF3B82F6),
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
  // ⚠️ AQUÍ DEBES PEGAR TU ENLACE REAL DE RENDER ENTRE LAS COMILLAS
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
        Uri.parse('$backendUrl/api/v1/predict')
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'home_team': home,
          'visitor_team': visitor,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          currentPrediction = jsonDecode(response.body);
        });
      } else {
        _showError('Error al obtener el pronóstico');
      }
    } catch (e) {
      _showError('Error de conexión con el servidor');
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
              "Partidos Destacados de Hoy",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                    onPressed: () => fetchPrediction("Boston Celtics", "New York Knicks"),
                    child: const Text("Celtics vs Knicks"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669)),
                    onPressed: () => fetchPrediction("Orlando Magic", "Minnesota Timberwolves"),
                    child: const Text("Magic vs Wolves"),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),

            if (currentPrediction != null) ...[
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        currentPrediction!['matchup'] ?? '',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "🏆 Ganador: ${currentPrediction!['predicted_winner']}",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                        textAlign: TextAlign.center,
                      ),
                      Text("Margen: ${currentPrediction!['predicted_margin']}"),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn("Total Puntos", "${currentPrediction!['estimated_total_points']}"),
                          _buildStatColumn("Línea", "${currentPrediction!['over_under_recommendation']}"),
                          _buildStatColumn("Confianza", "⭐ ${currentPrediction!['confidence_score']}/10"),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              const Text(
                "🔥 Player Props Recomendados",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              ...?((currentPrediction!['player_props'] as List?)?.map((prop) => Card(
                color: const Color(0xFF334155),
                child: ListTile(
                  title: Text(prop['player_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(prop['justification']),
                  trailing: Chip(
                    label: Text(prop['market']),
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
              ))),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
