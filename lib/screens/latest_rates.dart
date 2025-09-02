import 'package:flutter/material.dart';
import 'package:mywallet/services/forex_service.dart';
import 'package:mywallet/utils/Currency/conversion_form.dart';
import 'package:mywallet/utils/Currency/conversion_result.dart';
import 'package:mywallet/utils/Currency/rate_list.dart';

class LatestRatesScreen extends StatefulWidget {
  const LatestRatesScreen({super.key});

  @override
  State<LatestRatesScreen> createState() => _LatestRatesScreenState();
}

class _LatestRatesScreenState extends State<LatestRatesScreen> {
  Map<String, double> _rates = {};
  String? _fromCurrency;
  String? _toCurrency;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    setState(() => _loading = true);
    final currencies = await ForexService.getCachedCurrencies();
    final Map<String, double> tempRates = {};

    for (var target in currencies) {
      if (_fromCurrency != null) {
        final rate = await ForexService.getRate(_fromCurrency!, target);
        if (rate != null) tempRates[target] = rate;
      }
    }

    setState(() {
      _rates = tempRates;
      _loading = false;
    });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Latest Rates"),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
        elevation: 0,
        titleSpacing: 0,
      ),
      body:
          _loading
              ? const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text("Loading currency rates"),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ConversionResult(
                      from: _fromCurrency ?? 'PHP',
                      to: _toCurrency ?? 'USD',
                    ),
                    SizedBox(height: 24),
                    ConversionForm(onConvert: _onConvert),
                    SizedBox(height: 24),
                    RatesList(rates: _rates, highlightCurrency: _toCurrency),
                  ],
                ),
              ),
    );
  }
}
