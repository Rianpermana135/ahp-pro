
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AhpProvider with ChangeNotifier {
  // Data Master
  List<String> criteria = ["Biaya", "Kualitas", "Waktu"]; // Default
  List<String> alternatives = ["Mesin A", "Mesin B", "Mesin C"]; // Default
  
  // Penyimpanan Nilai Perbandingan (Pairwise)
  // Format Key: "Index1-Index2" (misal "0-1" artinya item ke-0 vs item ke-1)
  // Value: 1 sampai 9 (Jika user pilih kiri lebih penting) atau 1/9 (kanan)
  // Namun untuk slider kita simpan nilai raw (misal -9 s.d 9) lalu dikonversi.
  // Kita simpan nilai 1-9 Saaty. User input: A vs B. 
  // Jika A lebih penting nilai > 1. Jika B lebih penting nilai < 1 (pecahan).
  
  Map<String, double> criteriaComparisons = {};
  Map<String, Map<String, double>> alternativeComparisons = {};
  
  // Hasil
  Map<String, dynamic>? result;
  bool isLoading = false;
  String? errorMessage;

  // Konfigurasi API
  String? apiBaseUrl;

  // --- Setter & Management ---

  void addCriterion(String name) {
    if (!criteria.contains(name)) {
      criteria.add(name);
      criteriaComparisons.clear(); // Reset perbandingan jika struktur berubah
      notifyListeners();
    }
  }

  void removeCriterion(String name) {
    criteria.remove(name);
    criteriaComparisons.clear();
    alternativeComparisons.remove(name);
    notifyListeners();
  }

  void addAlternative(String name) {
    if (!alternatives.contains(name)) {
      alternatives.add(name);
      _resetAltComparisons();
      notifyListeners();
    }
  }

  void removeAlternative(String name) {
    alternatives.remove(name);
    _resetAltComparisons();
    notifyListeners();
  }

  void _resetAltComparisons() {
    alternativeComparisons.clear();
    for (var c in criteria) {
      alternativeComparisons[c] = {};
    }
  }
  
  void updateCriteriaComparison(int idx1, int idx2, double value) {
    // Value: 1/9 ... 1 ... 9
    criteriaComparisons["$idx1-$idx2"] = value;
    notifyListeners();
  }

  void updateAlternativeComparison(String critName, int idx1, int idx2, double value) {
    if (!alternativeComparisons.containsKey(critName)) {
        alternativeComparisons[critName] = {};
    }
    alternativeComparisons[critName]!["$idx1-$idx2"] = value;
    notifyListeners();
  }

  // --- Helper Build Matrix ---
  
  List<List<double>> _buildMatrix(int size, Map<String, double> comparisons) {
    List<List<double>> matrix = List.generate(size, (i) => List.filled(size, 1.0));
    
    for (int i = 0; i < size; i++) {
        for (int j = i + 1; j < size; j++) {
            String key = "$i-$j";
            double val = comparisons[key] ?? 1.0;
            matrix[i][j] = val;
            matrix[j][i] = 1.0 / val;
        }
    }
    return matrix;
  }

  // --- API Integration ---

  Future<void> fetchConfig() async {
    // TODO: Ganti dengan URL RAW Gist yang sebenarnya nanti
    // Untuk development lokal, kita anggap sudah set atau fetch dari hardcoded
    const gistUrl = "https://gist.githubusercontent.com/User/ID/raw/config.json"; 
    
    // Mocking for dev if needed or try fetch
    // Karena kita dev local, kita pakai localhost via ngrok user nanti.
    // Sementara kita hardcode ke localhost emulator android (10.0.2.2) atau actual IP
    // apiBaseUrl = "http://10.0.2.2:5000"; 
  }
  
  void setBaseUrl(String url) {
      apiBaseUrl = url;
      notifyListeners();
  }

  Future<bool> calculate() async {
    if (apiBaseUrl == null) {
        errorMessage = "API URL belum diset";
        return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // 1. Build Payload
      var goalMatrix = _buildMatrix(criteria.length, criteriaComparisons);
      var altMatrices = {};
      
      for (var c in criteria) {
          altMatrices[c] = _buildMatrix(alternatives.length, alternativeComparisons[c] ?? {});
      }
      
      var payload = {
          "criteria": criteria,
          "alternatives": alternatives,
          "goal_matrix": goalMatrix,
          "alternative_matrices": altMatrices
      };

      // 2. HTTP Request
      var response = await http.post(
          Uri.parse("$apiBaseUrl/calculate"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(payload)
      );

      if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          if (data['status'] == 'success') {
              result = data['data'];
              isLoading = false;
              notifyListeners();
              return true;
          } else {
              errorMessage = data['message'] ?? "Unknown Error";
          }
      } else {
          errorMessage = "Server Error: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
        errorMessage = "Connection Error: $e";
    }
    
    isLoading = false;
    notifyListeners();
    return false;
  }
}
