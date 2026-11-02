import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';

class FitnessScreen extends StatefulWidget {
  final String token;

  const FitnessScreen({super.key, required this.token});

  @override
  State<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> {
  Map<String, dynamic>? _program;
  bool _isLoading = true;
  int _selectedWeek = 1;
  final Set<int> _completedToday = {};

  final List<String> _dayNames = [
    "", "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"
  ];

  String get _today {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    _loadProgram();
  }

  Future<void> _loadProgram() async {
    setState(() => _isLoading = true);
    try {
      final program = await ApiService.getActiveProgram(widget.token);
      setState(() => _program = program);
    } catch (e) {
      setState(() => _program = null);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateProgram() async {
    setState(() => _isLoading = true);
    try {
      final program = await ApiService.generateProgram(widget.token);
      setState(() {
        _program = program;
        _selectedWeek = 1;
        _completedToday.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleExercise(int exerciseId) async {
    if (_completedToday.contains(exerciseId)) return;
    try {
      await ApiService.completeExercise(widget.token, exerciseId, _today);
      setState(() => _completedToday.add(exerciseId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bravo, +5 points !"), duration: Duration(seconds: 1)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon programme"),
        backgroundColor: AppTheme.background,
        elevation: 0,
        foregroundColor: AppTheme.textDark,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _program == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Aucun programme actif pour l'instant.",
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _generateProgram,
                          child: const Text("Générer mon programme"),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "Résultats visibles dans environ ${_program!["estimated_weeks_to_results"]} semaines si tu es régulière.",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _program!["total_weeks"],
                        itemBuilder: (context, index) {
                          final week = index + 1;
                          final isSelected = week == _selectedWeek;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text("Semaine $week"),
                              selected: isSelected,
                              selectedColor: AppTheme.primary,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.textDark,
                              ),
                              onSelected: (_) => setState(() => _selectedWeek = week),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: List.generate(7, (i) {
                          final day = i + 1;
                          final exercises = (_program!["exercises"] as List)
                              .where((e) =>
                                  e["day_of_week"] == day &&
                                  e["week_number"] == _selectedWeek)
                              .toList();
                          if (exercises.isEmpty) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.cardBorder, width: 0.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _dayNames[day],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ...exercises.map((e) {
                                    final isDone = _completedToday.contains(e["id"]);
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              e["name"],
                                              style: TextStyle(
                                                color: isDone
                                                    ? AppTheme.success
                                                    : AppTheme.textMuted,
                                                decoration: isDone
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isDone
                                                  ? Icons.check_circle
                                                  : Icons.radio_button_unchecked,
                                              color: isDone
                                                  ? AppTheme.success
                                                  : AppTheme.navInactive,
                                            ),
                                            onPressed: () => _toggleExercise(e["id"]),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
    );
  }
}
