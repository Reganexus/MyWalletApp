// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ForexService {
  static const String _apiBase = "https://api.fxratesapi.com/latest";
  static const String _cacheKey = "forex_rates_cache";
  static const String _timestampKey = "forex_rates_timestamp";

  static const Duration _cacheDuration = Duration(hours: 12);

  static Future<double?> getRate(String from, String to) async {
    final prefs = await SharedPreferences.getInstance();

    final cachedData = prefs.getString(_cacheKey);
    final cachedTimestamp = prefs.getInt(_timestampKey);

    double? staleRate;

    if (cachedData != null && cachedTimestamp != null) {
      try {
        final decoded = json.decode(cachedData);
        if (decoded[from] != null && decoded[from][to] != null) {
          final rate = (decoded[from][to] as num).toDouble();

          final cacheAge = DateTime.now().difference(
            DateTime.fromMillisecondsSinceEpoch(cachedTimestamp),
          );

          if (cacheAge < _cacheDuration) {
            // ✅ Fresh cache
            return rate;
          } else {
            // ✅ Save stale cache for fallback
            staleRate = rate;
          }
        }
      } catch (_) {
        await prefs.remove(_cacheKey);
        await prefs.remove(_timestampKey);
      }
    }

    // ✅ Try API
    try {
      final url = Uri.parse("$_apiBase?base=$from&symbols=$to");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["rates"] != null && data["rates"][to] != null) {
          final rate = (data["rates"][to] as num).toDouble();

          // Update cache
          final Map<String, dynamic> newCache =
              cachedData != null ? json.decode(cachedData) : {};
          newCache[from] = {to: rate};

          await prefs.setString(_cacheKey, json.encode(newCache));
          await prefs.setInt(
            _timestampKey,
            DateTime.now().millisecondsSinceEpoch,
          );

          return rate;
        }
      }
    } catch (e) {
      print("❌ API failed, using stale cache if available: $e");
    }

    // ✅ Final fallback: return stale cache if available
    return staleRate;
  }
}
