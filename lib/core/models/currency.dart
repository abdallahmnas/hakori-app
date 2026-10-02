class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;
  final double rateToUsd; // 1 USD = rate * currency
  final String flagEmoji;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
    required this.rateToUsd,
    required this.flagEmoji,
  });
}
