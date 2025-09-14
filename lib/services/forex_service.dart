// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ForexService {
  static const String _apiBase = "https://api.fxratesapi.com/latest";
  static const String _cacheKey = "forex_rates_cache";
  static const String _timestampKey = "forex_rates_time";

  static const Duration _cacheDuration = Duration(hours: 2);

  /// Get conversion rate FROM → TO
  static Future<double?> getRate(String from, String to) async {
    if (from == to) return 1.0;

    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);
    final cachedTime = prefs.getInt(_timestampKey);
    final now = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> rates = {};
    double? staleRate;

    // 🔹 Load from cache
    if (cachedData != null && cachedTime != null) {
      try {
        rates = json.decode(cachedData);

        if (rates.containsKey(from) && rates.containsKey(to)) {
          final rateFrom = (rates[from] as num).toDouble();
          final rateTo = (rates[to] as num).toDouble();

          // rate formula: target / base
          final rate = rateTo / rateFrom;

          if (now - cachedTime < _cacheDuration.inMilliseconds) {
            print("✅ Using cached rate for $from → $to");
            return rate;
          } else {
            print("⌛ Cache expired, will fetch new data.");
            staleRate = rate; // fallback
          }
        }
      } catch (e) {
        print("⚠️ Failed to parse cache: $e");
        await prefs.remove(_cacheKey);
        await prefs.remove(_timestampKey);
      }
    }

    // 🌍 Fetch from API
    try {
      print("🌍 Fetching fresh rates with base=$from");
      final url = Uri.parse("$_apiBase?base=$from");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["rates"] != null) {
          rates = Map<String, dynamic>.from(data["rates"]);

          // Save full rates map (not nested)
          await prefs.setString(_cacheKey, json.encode(rates));
          await prefs.setInt(_timestampKey, now);

          print("💾 Saved new rates: ${rates.keys.length} currencies");

          if (rates.containsKey(from) && rates.containsKey(to)) {
            final rateFrom = (rates[from] as num).toDouble();
            final rateTo = (rates[to] as num).toDouble();
            return rateTo / rateFrom;
          }
        }
      } else {
        print("⚠️ API request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ API failed: $e");
    }

    // ♻️ Fallback
    if (staleRate != null) {
      print("♻️ Returning stale cached rate for $from → $to");
      return staleRate;
    }

    print("❌ No rate available for $from → $to");
    return null;
  }

  /// List all currencies stored in cache
  static Future<List<String>> getCachedCurrencies() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);

    if (cachedData == null) return [];

    try {
      final Map<String, dynamic> rates = json.decode(cachedData);
      return rates.keys.toList()..sort();
    } catch (e) {
      print("⚠️ Failed to parse cached currencies: $e");
      return [];
    }
  }
}
