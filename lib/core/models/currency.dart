/// Currency Exchange and FX Rate Models supporting api/exchange:
/// {
///   "id": "EXC-AED",
///   "code": "AED",
///   "name": "UAE Dirham",
///   "symbol": "د.إ",
///   "price": 3.6725,
///   "isBase": false,
///   "isActive": true,
///   "createdAt": "2026-10-29T21:53:45.159Z",
///   "updatedAt": "2026-10-29T21:53:45.159Z"
/// }
class CurrencyInfo {
  final String id;
  final String code;
  final String symbol;
  final String name;
  final double price; // Rate against base currency (USD)
  final bool isBase;
  final bool isActive;
  final String? _flagEmoji;
  final String createdAt;
  final String updatedAt;

  const CurrencyInfo({
    this.id = '',
    required this.code,
    required this.symbol,
    required this.name,
    required double rateToUsd,
    this.isBase = false,
    this.isActive = true,
    String? flagEmoji,
    this.createdAt = '',
    this.updatedAt = '',
  })  : price = rateToUsd,
        _flagEmoji = flagEmoji;

  String get flagEmoji => _flagEmoji ?? _defaultFlagForCode(code);

  /// Backward-compatible alias for rate against USD
  double get rateToUsd => price;

  factory CurrencyInfo.fromJson(Map<String, dynamic> json) {
    final code = json['code']?.toString().toUpperCase() ?? 'USD';
    final rawPrice = json['price'] ?? json['rateToUsd'] ?? 1.0;
    final double parsedPrice = (rawPrice is num)
        ? rawPrice.toDouble()
        : (double.tryParse(rawPrice?.toString() ?? '') ?? 1.0);

    return CurrencyInfo(
      id: json['id']?.toString() ?? 'EXC-$code',
      code: code,
      symbol: json['symbol']?.toString() ?? _defaultSymbolForCode(code),
      name: json['name']?.toString() ?? code,
      rateToUsd: parsedPrice,
      isBase: json['isBase'] as bool? ?? (code == 'USD'),
      isActive: json['isActive'] as bool? ?? true,
      flagEmoji: json['flagEmoji']?.toString() ?? _defaultFlagForCode(code),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'symbol': symbol,
      'price': price,
      'rateToUsd': price,
      'isBase': isBase,
      'isActive': isActive,
      'flagEmoji': flagEmoji,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static String _defaultFlagForCode(String code) {
    switch (code.toUpperCase()) {
      case 'USD':
        return '🇺🇸';
      case 'AED':
        return '🇦🇪';
      case 'CAD':
        return '🇨🇦';
      case 'CHF':
        return '🇨🇭';
      case 'EUR':
        return '🇪🇺';
      case 'GBP':
        return '🇬🇧';
      case 'JPY':
        return '🇯🇵';
      case 'KWD':
        return '🇰🇼';
      case 'NGN':
        return '🇳🇬';
      case 'QAR':
        return '🇶🇦';
      case 'SAR':
        return '🇸🇦';
      default:
        return '🌐';
    }
  }

  static String _defaultSymbolForCode(String code) {
    switch (code.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'AED':
        return 'د.إ';
      case 'CAD':
        return 'CA\$';
      case 'CHF':
        return 'CHF';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'KWD':
        return 'KD';
      case 'NGN':
        return '₦';
      case 'QAR':
        return 'QR';
      case 'SAR':
        return '﷼';
      default:
        return code;
    }
  }
}

/// Container for the complete exchange response
class ExchangeData {
  final String baseCurrency;
  final List<CurrencyInfo> rates;
  final String lastUpdated;

  const ExchangeData({
    this.baseCurrency = 'USD',
    required this.rates,
    this.lastUpdated = '',
  });

  factory ExchangeData.fromJson(Map<String, dynamic> json) {
    List<CurrencyInfo> parsedRates = [];
    final rawRates = json['rates'];
    if (rawRates is List) {
      for (final r in rawRates) {
        if (r is Map<String, dynamic>) {
          parsedRates.add(CurrencyInfo.fromJson(r));
        } else if (r is Map) {
          parsedRates.add(CurrencyInfo.fromJson(Map<String, dynamic>.from(r)));
        }
      }
    }

    return ExchangeData(
      baseCurrency: json['baseCurrency']?.toString() ?? 'USD',
      rates: parsedRates,
      lastUpdated: json['lastUpdated']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseCurrency': baseCurrency,
      'rates': rates.map((r) => r.toJson()).toList(),
      'lastUpdated': lastUpdated,
    };
  }
}
