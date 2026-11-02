import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';
import 'premium_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String token;

  const ProfileScreen({super.key, required this.token});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String? _goal;
  String? _trainingMode;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _message;

  final Map<String, String> _goalLabels = {
    "lose_weight": "Perte de poids",
    "gain_weight": "Prise de poids",
    "maintain_weight": "Maintien du poids",
  };

  final Map<String, String> _trainingModeLabels = {
    "gym": "En salle",
    "home": "À la maison",
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await ApiService.getProfile(widget.token);
      _firstNameController.text = profile["first_name"] ?? "";
      _lastNameController.text = profile["last_name"] ?? "";
      _weightController.text = profile["current_weight_kg"]?.toString() ?? "";
      _heightController.text = profile["height_cm"]?.toString() ?? "";
      _goal = profile["goal"];
      _trainingMode = profile["training_mode"];
    } catch (e) {
      _message = "Impossible de charger le profil.";
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
      _message = null;
    });
    try {
      await ApiService.updateProfile(
        widget.token,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        currentWeightKg: double.tryParse(_weightController.text),
        heightCm: double.tryParse(_heightController.text),
        goal: _goal,
        trainingMode: _trainingMode,
      );
      setState(() => _message = "Profil mis à jour !");
    } catch (e) {
      setState(() => _message = "Erreur lors de la mise à jour.");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon compte"),
        backgroundColor: AppTheme.background,
        elevation: 0,
        foregroundColor: AppTheme.textDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium_outlined),
            tooltip: "Premium",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PremiumScreen(token: widget.token),
                ),
              );
            },
          ),
        ],
      ),
            body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SummaryRow(label: "Nom", value: _lastNameController.text.isEmpty ? "—" : _lastNameController.text),
                        _SummaryRow(label: "Prénom", value: _firstNameController.text.isEmpty ? "—" : _firstNameController.text),
                        _SummaryRow(label: "Poids", value: _weightController.text.isEmpty ? "—" : "${_weightController.text} kg"),
                        _SummaryRow(label: "Taille", value: _heightController.text.isEmpty ? "—" : "${_heightController.text} cm"),
                        _SummaryRow(label: "Objectif", value: _goal == null ? "—" : (_goalLabels[_goal] ?? "—")),
                        _SummaryRow(label: "Mode", value: _trainingMode == null ? "—" : (_trainingModeLabels[_trainingMode] ?? "—")),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Modifier mes informations",
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(hintText: "Prénom"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(hintText: "Nom"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _weightController,
                    decoration: const InputDecoration(hintText: "Poids actuel (kg)"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _heightController,
                    decoration: const InputDecoration(hintText: "Taille (cm)"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  const Text("Objectif", style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ..._goalLabels.entries.map(
                    (entry) => RadioListTile<String>(
                      value: entry.key,
                      groupValue: _goal,
                      title: Text(entry.value),
                      activeColor: AppTheme.primary,
                      onChanged: (value) => setState(() => _goal = value),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text("Mode d'entraînement", style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ..._trainingModeLabels.entries.map(
                    (entry) => RadioListTile<String>(
                      value: entry.key,
                      groupValue: _trainingMode,
                      title: Text(entry.value),
                      activeColor: AppTheme.primary,
                      onChanged: (value) => setState(() => _trainingMode = value),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _message!,
                        style: const TextStyle(color: AppTheme.textDark),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("Enregistrer"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
