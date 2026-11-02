import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';

class WellnessScreen extends StatefulWidget {
  final String token;

  const WellnessScreen({super.key, required this.token});

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  List<dynamic> _habits = [];
  bool _isLoading = true;
  final Set<int> _loggedToday = {};

  final Map<String, String> _categoryLabels = {
    "hydration": "Hydratation (verres d'eau)",
    "hygiene": "Hygiène (douches/jour)",
    "fruits": "Fruits (portions/jour)",
    "sleep": "Sommeil (heures)",
    "other": "Autre",
  };

  final Map<String, IconData> _categoryIcons = {
    "hydration": Icons.water_drop_outlined,
    "hygiene": Icons.shower_outlined,
    "fruits": Icons.apple,
    "sleep": Icons.bedtime_outlined,
    "other": Icons.check_circle_outline,
  };

  String get _today {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() => _isLoading = true);
    try {
      final habits = await ApiService.getWellnessHabits(widget.token);
      setState(() => _habits = habits);
    } catch (e) {
      // silencieux
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logHabit(int habitId, int targetValue) async {
    try {
      await ApiService.logWellnessHabit(widget.token, habitId, _today, targetValue);
      setState(() => _loggedToday.add(habitId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Objectif atteint, +10 points !"), duration: Duration(seconds: 1)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l'enregistrement")),
      );
    }
  }

  void _showAddHabitDialog() {
    String? selectedCategory;
    final targetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.background,
          title: const Text("Nouvelle habitude bien-être"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(hintText: "Catégorie"),
                items: _categoryLabels.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (value) => setDialogState(() => selectedCategory = value),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetController,
                decoration: const InputDecoration(hintText: "Objectif quotidien"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                final target = int.tryParse(targetController.text);
                if (selectedCategory == null || target == null) return;
                try {
                  await ApiService.createWellnessHabit(widget.token, selectedCategory!, target);
                  if (context.mounted) Navigator.of(context).pop();
                  _loadHabits();
                } catch (e) {
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
              child: const Text("Créer"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bien-être"),
        backgroundColor: AppTheme.background,
        elevation: 0,
        foregroundColor: AppTheme.textDark,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: _showAddHabitDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _habits.isEmpty
              ? const Center(
                  child: Text(
                    "Aucune habitude bien-être. Ajoute-en une avec le bouton +.",
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _habits.length,
                  itemBuilder: (context, index) {
                    final habit = _habits[index];
                    final isLogged = _loggedToday.contains(habit["id"]);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.cardBorder, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _categoryIcons[habit["category"]] ?? Icons.check_circle_outline,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _categoryLabels[habit["category"]] ?? habit["category"],
                              style: const TextStyle(color: AppTheme.textDark),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isLogged ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: isLogged ? AppTheme.success : AppTheme.navInactive,
                            ),
                            onPressed: isLogged
                                ? null
                                : () => _logHabit(habit["id"], habit["target_value"]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
