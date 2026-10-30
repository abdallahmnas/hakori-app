import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_typography.dart';
import '../models/currency.dart';
import '../services/currency_provider.dart';

/// Reusable Dual Currency / Dynamic FX Price Display
class DualPriceText extends StatelessWidget {
  final double priceUsd;
  final double? priceNgn;
  final TextStyle? primaryStyle;
  final TextStyle? secondaryStyle;
  final bool showSecondary;
  final bool isVertical;

  const DualPriceText({
    super.key,
    required this.priceUsd,
    this.priceNgn,
    this.primaryStyle,
    this.secondaryStyle,
    this.showSecondary = true,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final activeFormatted = currencyProvider.formatPrice(priceUsd);

    // Calculate secondary conversion (e.g. if USD is active, show NGN secondary from exchange rates)
    String secondaryText = '';
    if (showSecondary) {
      if (currencyProvider.selectedCurrency.code == 'USD') {
        final ngnRate = currencyProvider.currencies
            .firstWhere(
              (c) => c.code == 'NGN',
              orElse: () => CurrencyInfo(
                code: 'NGN',
                symbol: '₦',
                name: 'Nigerian Naira',
                rateToUsd: 1600.0,
              ),
            )
            .price;
        final ngnAmount = (priceUsd * ngnRate).toStringAsFixed(0).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );
        secondaryText = '₦$ngnAmount';
      } else {
        final usdAmount =
            '\$${priceUsd.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
        secondaryText = '$usdAmount USD';
      }
    }

    if (isVertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            activeFormatted,
            style: primaryStyle ?? AppTypography.priceDisplay(),
          ),
          if (showSecondary && secondaryText.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              secondaryText,
              style: secondaryStyle ?? AppTypography.priceSecondary(),
            ),
          ],
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          activeFormatted,
          style: primaryStyle ?? AppTypography.priceDisplay(),
        ),
        if (showSecondary && secondaryText.isNotEmpty) ...[
          const SizedBox(width: 6),
          Text(
            '• $secondaryText',
            style: secondaryStyle ?? AppTypography.priceSecondary(),
          ),
        ],
      ],
    );
  }
}
