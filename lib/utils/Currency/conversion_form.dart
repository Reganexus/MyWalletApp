import 'package:flutter/material.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/services/currencies.dart';
import 'package:mywallet/services/forex_service.dart';
import 'package:mywallet/utils/Design/form_decoration.dart';
import 'package:provider/provider.dart';

class ConversionForm extends StatefulWidget {
  final void Function(String from, String to, double rate) onConvert;

  const ConversionForm({super.key, required this.onConvert});

  @override
  State<ConversionForm> createState() => _ConversionFormState();
}

class _ConversionFormState extends State<ConversionForm> {
  final _formKey = GlobalKey<FormState>();
  String _fromCurrency = 'PHP';
  String _toCurrency = 'USD';
  bool _loading = false;

  final FocusNode _fromFocus = FocusNode();
  final FocusNode _toFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _fromFocus.addListener(() => setState(() {}));
    _toFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fromFocus.dispose();
    _toFocus.dispose();
    super.dispose();
  }

  Future<void> _convert() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final rate = await ForexService.getRate(_fromCurrency, _toCurrency);
    if (rate != null) {
      widget.onConvert(_fromCurrency, _toCurrency, rate);
    }

    setState(() => _loading = false);
  }

  List<DropdownMenuItem<String>> _buildCurrencyDropdownItems() {
    return allCurrencies.map((currency) {
      return DropdownMenuItem(value: currency.code, child: Text(currency.code));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            focusNode: _fromFocus,
            initialValue: _fromCurrency,
            items: _buildCurrencyDropdownItems(),
            onChanged: (val) => setState(() => _fromCurrency = val!),
            decoration: buildInputDecoration(
              "From Currency",
              color: baseColor,
              isFocused: _fromFocus.hasFocus,
              context: context,
            ),
            validator: (val) => val == null ? "Please select a currency" : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            focusNode: _toFocus,
            initialValue: _toCurrency,
            items: _buildCurrencyDropdownItems(),
            onChanged: (val) => setState(() => _toCurrency = val!),
            decoration: buildInputDecoration(
              "To Currency",
              color: baseColor,
              isFocused: _toFocus.hasFocus,
              context: context,
            ),
            validator: (val) => val == null ? "Please select a currency" : null,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _convert,
              style: FilledButton.styleFrom(
                backgroundColor: baseColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _loading
                      ? CircularProgressIndicator(color: baseColor)
                      : const Text(
                        "Convert",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
