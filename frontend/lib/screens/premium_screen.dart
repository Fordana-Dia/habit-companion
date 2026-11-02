import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';

class PremiumScreen extends StatefulWidget {
  final String token;

  const PremiumScreen({super.key, required this.token});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isPremium = false;
  bool _isLoading = true;

  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _budgetController = TextEditingController();
  final _allergyController = TextEditingController();

  List<dynamic> _allergies = [];
  Map<String, dynamic>? _mealPlan;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);
    try {
      final isPremium = await ApiService.getPremiumStatus(widget.token);
      setState(() => _isPremium = isPremium);
      if (isPremium) {
        final allergies = await ApiService.getAllergies(widget.token);
        setState(() => _allergies = allergies);
        try {
          final plan = await ApiService.getLatestMealPlan(widget.token);
          setState(() => _mealPlan = plan);
        } catch (_) {
          _mealPlan = null;
        }
      }
    } catch (e) {
      // silencieux
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _activatePremium() async {
    try {
      await ApiService.activatePremium(widget.token);
      _loadStatus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l'activation")),
      );
    }
  }

  Future<void> _saveLocation() async {
    try {
      await ApiService.updateLocation(
        widget.token,
        _cityController.text.trim(),
        _neighborhoodController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Localisation enregistrée")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur")),
      );
    }
  }

  Future<void> _saveBudget() async {
    final budget = double.tryParse(_budgetController.text);
    if (budget == null) return;
    try {
      await ApiService.updateFinances(widget.token, budget);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Budget enregistré")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur")),
      );
    }
  }

  Future<void> _addAllergy() async {
    final allergy = _allergyController.text.trim();
    if (allergy.isEmpty) return;
    try {
      await ApiService.addAllergy(widget.token, allergy);
      _allergyController.clear();
      _loadStatus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur")),
      );
    }
  }

  Future<void> _generatePlan() async {
    final now = DateTime.now();
    final today = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    try {
      final plan = await ApiService.generateMealPlan(widget.token, "monthly", today);
      setState(() => _mealPlan = plan);
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
        title: const Text("Premium"),
        backgroundColor: AppTheme.background,
        elevation: 0,
        foregroundColor: AppTheme.textDark,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_isPremium
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.workspace_premium, size: 56, color: AppTheme.secondary),
                        const SizedBox(height: 16),
                        const Text(
                          "Débloque le planning alimentaire personnalisé selon ta ville et ton budget.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _activatePremium,
                          child: const Text("Activer Premium"),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text("Ma localisation", style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _cityController,
                      decoration: const InputDecoration(hintText: "Ville"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _neighborhoodController,
                      decoration: const InputDecoration(hintText: "Quartier"),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: _saveLocation, child: const Text("Enregistrer")),

                    const SizedBox(height: 24),
                    const Text("Mon budget mensuel", style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _budgetController,
                      decoration: const InputDecoration(hintText: "Budget", suffixText: "XAF"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: _saveBudget, child: const Text("Enregistrer")),

                    const SizedBox(height: 24),
                    const Text("Mes allergies", style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _allergyController,
                            decoration: const InputDecoration(hintText: "Ex: arachide"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(onPressed: _addAllergy, child: const Icon(Icons.add)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: _allergies
                          .map((a) => Chip(
                                label: Text(a["allergy_name"]),
                                backgroundColor: AppTheme.secondary,
                                labelStyle: const TextStyle(color: Colors.white),
                              ))
                          .toList(),
                    ),

                    const SizedBox(height: 24),
                    const Text("Mon planning alimentaire", style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _generatePlan,
                      child: const Text("Générer mon planning du mois"),
                    ),
                    const SizedBox(height: 14),
                    if (_mealPlan != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          "Coût total estimé : ${_mealPlan!["total_estimated_cost"]} XAF",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...((_mealPlan!["items"] as List).take(9).map((item) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.cardBorder, width: 0.5),
                            ),
                            child: Row(
                              children: [
                                Text(item["meal_time"], style: const TextStyle(color: AppTheme.textMuted)),
                                const SizedBox(width: 12),
                                Expanded(child: Text(item["meal_name"])),
                                Text("${item["estimated_cost"]} XAF"),
                              ],
                            ),
                          ))),
                    ],
                  ],
                ),
    );
  }
}
