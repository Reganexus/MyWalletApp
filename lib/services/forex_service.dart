// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ForexService {
  static const String _apiBase = "https://api.fxratesapi.com/latest";
  static const String _cacheKey = "forex_rates_cache";
  static const String _timestampKey = "forex_rates_slot";

  /// Returns the start of the current 12h slot in UTC.
  static DateTime _getCurrentSlot() {
    final now = DateTime.now().toUtc();
    final slotHour = (now.hour < 12) ? 0 : 12;
    return DateTime.utc(now.year, now.month, now.day, slotHour);
  }

  static Future<double?> getRate(String from, String to) async {
    if (from == to) return 1.0; // trivial case

    final prefs = await SharedPreferences.getInstance();

    final cachedData = prefs.getString(_cacheKey);
    final cachedSlot = prefs.getInt(_timestampKey);
    final currentSlot = _getCurrentSlot().millisecondsSinceEpoch;

    Map<String, dynamic> cache = {};
    double? staleRate;

    if (cachedData != null && cachedSlot != null) {
      try {
        cache = json.decode(cachedData);

        if (cache[from] != null && cache[from][to] != null) {
          final rate = (cache[from][to] as num).toDouble();

          if (cachedSlot == currentSlot) {
            // ✅ Same slot, cache is valid
            print("✅ Using cached rate for $from → $to");
            return rate;
          } else {
            // ✅ Keep stale as fallback
            staleRate = rate;
          }
        }
      } catch (_) {
        await prefs.remove(_cacheKey);
        await prefs.remove(_timestampKey);
      }
    }

    // 🌍 Fetch all rates for "from" if slot changed or no cache
    try {
      print("🌍 Fetching new rates for base: $from");
      final url = Uri.parse("$_apiBase?base=$from");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["rates"] != null) {
          final rates = data["rates"] as Map<String, dynamic>;

          // Update cache
          cache[from] = rates;

          await prefs.setString(_cacheKey, json.encode(cache));
          await prefs.setInt(_timestampKey, currentSlot);

          if (rates[to] != null) {
            return (rates[to] as num).toDouble();
          }
        }
      }
    } catch (e) {
      print("❌ API failed, using stale cache if available: $e");
    }

    // ✅ Fallback to stale cache
    return staleRate;
  }
}
