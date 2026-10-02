import 'package:flutter/foundation.dart';
import '../models/currency.dart';
import 'mock_data_service.dart';

class CurrencyProvider extends ChangeNotifier {
  CurrencyInfo _selectedCurrency = MockDataService.supportedCurrencies[0]; // USD
  bool _autoLockRates = true;

  CurrencyInfo get selectedCurrency => _selectedCurrency;
  bool get autoLockRates => _autoLockRates;

  void setCurrency(CurrencyInfo currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  void toggleAutoLock(bool value) {
    _autoLockRates = value;
    notifyListeners();
  }

  String formatPrice(double priceInUsd) {
    final converted = priceInUsd * _selectedCurrency.rateToUsd;
    if (_selectedCurrency.code == 'NGN') {
      return '${_selectedCurrency.symbol}${converted.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    } else {
      return '${_selectedCurrency.symbol}${converted.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    }
  }

  String formatUsdAndNgn(double priceInUsd, double priceInNgn) {
    final usdFormatted = '\$${priceInUsd.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    final ngnFormatted = '₦${priceInNgn.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    return '$usdFormatted • $ngnFormatted';
  }
}
