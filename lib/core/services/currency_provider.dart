import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../models/currency.dart';
import 'api_client.dart';
import 'storage_service.dart';

/// Provider managing exchange rates from api/exchange, local storage caching,
/// active display currency selection, and automatic real-time price conversion.
class CurrencyProvider extends ChangeNotifier {
  final ApiClient? _apiClient;
  final StorageService? _storageService;

  static const List<CurrencyInfo> defaultCurrencies = [
    CurrencyInfo(id: 'EXC-USD', code: 'USD', name: 'US Dollar', symbol: '\$', rateToUsd: 1.0, isBase: true),
    CurrencyInfo(id: 'EXC-AED', code: 'AED', name: 'UAE Dirham', symbol: 'د.إ', rateToUsd: 3.6725),
    CurrencyInfo(id: 'EXC-CAD', code: 'CAD', name: 'Canadian Dollar', symbol: 'CA\$', rateToUsd: 1.382),
    CurrencyInfo(id: 'EXC-CHF', code: 'CHF', name: 'Swiss Franc', symbol: 'CHF', rateToUsd: 0.892),
    CurrencyInfo(id: 'EXC-EUR', code: 'EUR', name: 'Euro', symbol: '€', rateToUsd: 0.9215),
    CurrencyInfo(id: 'EXC-GBP', code: 'GBP', name: 'British Pound', symbol: '£', rateToUsd: 0.7842),
    CurrencyInfo(id: 'EXC-JPY', code: 'JPY', name: 'Japanese Yen', symbol: '¥', rateToUsd: 154.5),
    CurrencyInfo(id: 'EXC-KWD', code: 'KWD', name: 'Kuwaiti Dinar', symbol: 'KD', rateToUsd: 0.308),
    CurrencyInfo(id: 'EXC-NGN', code: 'NGN', name: 'Nigerian Naira', symbol: '₦', rateToUsd: 1600.0),
    CurrencyInfo(id: 'EXC-QAR', code: 'QAR', name: 'Qatari Riyal', symbol: 'QR', rateToUsd: 3.64),
    CurrencyInfo(id: 'EXC-SAR', code: 'SAR', name: 'Saudi Riyal', symbol: '﷼', rateToUsd: 3.75),
  ];

  List<CurrencyInfo> _currencies = List.from(defaultCurrencies);
  late CurrencyInfo _selectedCurrency;
  bool _autoLockRates = true;
  bool _isLoading = false;
  String? _errorMessage;
  String _lastUpdated = '';

  CurrencyProvider([this._apiClient, this._storageService]) {
    _selectedCurrency = _currencies.firstWhere(
      (c) => c.code == 'USD',
      orElse: () => _currencies.first,
    );
    _restoreFromStorage();
  }

  List<CurrencyInfo> get currencies => List.unmodifiable(_currencies);
  List<CurrencyInfo> get supportedCurrencies => currencies;
  CurrencyInfo get selectedCurrency => _selectedCurrency;
  bool get autoLockRates => _autoLockRates;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get lastUpdated => _lastUpdated;

  void _restoreFromStorage() {
    final storage = _storageService;
    if (storage == null) return;

    // 1. Restore cached exchange rates
    final cached = storage.getExchangeData();
    if (cached != null) {
      try {
        final exchangeData = ExchangeData.fromJson(cached);
        if (exchangeData.rates.isNotEmpty) {
          _currencies = exchangeData.rates;
          _lastUpdated = exchangeData.lastUpdated;
        }
      } catch (_) {}
    }

    // 2. Restore saved currency code preference
    final savedCode = storage.getSelectedCurrencyCode();
    if (savedCode != null && savedCode.isNotEmpty) {
      final match = _currencies.firstWhere(
        (c) => c.code.toUpperCase() == savedCode.toUpperCase(),
        orElse: () => _selectedCurrency,
      );
      _selectedCurrency = match;
    }
  }

  /// Fetches latest exchange rates from api/exchange, caches in local storage & provider
  Future<void> fetchExchangeRates({bool silent = false}) async {
    final client = _apiClient;
    if (client == null) return;

    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final response = await client.get(ApiConstants.exchange);
      final respData = response.data;
      Map<String, dynamic>? dataMap;

      if (respData is Map) {
        if (respData['data'] is Map) {
          dataMap = Map<String, dynamic>.from(respData['data'] as Map);
        } else if (respData['rates'] is List) {
          dataMap = Map<String, dynamic>.from(respData);
        }
      }

      if (dataMap != null) {
        final exchangeData = ExchangeData.fromJson(dataMap);
        if (exchangeData.rates.isNotEmpty) {
          _currencies = exchangeData.rates;
          _lastUpdated = exchangeData.lastUpdated;

          // Re-link current selected currency with updated rate
          _selectedCurrency = _currencies.firstWhere(
            (c) => c.code.toUpperCase() == _selectedCurrency.code.toUpperCase(),
            orElse: () => _currencies.first,
          );

          // Cache response on local storage
          await _storageService?.saveExchangeData(dataMap);
        }
      }

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      if (!silent) {
        _errorMessage = 'Could not update exchange rates';
      }
      notifyListeners();
    }
  }

  /// Updates active currency, persists choice in local storage & provider
  Future<void> setCurrency(CurrencyInfo currency) async {
    _selectedCurrency = currency;
    await _storageService?.saveSelectedCurrencyCode(currency.code);
    notifyListeners();
  }

  void toggleAutoLock(bool value) {
    _autoLockRates = value;
    notifyListeners();
  }

  /// Converts a price from base currency (USD) into the active selected currency
  double convertPrice(double priceInUsd) {
    return priceInUsd * _selectedCurrency.price;
  }

  /// Formats price in the currently active currency with its native symbol and decimal precision
  String formatPrice(double priceInUsd) {
    final converted = convertPrice(priceInUsd);
    final symbol = _selectedCurrency.symbol;
    final code = _selectedCurrency.code.toUpperCase();

    // Use zero decimals for currencies with large denominations (NGN, JPY, KWD, etc.)
    final bool isZeroDecimal = (code == 'NGN' || code == 'JPY');
    final String formattedNumber = isZeroDecimal
        ? converted.toStringAsFixed(0).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            )
        : converted.toStringAsFixed(2).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );

    // If symbol ends with space or is Arabic (e.g. د.إ or ﷼ or QR) format cleanly
    if (symbol.endsWith(' ') || code == 'AED' || code == 'SAR' || code == 'QAR' || code == 'KWD') {
      return '$symbol $formattedNumber'.replaceAll('  ', ' ');
    }
    return '$symbol$formattedNumber';
  }

  String formatUsdAndNgn(double priceInUsd, double priceInNgn) {
    final usdFormatted = '\$${priceInUsd.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    final ngnFormatted = '₦${priceInNgn.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    return '$usdFormatted • $ngnFormatted';
  }
}
