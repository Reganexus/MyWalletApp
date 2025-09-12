import 'package:flutter/material.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/screens/Rates/rates_loader.dart';
import 'package:mywallet/services/forex_service.dart';
import 'package:mywallet/utils/Currency/conversion_form.dart';
import 'package:mywallet/utils/Currency/conversion_result.dart';
import 'package:mywallet/utils/Currency/rate_list.dart';
import 'package:provider/provider.dart';

class LatestRatesScreen extends StatefulWidget {
  const LatestRatesScreen({super.key});

  @override
  State<LatestRatesScreen> createState() => _LatestRatesScreenState();
}

class _LatestRatesScreenState extends State<LatestRatesScreen> {
  Map<String, double> _rates = {};
  String? _fromCurrency = "PHP";
  String? _toCurrency = "USD";
  bool _loading = true;

  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();

    setState(() => _loading = true);

    // Listen for scroll position
    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset <= 300 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    });

    // Delay fetch so the screen builds first
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _loadRates();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRates() async {
    setState(() => _loading = true);
    try {
      final currencies = await ForexService.getCachedCurrencies();

      final results = await Future.wait(
        currencies.map((target) async {
          if (_fromCurrency != null) {
            final rate = await ForexService.getRate(_fromCurrency!, target);
            return MapEntry(target, rate);
          }
          return null;
        }),
      );

      final Map<String, double> tempRates = {};
      for (var entry in results) {
        if (entry != null && entry.value != null) {
          tempRates[entry.key] = entry.value!;
        }
      }

      if (mounted) {
        setState(() {
          _rates = tempRates;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      debugPrint("❌ Failed to load rates: $e");
    }
  }

  void _onConvert(String from, String to) {
    setState(() {
      _fromCurrency = from;
      _toCurrency = to;
    });
    _loadRates();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Latest Rates"),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
        elevation: 0,
        titleSpacing: 0,
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConversionResult(
                  from: _fromCurrency ?? 'PHP',
                  to: _toCurrency ?? 'USD',
                ),
                const SizedBox(height: 24),
                ConversionForm(onConvert: _onConvert),
                const SizedBox(height: 24),
                RatesList(rates: _rates, highlightCurrency: _toCurrency),
              ],
            ),
          ),

          // Loading overlay
          if (_loading) RatesLoader(),
        ],
      ),

      // Scroll-to-top FAB
      floatingActionButton:
          _showScrollToTop
              ? FloatingActionButton(
                backgroundColor: baseColor,
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                  );
                },
                child: const Icon(Icons.arrow_upward, color: Colors.white),
              )
              : null,
    );
  }
}
