import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:8000";

  static Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["access_token"];
    } else {
      throw Exception("Email ou mot de passe incorrect");
    }
  }

  static Future<void> register(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data["detail"] ?? "Erreur lors de l'inscription");
    }
  }

  static Future<List<dynamic>> getHabitsWithStatus(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/habits/with-status"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Impossible de récupérer les habitudes");
    }
  }

  static Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/profile/"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Impossible de récupérer le profil");
  }

  static Future<Map<String, dynamic>> updateProfile(
    String token, {
    String? firstName,
    String? lastName,
    double? currentWeightKg,
    double? heightCm,
    String? goal,
    String? trainingMode,
  }) async {
    final body = <String, dynamic>{};
    if (firstName != null) body["first_name"] = firstName;
    if (lastName != null) body["last_name"] = lastName;
    if (currentWeightKg != null) body["current_weight_kg"] = currentWeightKg;
    if (heightCm != null) body["height_cm"] = heightCm;
    if (goal != null) body["goal"] = goal;
    if (trainingMode != null) body["training_mode"] = trainingMode;

    final response = await http.put(
      Uri.parse("$baseUrl/profile/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Impossible de mettre à jour le profil");
  }

  static Future<Map<String, dynamic>> getPoints(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/wellness/points"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Impossible de récupérer les points");
  }
    static Future<Map<String, dynamic>> getActiveProgram(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/fitness/active"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Aucun programme actif");
  }

  static Future<Map<String, dynamic>> generateProgram(String token) async {
    final response = await http.post(
      Uri.parse("$baseUrl/fitness/generate"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    final data = jsonDecode(response.body);
    throw Exception(data["detail"] ?? "Impossible de générer le programme");
  }
    static Future<void> completeExercise(String token, int exerciseId, String logDate) async {
    final response = await http.post(
      Uri.parse("$baseUrl/fitness/exercises/$exerciseId/complete"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"log_date": logDate}),
    );
    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data["detail"] ?? "Impossible de valider l'exercice");
    }
  }
    static Future<List<dynamic>> getWeightLogs(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/weight/"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Impossible de récupérer l'historique de poids");
  }

  static Future<void> addWeightLog(String token, String logDate, double weightKg) async {
    final response = await http.post(
      Uri.parse("$baseUrl/weight/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"log_date": logDate, "weight_kg": weightKg}),
    );
    if (response.statusCode != 201) {
      throw Exception("Impossible d'enregistrer le poids");
    }
  }
    static Future<List<dynamic>> getWellnessHabits(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/wellness/habits"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Impossible de récupérer les habitudes bien-être");
  }

  static Future<void> createWellnessHabit(String token, String category, int targetValue) async {
    final response = await http.post(
      Uri.parse("$baseUrl/wellness/habits"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"category": category, "target_value": targetValue}),
    );
    if (response.statusCode != 201) {
      throw Exception("Impossible de créer l'habitude bien-être");
    }
  }

  static Future<void> logWellnessHabit(String token, int habitId, String logDate, int value) async {
    final response = await http.post(
      Uri.parse("$baseUrl/wellness/habits/$habitId/logs"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"log_date": logDate, "value": value}),
    );
    if (response.statusCode != 201) {
      throw Exception("Impossible d'enregistrer");
    }
  }
    static Future<bool> getPremiumStatus(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/premium/status"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)["is_active"] ?? false;
    }
    return false;
  }

  static Future<void> activatePremium(String token) async {
    final response = await http.post(
      Uri.parse("$baseUrl/premium/activate"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode != 200) {
      throw Exception("Impossible d'activer le premium");
    }
  }

  static Future<void> updateLocation(String token, String city, String neighborhood) async {
    final response = await http.put(
      Uri.parse("$baseUrl/premium/location"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"city": city, "neighborhood": neighborhood}),
    );
    if (response.statusCode != 200) {
      throw Exception("Impossible de mettre à jour la localisation");
    }
  }

  static Future<void> updateFinances(String token, double monthlyBudget) async {
    final response = await http.put(
      Uri.parse("$baseUrl/premium/finances"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"monthly_budget": monthlyBudget, "currency": "XAF"}),
    );
    if (response.statusCode != 200) {
      throw Exception("Impossible de mettre à jour le budget");
    }
  }

  static Future<List<dynamic>> getAllergies(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/premium/allergies"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  static Future<void> addAllergy(String token, String allergyName) async {
    final response = await http.post(
      Uri.parse("$baseUrl/premium/allergies"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"allergy_name": allergyName}),
    );
    if (response.statusCode != 201) {
      throw Exception("Impossible d'ajouter l'allergie");
    }
  }

  static Future<Map<String, dynamic>> generateMealPlan(String token, String periodType, String startDate) async {
    final response = await http.post(
      Uri.parse("$baseUrl/meal-plan/generate"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"period_type": periodType, "start_date": startDate}),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    final data = jsonDecode(response.body);
    throw Exception(data["detail"] ?? "Impossible de générer le planning");
  }

  static Future<Map<String, dynamic>> getLatestMealPlan(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/meal-plan/latest"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Aucun planning disponible");
  }
}
