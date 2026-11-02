import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';
import 'wellness_screen.dart';

class ProgressScreen extends StatefulWidget {
  final String token;

  const ProgressScreen({super.key, required this.token});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _totalPoints = 0;
  List<dynamic> _weightLogs = [];
  bool _isLoading = true;
  final _weightController = TextEditingController();

  final List<String> _suggestions = [
    "Bois 8 verres d'eau aujourd'hui → +10 points",
    "Complète un exercice de ton programme → +5 points",
    "Respecte ton habitude 3 jours de suite → bonus streak",
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final points = await ApiService.getPoints(widget.token);
      final logs = await ApiService.getWeightLogs(widget.token);
      setState(() {
        _totalPoints = points["total_points"] ?? 0;
        _weightLogs = logs;
      });
    } catch (e) {
      // silencieux
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addWeight() async {
    final weight = double.tryParse(_weightController.text);
    if (weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entre un poids valide")),
      );
      return;
    }

    final now = DateTime.now();
    final today = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    try {
      await ApiService.addWeightLog(widget.token, today, weight);
      _weightController.clear();
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'enregistrer le poids")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes efforts"),
        backgroundColor: AppTheme.background,
        elevation: 0,
        foregroundColor: AppTheme.textDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.spa_outlined),
            tooltip: "Bien-être",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WellnessScreen(token: widget.token),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 32),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$_totalPoints",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              "Points gagnés",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Suggestions pour gagner des points",
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 10),
                  ..._suggestions.map((s) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.cardBorder, width: 0.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lightbulb_outline, color: AppTheme.secondary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(s, style: const TextStyle(color: AppTheme.textDark, fontSize: 13)),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),
                  const Text(
                    "Mon évolution de poids",
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _weightController,
                          decoration: const InputDecoration(hintText: "Poids aujourd'hui", suffixText: "kg"),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _addWeight,
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_weightLogs.isEmpty)
                    const Text(
                      "Aucune pesée enregistrée pour l'instant.",
                      style: TextStyle(color: AppTheme.textMuted),
                    )
                  else
                    ..._weightLogs.reversed.map((log) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.cardBorder, width: 0.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(log["log_date"], style: const TextStyle(color: AppTheme.textMuted)),
                              Text(
                                "${log["weight_kg"]} kg",
                                style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark),
                              ),
                            ],
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}
