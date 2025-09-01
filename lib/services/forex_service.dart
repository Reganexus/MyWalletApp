// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ForexService {
  static const String _apiBase = "https://api.fxratesapi.com/latest";
  static const String _cacheKey = "forex_rates_cache";
  static const String _timestampKey = "forex_rates_time";

  static const Duration _cacheDuration = Duration(hours: 2);

  static Future<double?> getRate(String from, String to) async {
    if (from == to) return 1.0; // trivial case

    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);
    final cachedTime = prefs.getInt(_timestampKey);
    final now = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> cache = {};
    double? staleRate;

    if (cachedData != null && cachedTime != null) {
      try {
        cache = json.decode(cachedData);

        if (cache[from] != null && cache[from][to] != null) {
          final rate = (cache[from][to] as num).toDouble();

          // ✅ Check if cache is still fresh (within 2h)
          if (now - cachedTime < _cacheDuration.inMilliseconds) {
            print("✅ Using cached rate for $from → $to");
            return rate;
          } else {
            print("⌛ Cache expired, will fetch new data.");
            staleRate = rate; // keep as fallback
          }
        }
      } catch (_) {
        await prefs.remove(_cacheKey);
        await prefs.remove(_timestampKey);
      }
    }

    // 🌍 Fetch new rates if cache expired or not available
    try {
      print("🌍 Fetching new rates for base: $from");
      final url = Uri.parse("$_apiBase?base=$from");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 🐞 Debug: print full response JSON
        final debugJson = const JsonEncoder.withIndent('  ').convert(data);
        print("📦 API Response:\n$debugJson");

        if (data["rates"] != null) {
          final rates = data["rates"] as Map<String, dynamic>;

          // Update cache
          cache[from] = rates;
          await prefs.setString(_cacheKey, json.encode(cache));
          await prefs.setInt(_timestampKey, now);

          if (rates[to] != null) {
            return (rates[to] as num).toDouble();
          }
        }
      } else {
        print("⚠️ API request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ API failed, using stale cache if available: $e");
    }

    // ✅ Fallback to stale cache if available
    return staleRate;
  }

  static Future<List<String>> getCachedCurrencies() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);

    if (cachedData == null) return [];

    try {
      final Map<String, dynamic> cache = json.decode(cachedData);

      // Get all keys from the cache (bases) and all target currencies
      final Set<String> currencies = {};

      for (final base in cache.keys) {
        currencies.add(base); // base currency
        final rates = cache[base] as Map<String, dynamic>;
        currencies.addAll(rates.keys); // target currencies
      }

      return currencies.toList()..sort();
    } catch (_) {
      return [];
    }
  }
}
