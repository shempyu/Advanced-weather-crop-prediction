import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _weatherUrl = "http://127.0.0.1:10000/predict-weather";
  static const String _basicCropUrl = "http://127.0.0.1:10000/recommend-basic-crop";
  static const String _advancedCropUrl = "http://127.0.0.1:10000/recommend-advanced-crop";
  static const String _cropNewsUrl = "http://10.53.3.78:5000/crop-news";

  // Weather Prediction
  static Future<Map<String, dynamic>?> fetchWeather({
    required String district,
    required int year,
    required String month,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_weatherUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "district": district,
          "year": year,
          "month": month,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return body;
      } else {
        debugPrint("Forecast API Error ${response.statusCode}: ${body['error']}");
        return {"error": body['error'] ?? "Forecast Error"};
      }
    } catch (e) {
      debugPrint("Forecast Connection Error: $e");
      return null;
    }
  }

  // Crop Recommendation
  static Future<List<dynamic>?> recommendCrop({
    required bool isAdvanced,
    required Map<String, dynamic> data,
  }) async {
    try {
      final endpoint = isAdvanced ? _advancedCropUrl : _basicCropUrl;
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result['recommended_crops'] ?? [];
      } else {
        debugPrint("Crop Recommendation API Error ${response.statusCode}: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Crop Recommendation Connection Error: $e");
      return null;
    }
  }

  // Fetch Crop News
  static Future<Map<String, dynamic>?> fetchCropNews(String crop) async {
    try {
      debugPrint("Fetching news for crop: $crop");
      final response = await http.post(
        Uri.parse(_cropNewsUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"crop": crop}),
      );
      
      debugPrint("News API Status Code: ${response.statusCode}");
      debugPrint("News API Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("News API Error: $e");
      return null;
    }
  }
}
